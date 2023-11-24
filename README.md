# AIO-plutonium-t6 [A all-in-one plutonium server, Easier]

[![build images](https://github.com/thejcpalma/AIO-plutonium-t6-server-docker-setup/actions/workflows/docker-images.yml/badge.svg?branch=main)](https://github.com/thejcpalma/AIO-plutonium-t6-server-docker-setup/actions/workflows/docker-images.yml)

Files Used to Build and run a [Plutonium](https://plutonium.pw) Server and a [IW4Admin](https://github.com/RaidMax/IW4M-Admin) Panel in docker

This is intended to make hosting a ~lan~ server easier and faster, removing the worry of making your own full installation from scratch.

> Trust me bro, I've been there. :sunglasses:

This Repository is a work in progress state, so if you think there's an improvement to be made please contribute in the Issues Tab

- Currently this repository is only tested in Linux, but it should work in any system able to run Docker.

- It's also only tested in a LAN environment, but it should work in a WAN environment as well.

- And it's only tested with the Zombie mode, but it should work with the Multiplayer mode as well.

> Don't quote me on the statements above :sweat_smile:


## Setup

Requirements:

 - Docker
    > Works in any system able to run [Docker](https://docs.docker.com/get-docker/).
 - Joy, lots of joy
    > Yeah, as simple as that, no need to worry about anything else really :smile:


## Installation

### 1. Docker volume creation

First we need to create a docker volume to store our server files, this will make it easier to manage the server files and keep them persistent between restarts.

For this we use the following command:
```bash
docker volume create <volume_name>
```
> **Note:** You can use any name you want for the volume, but it's recommended to use a name that is easy to remember and identify.

For easier setup, we use the name `aio-plutonium-t6` for the volume:
```bash
docker volume remove aio-plutonium-t6 || true && \
docker volume create aio-plutonium-t6
```
> **Note:** We first remove the volume if it exists, to avoid any errors. Be carefil when using this command, as it will remove any data stored in the volume.


### 2. Launching the server

Now that we have our volume created, we can launch the server.

We can launch the server online or in LAN mode.

To launch the server in online mode, we use the following command:
```bash
docker run -d --name <container_name> \
              -p <game_server_host_port>:4976/udp \
              -p <admin_panel_host_port>:1624/tcp \
              -v <volume_name>:/t6server \
              -e SERVER_KEY="<your_plutonium_server_key>" \
              -e SERVER_RCON_PASSWORD="<rcon_password>" \
              -e SERVER_MAX_CLIENTS="<max_clients>" \
              -e SERVER_MODE="<server_mode>"
```

An example of a full command to launch the Zombies server in online mode is:
```bash
docker run -d --name aio-plutonium-t6-server \
              -p 4976:4976/udp \
              -p 1624:1624/tcp \
              -v aio-plutonium-t6:/t6server \
              -e SERVER_KEY="aFb57Hkbe" \
              -e SERVER_RCON_PASSWORD="admin" \
              -e SERVER_MAX_CLIENTS="7"
```
> **Note:** The key is completely random on this example, you should use your own key from [Plutonium](https://plutonium.pw).

To launch the server in LAN mode, we use the following command:
```bash
docker run -d --name <container_name> \
              -p <game_server_host_port>:4976/udp \
              -p <admin_panel_host_port>:1624/tcp \
              -v <volume_name>:/t6server \
              -e LAN_MODE="true" \
              -e SERVER_RCON_PASSWORD="<rcon_password>" \
              -e SERVER_MAX_CLIENTS="<max_clients>" \
              -e SERVER_MAP_ROTATION='<map_rotation_string>' \
              -e SERVER_MODE="<server_mode>"
```

An example of a full command to launch the Zombies server in LAN mode is:
```bash
docker run -d --name aio-plutonium-t6-server \
              -p 4976:4976/udp \
              -p 1624:1624/tcp \
              -v aio-plutonium-t6:/t6server \
              -e LAN_MODE="true" \
              -e SERVER_RCON_PASSWORD="admin" \
              -e SERVER_MAX_CLIENTS="8" \
              -e SERVER_MAP_ROTATION='sv_maprotation "exec zm_classic_transit.cfg map zm_transit"'
```


Breakdown of the parameters used in the `docker run` command:

| **Parameter**                               | **Function**                                                                                                                                                 |
|---------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `--name <container_name>`                   | Set container name.                                                                                                                                          |
| `-v <volume_name>:/t6server`                | Map docker volume <volume_name> to directory `/t6server` keep the files persistent between restarts.                                                         |
| `-p <game_server_host_port>:4976/udp`       | Map game server port (host:guest/protocol). Game server protocol must be UDP. Don't change guest port unless you change `SERVER_PORT` environment variable.  |
| `-p <admin_panel_host_port>:1624/tcp`       | Map admin panel port (host:guest/protocol). Admin panel protocol must be TCP. Don't change guest port unless you change `ADMIN_PORT` environment variable.   |
| `-e LAN_MODE="true"`                        | Set to `true` to enable LAN mode (Any other value will disable LAN mode).                                                                                    |
| `-e SERVER_MAX_CLIENTS="<max_clients>"`     | The maximum number of clients allowed on your server. Between `1-8` (Leave blank for default, which is `4`).                                                 |
| `-e SERVER_RCON_PASSWORD="<rcon_password>"` | The password for your server's RCON. (Leave blank for default, which is `admin`).                                                                            |



### 3. Setup IW4MAdmin

Now that we have our container up and running, if everything went well, we have 2 `screen` processes running in the background, one with the game server (named `plutonium-server`) and another with the admin panel (`admin-panel`).

We still need to run the initial setup for the admin panel, so we can access it in our browser afterwards.

To do this, we need to attach to the `admin-panel` screen process inside the container, and run the initial setup:
```bash
docker exec -it --entrypoint /bin/bash <container_name> -c "screen -r admin-panel"
```

An example of a full command to attach to the `admin-panel` screen process is:
```bash
docker exec -it --entrypoint /bin/bash aio-plutonium-t6-server -c "screen -r admin-panel"
```

Now we are inside the `admin-panel` screen process, and we shall follow [IW4Admin's initial configuration](https://github.com/RaidMax/IW4M-Admin/wiki/Configuration).

Any issues Regarding IW4Admin should be directed to the [IW4Admin's repository](https://github.com/RaidMax/IW4M-Admin), and check the [IW4Admin's wiki](https://github.com/RaidMax/IW4M-Admin/wiki) for more information.

After you finish the initial configuration, you can detach from the `screen` process by pressing `Ctrl+A` and then `Ctrl+D`.

Now you should be able to visit IW4Admin in your browser via `http://hostname:1624` with your server configured (`hostname` is the IP address of the host you´re running the container in).

## Environment Variables

### Fixed Environment Variables

The following is a list of all the environment variables that will break your server if you change them.

> ** :warning: PROCEED WITH CAUTION :warning: **

**Directories Environment Variables:**

| **Environment Variable**    | **Default Value**              |
|-----------------------------|--------------------------------|
| `PLUTONIUM_DIRECTORY`       | "/t6server/plutonium"          |
| `SERVER_DIRECTORY`          | "/t6server/server"             |
| `IW4ADMIN_DIRECTORY`        | "/t6server/admin"              |
| `UPDATER_DIRECTORY`         | "/t6server/updater"            |
| `DOWNLOAD_DIRECTORY`        | "/t6server/downloaded_files"   |
| `STATUS_DIRECTORY`          | "/t6server/status"             |

**Wine Environment Variables**

| **Environment Variable**    | **Default Value**              |
|-----------------------------|--------------------------------|
| `WINEPREFIX`                | "/root/.wine"                  |
| `WINEDEBUG`                 | "fixme-all"                    |
| `WINEARCH`                  | "win64"                        |

### Changeable Environment Variables

The following is a list of all the environment variables that you can change.

| **Environment Variable**    | **Default Value**                 | **Description**                                                                                                  |
|-----------------------------|-----------------------------------|------------------------------------------------------------------------------------------------------------------|
| `SERVER_KEY`                | "your_plutonium_server_key_here"  | Your server key from [Plutonium](https://plutonium.pw).                                                          |
| `SERVER_PORT`               | "4976"                            | The port your game server will run on (game server protocol must be UDP).                                        |
| `SERVER_MODE`               | "Zombie"                          | The mode your game server will run on. Either `Zombie` or `Multiplayer` (any other value defaults to `Zombie`).  |
| `LAN_MODE`                  | "false"                           | Set to `true` to enable LAN mode (Any other value will disable LAN mode).                                        |
| `SERVER_MAX_CLIENTS`        | ""                                | The maximum number of clients allowed on your server. Between `1-8` (Leave blank for default, which is `4`).     |
| `SERVER_MAP_ROTATION`       | ""                                | String to set the map rotation. (Leave blank for default).                                                       |
| `SERVER_RCON_PASSWORD`      | "admin"                           | The password for your server's RCON. (Leave blank for default, which is `admin`).                                |
| `ADMIN_PORT`                | "1624"                            | The port your admin panel will run on (admin panel protocol must be TCP).                                        |

* `SERVER_MAP_ROTATION`

The string to be passed will replace the default `sv_maprotation` configuration on the server dedicated configuration file.
You can change it to whatever you want, but it must be a valid string of commands.

Bellow is an example of a valid string of commands:
 ```
 'sv_maprotation "exec zm_classic_transit.cfg map zm_transit exec zm_classic_tomb.cfg map zm_tomb exec zm_classic_prison.cfg map zm_prison"'
 ```

* `SERVER_PORT`

This value must be the same as the port you mapped in the `-p <game_server_host_port>:4976/udp` parameter.
Here the default value is `4976`, but you can change it to whatever you want, as long as it's the same as the port you mapped.

So if you mapped the port `4977` in the `-p <game_server_host_port>:4977/udp` parameter, you must change the `SERVER_PORT` environment variable to `4977` as well.

* `ADMIN_PORT`

This value must be the same as the port you mapped in the `-p <admin_panel_host_port>:1624/tcp` parameter.
Here the default value is `1624`, but you can change it to whatever you want, as long as it's the same as the port you mapped.

So if you mapped the port `1625` in the `-p <admin_panel_host_port>:1625/tcp` parameter, you must change the `ADMIN_PORT` environment variable to `1625` as well.

## Credits

Projects used in this repository:
- [Plutonium](https://plutonium.pw) for the game server files.
- [RaidMax](https://github.com/RaidMax)/[IW4Admin](https://github.com/RaidMax/IW4M-Admin) for the admin panel.
- [mxve](https://github.com/mxve)/[plutonium-updater.rs](https://github.com/mxve/plutonium-updater.rs) for the plutonium updater.
- [xerxes-at](https://github.com/xerxes-at)/[T6ServerConfigs](https://github.com/xerxes-at/T6ServerConfigs) for the server configuration files.


**The true heroes of this repository:**
- [GaryCraft](https://github.com/GaryCraft)/[ptero-plutonium](https://github.com/GaryCraft/ptero-plutonium)
- [rexlManu](https://github.com/rexlManu)/[t6server-docker-setup](https://github.com/rexlManu/t6server-docker-setup)

Without their repositories, this repository would not exist. So thank you very much for your work. :heart:
