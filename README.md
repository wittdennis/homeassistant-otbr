# Homeassistant OpenThread Border Router

This is a standalone version of the Homeassistant OpenThread Border Router Addon ([link](https://github.com/home-assistant/addons/blob/master/openthread_border_router/README.md)).

What I've done is remove all direct integrations with HA OS from the scripts and made every configuration possible via environment variables.

Furthermore I've added proper multi-arch support for the resulting image (You can find the image [here](https://hub.docker.com/r/denniswitt/homeassistant-otbr))

Here are the config environment variables:

| Configuration  | Required | Description                                                           | Example           |
| -------------- | :------: | --------------------------------------------------------------------- | ----------------- |
| DEVICE         |    x     | Serial port where the OpenThread RCP Radio is attached                | /dev/ttyUSB0      |
| BAUDRATE       |          | Serial port baudrate (depends on firmware)                            | 48000             |
| BACKBONE_IF    |          | Underlying network interface to use                                   | wlan0             |
| FLOW_CONTROL   |          | If hardware flow control should be enabled (depends on firmware)      | 0                 |
| OTBR_LOG_LEVEL |          | Set the log level of the OpenThread BorderRouter Agent                | 4                 |
| FIREWALL       |          | Enable OpenThread Border Router firewall to block unnecessary traffic | 1                 |
| NAT64          |          | Enable NAT64 to allow Thread devices accessing IPv4 addresses         | 0                 |
| NETWORK_DEVICE |          | IP address and port to connect to a network-based RCP                 | 192.168.1.10:5827 |

For guidance how to use the addon see the official documentation.

- https://github.com/home-assistant/addons/blob/master/openthread_border_router/DOCS.md
- https://www.home-assistant.io/integrations/otbr/
- https://www.home-assistant.io/integrations/thread/
