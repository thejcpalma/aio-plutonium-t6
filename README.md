# plutonium t6 servers in docker

Here is a setup how to run t6servers and iw4admin in docker nicely

Currently this repo is not recommend for production use. WIPx

## Setup

Requirements

- docker installed

### 1. Install game files and plutonium

Run the script in `scripts/install-server.sh` in the repository main directory.

After that you should see a new directory `servers`.
There a two other directors:

- `game`
- `plutonium`

In the `game` directory your multiplayer and zombie game files belongs.
I would recommend you use the files from [https://dl.axite.dev/T6-Server.zip](https://dl.axite.dev/T6-Server.zip).
Copy the content of `Server` in the archive into `game` directory.

Because plutonium is outdated in the archive, we will use the files from your client.
Copy the contents of your plutonium folder in `%localappdata%/Plutonium` folder and put them in the `plutonium` folder on server.

Now we're ready to add our first server

### 2. Add our first server

First copy one of the example cfgs from the `example-configs` directory.

- t6mp is Multiplayer
- t6zm is Zombie

In the cfg file it is important to set a rcon password for later and change following option:

```
g_log "logs\YOURSERVERNAME_games_mp.log"
```

please replace `YOURSERVERNAME` with a server name like as example server1. That name is also important for later.
Don't use spaces or some strange characters.

After that run the script `scripts/install-servers.sh`, also in the main repository directory, where your servers directory and this file is.

The script is self explanation enough.

You should now be able to connect to the server.

### 3. Setup IW4MAdmin

First run the script `scripts/install-admin.sh`.
After that run `scripts/setup-admin.sh`.

When you run the last script and waited a bit, you will see that the connection to the server wasnt successful.
When that happend, you have made everything right.

Open the following file with nano

```bash
nano admin/Configuration/IW4MAdminSettings.json
```

Nearly at the end of the file you will find a `Servers` section,
replace `ManualLogPath` path like so

```
"/storage/t6/logs/YOURSERVERNAME_games_mp.log" -> "/t6server-logs/YOURSERVERNAME_games_mp.log"
```

After that save and run:

```bash
docker start t6server_iw6admin
```

Now you should be able to visit iw6admin in your browser via `http://hostname:1624` with your server configured.
