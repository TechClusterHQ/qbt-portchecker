# qbt-portchecker

small docker mod for the [linuxserver.io qbittorrent container](https://docs.linuxserver.io/images/docker-qbittorrent) that automatically updates the torrenting port to the forwarded vpn port (via [gluetun](https://github.com/qdm12/gluetun)) and checks if you are connectable.

adapted from a script made by [schumi4](https://github.com/schumi4)

Important: If you were using an older version of this script (that uses custom services and is not a docker mod), remove it first: Delete the custom-services volume and the corresponding folder on your drive. After you've upgraded, the script will update itself and no manual intervention is needed.

## Installation

First up, enable the option "Bypass authentication for clients on localhost" in the qBittorrent settings under the "Web UI" tab

Add the following environment variables to your qBittorrent container:
```yaml
- DOCKER_MODS=ghcr.io/techclusterhq/qbt-portchecker:main
- PORTCHECKER_GLUETUN_API_KEY=API KEY HERE # instructions below
- PORTCHECKER_SLEEP=180 # optional, default 180: how long the script should wait between each check
- PORTCHECKER_KILL_ON_NOT_CONNECTABLE=true # optional, default true: whether or not to restart qBittorrent if the port stops being connectable
```

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
