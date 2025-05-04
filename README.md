# qbt-portchecker

Docker mod for the [linuxserver.io qbittorrent container](https://docs.linuxserver.io/images/docker-qbittorrent) that automatically updates the torrenting port to the forwarded vpn port (via [gluetun](https://github.com/qdm12/gluetun)) and checks if you are connectable.

Based on a script made by [schumi4](https://github.com/schumi4)

Pick the [dynamic port installation](#installation-dynamic-port) for VPN providers who decide the port that you will be forwarding for you (for example ProtonVPN and PIA), the script will then automatically update the port qBittorrent uses for torrent traffic.\
If your VPN provider lets you select a port to be forwarded that stays the same (like AirVPN), follow the instructions for the [static port installation](#installation-static-port).

Important: If you were using an older version of this script (that uses custom services and is not a docker mod), remove it first: Delete the custom-services volume and the corresponding folder on your drive. After you've upgraded, the script will update itself and no manual intervention is needed.

## Installation (dynamic port)

> [!NOTE]
> Gluetun port forwarding must already be set up for the portchecker to function correctly
> See the [gluetun documentation](https://github.com/qdm12/gluetun-wiki/blob/main/setup/advanced/vpn-port-forwarding.md#native-integrations) for more details

First, enable the option "Bypass authentication for clients on localhost" in the qBittorrent settings under the "Web UI" tab

Add the following environment variables to your qBittorrent container:
- `WEBUI_PORT=8080`: If it doesn't exist already and you changed the port from the default 8080
- `DOCKER_MODS=ghcr.io/techclusterhq/qbt-portchecker:main`
- `PORTCHECKER_GLUETUN_API_KEY=API KEY HERE`: Instructions below
- `PORTCHECKER_GLUETUN_CONTROL_SERVER_PORT=8000`: Optional, default 8000: the port the gluetun control server can be reached at
- `PORTCHECKER_SLEEP=120`: Optional, default 120: how long the script should wait between each check
- `PORTCHECKER_KILL_ON_NOT_CONNECTABLE=true`: Optional, default true: whether or not to restart qBittorrent if the port stops being connectable
- `PORTCHECKER_HTTPS=false`: Optional, default false: Set to `true` if you configured qBittorrent WebUI to use HTTPS.

> [!NOTE]  
> If you are already using another docker mod with your qBittorrent container you have to combine both into one DOCKER_MODS variable, seperated by a pipe:
> ```yaml
> DOCKER_MODS=ghcr.io/techclusterhq/qbt-portchecker:main|ghcr.io/techclusterhq/qbt-slowban:main
> ```

If it exists, remove the `TORRENTING_PORT` variable completely.

Then, volume the gluetun folder from the gluetun container to your host if you haven't already:
```yaml
volumes:
    - ./gluetun:/gluetun
```
> [!NOTE]  
> Refer to the [gluetun documentation](https://github.com/qdm12/gluetun-wiki/blob/main/setup/advanced/control-server.md) for more information regarding the auth system

Generate an api key using `docker run --rm -v ./gluetun:/gluetun qmcgaw/gluetun genkey`, which should also create the gluetun folder.

Navigate to the gluetun folder and create the "auth" subdirectory. If there are issues with folder permissions, run the mkdir command as root.

Copy the following template to a file called `config.toml` (create it if it doesn't exist) and paste in your generated api key.
```toml
[[roles]]
name = "qbt-portchecker"
routes = ["GET /v1/openvpn/portforwarded"]
auth = "apikey"
apikey = "API KEY HERE"
```
Now, set the qBittorrent environment variable `PORTCHECKER_GLUETUN_API_KEY` to the api key.

Start the stack again and check if the program updates the port accordingly. Feel free to open a [GitHub issue](https://github.com/TechClusterHQ/qbt-portchecker/issues) or DM me on Discord (username `app.py`).

## Installation (static port)

> [!NOTE]
> Gluetun port forwarding must already be set up for the portchecker to function correctly
> See the [gluetun documentation](https://github.com/qdm12/gluetun-wiki/blob/main/setup/advanced/vpn-port-forwarding.md#allow-a-forwarded-port-through-the-firewall) for more details

First, enable the option "Bypass authentication for clients on localhost" in the qBittorrent settings under the "Web UI" tab

Add the following environment variables to your qBittorrent container:
- `WEBUI_PORT=8080`: If it doesn't exist already and you changed the port from the default 8080
- `DOCKER_MODS=ghcr.io/techclusterhq/qbt-portchecker:main`
- `FIREWALL_VPN_INPUT_PORTS=12345`: Set this to your forwarded vpn port
- `PORTCHECKER_SLEEP=180`: Optional, default 180: how long the script should wait between each check
- `PORTCHECKER_KILL_ON_NOT_CONNECTABLE=true`: Optional, default true: whether or not to restart qBittorrent if the port stops being connectable
- `PORTCHECKER_HTTPS=false`: Optional, default false: Set to `true` if you configured qBittorrent WebUI to use HTTPS.

If it exists, remove the `TORRENTING_PORT` variable completely.

Start the stack again and check if the program updates the port accordingly. Feel free to open a [GitHub issue](https://github.com/TechClusterHQ/qbt-portchecker/issues) or DM me on Discord (username `app.py`).

## Disabling gluetun control server log messages

If you don't want gluetun to print a log message every time the portchecker accesses the currently open port, you can add the following environment variable to the gluetun service:
```yaml
HTTP_CONTROL_SERVER_LOG=off
```
