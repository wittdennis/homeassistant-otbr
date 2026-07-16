---
name: sync-upstream-otbr
description: Port upstream Home Assistant OTBR addon changes into this fork's rootfs when the base image version bumps. Use whenever Renovate opens a branch bumping homeassistant/amd64-addon-otbr in the Dockerfile, or when asked to sync/update against upstream.
---

# Sync upstream OTBR addon changes into this fork

## What this repo is

This is a **standalone fork** of the Home Assistant `openthread_border_router` addon
(upstream: `home-assistant/addons`, path `openthread_border_router/`). It `FROM`s the
upstream image (`docker.io/homeassistant/amd64-addon-otbr:<VERSION>`) and overlays its
own `rootfs/` — reimplemented s6 startup/config scripts that strip out HA-OS coupling
and drive everything via **environment variables** instead of bashio/addon config.

Because the overlay scripts are reimplementations of the upstream ones, a base-image
version bump can carry **behavioral changes in the upstream scripts that must be
manually mirrored** into this fork's `rootfs/`. Renovate only bumps the tag; it cannot
do this part. The goal (per README) is to stay "1:1 version feature-wise" with upstream.

## Trigger

A Renovate branch/PR bumping `ARG VERSION=` in `Dockerfile` (the
`homeassistant/amd64-addon-otbr` base image). The renovate rule labels these `fix`.

## Procedure

### 1. Identify old and new version

```bash
git diff main..HEAD -- Dockerfile   # shows OLD -> NEW, e.g. 3.0.1 -> 3.0.2
```

### 2. Get the upstream source and map versions to commits

The upstream addon version lives in `openthread_border_router/config.yaml` (`version:`).

```bash
cd "$SCRATCH"   # use the session scratchpad, not the repo
git clone --quiet --filter=blob:none --no-checkout https://github.com/home-assistant/addons.git addons
cd addons
# Find the commit where each version was set:
for v in <OLD> <NEW>; do echo "=== $v ==="; git log --oneline -S "version: $v" -- openthread_border_router/config.yaml | head -3; done
# Confirm the exact version at a candidate commit:
git show <commit>:openthread_border_router/config.yaml | grep '^version:'
```

Usually each patch bump is a single upstream commit.

### 3. Diff the upstream changes

```bash
git show <new_commit> -- openthread_border_router/          # single-commit bump
# or, for a multi-commit range:
git diff <old_commit>..<new_commit> -- openthread_border_router/rootfs/
```

### 4. Classify each hunk — port or skip

**Port** (these change runtime behavior of the overlay):
- Changes under `rootfs/etc/s6-overlay/` — startup args, service run/finish scripts,
  config logic, firewall/NAT64 rules, log-level handling, new services.
- New config knobs that upstream exposes — add a matching **env var** and document it
  in `README.md`'s config table.

**Skip** (not part of this fork's surface):
- `build.yaml` OTBR/beta version args, `Dockerfile` build steps, build patches
  (`*.patch`) — the fork consumes the prebuilt upstream image, it doesn't build OTBR.
- `DOCS.md`, `translations/`, `icon.png`, `config.yaml` fields other than behavior.
- Pure bashio-internal refactors with no behavior change.
- HA discovery / supervisor / addon-port detection — deliberately stubbed out here
  (see the commented-out blocks in `enable-check.sh` and `otbr-agent-rest-discovery.sh`).

### 5. Adapt upstream idioms to this fork's style

When porting a hunk, translate:

| Upstream (bashio)                          | This fork                                                        |
| ------------------------------------------ | --------------------------------------------------------------- |
| `bashio::config 'foo'`                     | `$FOO` env var (document in README table)                       |
| `bashio::addon.port 8080`                  | `${OTBR_WEB_PORT:-8080}` style env var with default             |
| `bashio::log.info "x"` / `.warning`        | `echo "INFO: x"` / `echo "WARN: x"`                             |
| `bashio::exit.nok "x"`                     | lenient: `echo "WARN: x ... using <default>"` + fall back; use `exit 1` only for genuinely fatal config |
| `bashio::string.lower "$(bashio::config x)"` | `${X:-default}` (env vars already plain strings)              |

Preserve the fork's **lenient** philosophy: prefer warn-and-default over hard exit for
bad/missing optional config. Keep shared logic in
`rootfs/etc/s6-overlay/scripts/otbr-agent-common` (sourced by the run/finish scripts),
mirroring how upstream factors shared helpers there.

### 6. Verify

```bash
for f in <changed scripts>; do bash -n "$f" && echo "OK: $f"; done
command -v shellcheck >/dev/null && shellcheck -s bash <changed scripts>
# Smoke-test any new helper by sourcing otbr-agent-common and exercising it with
# representative env-var values (valid, unset, and invalid inputs).
```

### 7. Commit

Follow repo conventions (see global CLAUDE.md): semantic commit, `-s -S`,
`Co-Authored-By` footer. **Do not commit or push without explicit permission.**
The Dockerfile bump itself is already committed by Renovate on the branch; add the
rootfs port as a separate commit (e.g. `feat:`/`fix:` describing the ported behavior).

## Reference: worked example (3.0.1 → 3.0.2)

Upstream commit `73a34f9` "Honor otbr_log_level for the web UI". Relevant change: the
web UI stopped hardcoding `-d6` and now honors the configured log level, via a new
shared `otbr_log_level_to_int` helper. Ported by:
- adding `otbr_log_level_to_int()` (env-var based, warns to stderr + defaults to info) to `otbr-agent-common`;
- replacing the inline `case` in `otbr-agent/run` with a call to it;
- sourcing the common file in `otbr-web/run` and passing `-d"${otbr_log_level_int}"`.

Everything else in that commit (beta OTBR bump, dropped `SO_REUSEADDR` build patch,
DOCS typo, bashio refactor) was correctly **skipped**.
