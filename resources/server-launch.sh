#!/bin/bash

PLUTONIUM_DIRECTORY=/t6server/plutonium
SERVER_DIRECTORY=/t6server/server
IW4ADMIN_DIRECTORY=/t6server/admin
DOWNLOAD_DIRECTORY=/t6server/downloaded_files
UPDATER_DIRECTORY=/t6server/updater
STATUS_DIRECTORY=/t6server/status

# Create Directories (redudant as they are created in the Dockerfile)
mkdir -p $PLUTONIUM_DIRECTORY \
         $IW4ADMIN_DIRECTORY \
         $DOWNLOAD_DIRECTORY \
         $UPDATER_DIRECTORY \
         $SERVER_DIRECTORY \
         $STATUS_DIRECTORY

################################################################################
#                          Server Files Provisioning                           #
################################################################################

## Download Server Files 
echo "Checking plutonium server files, please wait..."

if [ -e $STATUS_DIRECTORY/.sv_files_downloaded ]; then
    echo "Server files already downloaded!"
else
    echo "Downloading server files..."
    wget https://vault.our-space.xyz/ATOM/T6-Server.zip -O $DOWNLOAD_DIRECTORY/T6-Server.zip -q --show-progress
    # Check the exit status
    if [ $? -eq 0 ]; then
        echo "Server files downloaded successfully!"
        touch $STATUS_DIRECTORY/.sv_files_downloaded
    else
        echo "Command failed"
        exit 1
    fi
fi

## Extract Server Files
if [ -e $STATUS_DIRECTORY/.sv_files_extracted ]; then
    echo "Server files already extracted!"
else
    echo "Extracting server files..."
    unzip -o $DOWNLOAD_DIRECTORY/T6-Server.zip -d $DOWNLOAD_DIRECTORY/
    # Check the exit status
    if [ $? -eq 0 ]; then
        echo "Server files extracted successfully!"
        touch $STATUS_DIRECTORY/.sv_files_extracted
    else
        echo "Command failed"
        exit 1
    fi
fi

# Remove the downloaded Zip file [WIP]
# rm $DOWNLOAD_DIRECTORY/T6-Server.zip

# Copy Server Files
if [ -e $STATUS_DIRECTORY/.sv_files_copied ]; then
    echo "Server files already copied!"
else
    echo "Copying server files..."

    # Copy the files to the destination directory

    echo "Copying /Plutonium files..."
    cp -r $DOWNLOAD_DIRECTORY/T6-Server/Plutonium/* $PLUTONIUM_DIRECTORY
    # Check the exit status
    if [ $? -eq 0 ]; then
        echo "Server files from /Plutonium copied successfully!"
    else
        echo "Command failed"
        exit 1
    fi
    
    echo "Copying /Server files..."
    cp -r $DOWNLOAD_DIRECTORY/T6-Server/Server/* $SERVER_DIRECTORY
    # Check the exit status
    if [ $? -eq 0 ]; then
        echo "Server files from /Server copied successfully!"
    else
        echo "Command failed"
        exit 1
    fi

    echo "All server files copied successfully!"
    touch $STATUS_DIRECTORY/.sv_files_copied
fi

# Remove the downloaded Server files [WIP]
# rm -rf $DOWNLOAD_DIRECTORY/T6-Server


################################################################################
#                             Updater Provisioning                             #
################################################################################

echo "Running updater..."
# Use checkupdater.sh to download the latest updater and run it
bash /t6server/check_updater.sh
echo "Updater finished!"


################################################################################
#                   Server Configuration Files Provisioning                    #
################################################################################

# Download the Server Configuration Files
if [ -e $STATUS_DIRECTORY/.sv_cfg_files_downloaded ]; then
    echo "Server config files already downloaded!"
else
    echo "Downloading server config files..."
    wget https://github.com/xerxes-at/T6ServerConfigs/archive/master.zip -O $DOWNLOAD_DIRECTORY/server_configs.zip -q --show-progress
    # Check the exit status
    if [ $? -eq 0 ]; then
        echo "Server files downloaded successfully!"
        touch $STATUS_DIRECTORY/.sv_cfg_files_downloaded
    else
        echo "Command failed"
        exit 1
    fi
fi

# Extract the Server Config Files
if [ -e $STATUS_DIRECTORY/.sv_cfg_files_extracted ]; then
    echo "Server config files already extracted!"
else
    echo "Extracting server config files..."
    unzip -o $DOWNLOAD_DIRECTORY/server_configs.zip -d $DOWNLOAD_DIRECTORY/server_configs/
    # Check the exit status
    if [ $? -eq 0 ]; then
        echo "Server files extracted successfully!"
        touch $STATUS_DIRECTORY/.sv_cfg_files_extracted
    else
        echo "Command failed"
        exit 1
    fi
fi

# Copy the Server Config Files
if [ -e $STATUS_DIRECTORY/.sv_cfg_files_copied ]; then
    echo "Server config files already copied!"
else
    echo "Copying server config files..."

    # Locate config files
    t6_path=$(find "$DOWNLOAD_DIRECTORY/server_configs/" -type d -name "t6")
    mp_cfg="$t6_path/dedicated.cfg"
    zm_cfg="$t6_path/dedicated_zm.cfg"
    gs_path="$t6_path/gamesettings/"

    # Copy Multiplayer config file
    if [ -z "$mp_cfg" ]; then
        echo "File not found: '$mp_cfg'"
    else
        # Copy the file to the destination directory
        cp "$mp_cfg" "/t6server/server/Multiplayer/main/dedicated.cfg"
        echo "File '$mp_cfg' found and copied to: '/t6server/server/Multiplayer/main/dedicated.cfg'"
    fi

    # Copy Zombie config file
    if [ -z "$zm_cfg" ]; then
        echo "File not found: '$zm_cfg'"
    else
        # Copy the file to the destination directory
        cp "$zm_cfg" "/t6server/server/Zombie/main/dedicated_zm.cfg"
        echo "File '$zm_cfg' found and copied to: '/t6server/server/Zombie/main/dedicated_zm.cfg'"
    fi

    # Copy Game Settings files
    if [ -z "$gs_path" ]; then
        echo "Directory not found: '$gs_path'"
    else
        # Copy the file to the destination directory
        cp -r "$gs_path" "/t6server/plutonium/storage/t6/gamesettings/"
        echo "Directory '$gs_path' found and copied to: '/t6server/plutonium/storage/t6/'"
    fi

    touch $STATUS_DIRECTORY/.sv_cfg_files_copied
fi


################################################################################
#                             Wine Provisioning                                #
################################################################################

# Output Current Wine Version
echo "Current Wine Version:"
wine --version

# rm -rf /root/.wine
# If .wine directory doesn't exist, copy backup
if [ ! -d /root/.wine ];  then
    echo "Wineprefix not found, initialiizing wine" && winecfg && /usr/sbin/winetricks
    echo "Configured Succesfully"
else
    winecfg
fi;

# echo "before setting virtual server"
# # Setup Virtual Screen 
# Xvfb :0 -screen 0 1024x768x16 -nolisten unix
# export DISPLAY=:0.0
# export WINEDEBUG=fixme-all
# echo "after setting virtual server"


################################################################################
#                             Server Provisioning                              #
################################################################################

MODE_PATH=""
MODE=""
CFG=""

# Define Server Mode
# Default Mode is Zombie ('t6mp' -> Multiplayer | 't6zm' -> Zombie)
if [ "$SERVER_MODE" = "Multiplayer" ]; then
    echo "Server mode is Multiplayer!"
    MODE_PATH="/t6server/server/Multiplayer"
    MODE="t6mp"
    CFG="dedicated.cfg"
    CFG_PATH="$MODE_PATH/main/$CFG"
    ln -sf /t6server/server/zone /t6server/server/Multiplayer/zone
else
    if [ "$SERVER_MODE" != "Zombie" ]; then
        echo "Invalid Server Mode! Defaulting to Zombie"
    else
        echo "Server mode is Zombie!"
    fi
    MODE="t6zm"
    MODE_PATH="/t6server/server/Zombie"
    CFG="dedicated_zm.cfg"
    CFG_PATH="$MODE_PATH/main/$CFG"
    ln -sf /t6server/server/zone /t6server/server/Zombie/zone
fi

# Define if server will run in LAN mode
if [ "$LAN_MODE" = "true" ]; then
    LAN="-lan"
else
    LAN=""
fi

# Apply specific configs from environment variables to the dedicated configuration file [WIP]

# Set max clients of the server
if [ ! -z "$SERVER_MAX_CLIENTS" ]&& [ ! -e $STATUS_DIRECTORY/.server_config_file_max_clients_modified ]; then
    echo "Setting server max clients to: '$SERVER_MAX_CLIENTS'"
    sed -i "s/\(sv_maxclients \)[0-9]/\1$SERVER_MAX_CLIENTS/" "$CFG_PATH"
    touch $STATUS_DIRECTORY/.server_config_file_max_clients_modified
fi

# Set server RCON password
if [ ! -z "$SERVER_RCON_PASSWORD" ] && [ ! -e $STATUS_DIRECTORY/.server_config_file_rcon_password_modified ]; then
    echo "Setting server rcon password to: '$SERVER_RCON_PASSWORD'"
    sed -i "s/\(rcon_password \)\"[^\"]*\"/\1\"$SERVER_RCON_PASSWORD\"/" "$CFG_PATH"
    touch $STATUS_DIRECTORY/.server_config_file_rcon_password_modified
fi

# Set server map rotation
if [ ! -z "$SERVER_MAP_ROTATION" ] && [ ! -e $STATUS_DIRECTORY/.server_config_file_zm_map_rotation_modified ]; then
    echo "Setting server rotation to: '$SERVER_MAP_ROTATION'"
    sed -i "/\/\/Classic\/TranZit Maps rotation/ {
        n; s/^\(.*\)$/\/\/\1/; n; a\\
        $SERVER_MAP_ROTATION
    }" "$CFG_PATH"
    touch $STATUS_DIRECTORY/.server_config_file_zm_map_rotation_modified
fi

# Set server password
if [ ! -z "$SERVER_PASSWORD" ] && [ ! -e $STATUS_DIRECTORY/.server_config_file_password_modified ]; then
    echo "Setting server password to: '$SERVER_PASSWORD'"
    sed -i "s/\(g_password \)\"[^\"]*\"/\1\"$SERVER_PASSWORD\"/" "$CFG_PATH"
    touch $STATUS_DIRECTORY/.server_config_file_password_modified
fi


################################################################################
#                             IW4Admin Provisioning                            #
################################################################################

# Define IW4Admin Logs Directory
LOGS_DIR="$PLUTONIUM_DIRECTORY/storage/t6/logs/"

echo "Checking IW4Admin files..."

# Download IW4Admin
if [ -e $STATUS_DIRECTORY/.admin_files_downloaded ]; then
    echo "IW4Admin files already downloaded!"
else
    echo "Downloading IW4Admin files..."
    curl -s https://api.github.com/repos/RaidMax/IW4M-Admin/releases \
        | grep -m 1 "browser_download_url" \
        | cut -d : -f 2,3 \
        | tr -d \" \
        | wget -qi - -P $DOWNLOAD_DIRECTORY
    # Check the exit status
    if [ $? -eq 0 ]; then
        echo "IW4Admin files downloaded successfully!"
        touch $STATUS_DIRECTORY/.admin_files_downloaded
    else
        echo "Command failed"
        exit 1
    fi
fi

# Extract IW4Admin
if [ -e $STATUS_DIRECTORY/.admin_files_extracted ]; then
    echo "IW4Admin files already extracted!"
else
    echo "Extracting IW4Admin files..."
    unzip -o $DOWNLOAD_DIRECTORY/IW4MAdmin-*.zip -d $IW4ADMIN_DIRECTORY
    # Check the exit status
    if [ $? -eq 0 ]; then
        echo "IW4Admin files extracted successfully!"
        touch $STATUS_DIRECTORY/.admin_files_extracted
    else
        echo "Command failed"
        exit 1
    fi
fi

# Give execute permissions to IW4Admin
chmod +x $IW4ADMIN_DIRECTORY/StartIW4MAdmin.sh

################################################################################
#                             Server Launching                                #
################################################################################

# Remove deleted screen sessions
screen -wipe

# Launch Plutonium BO2 Server
if [ -e $PLUTONIUM_DIRECTORY/bin/plutonium-bootstrapper-win32.exe ]; then
    echo "Plutonium files exist!"
    echo "Starting server..."
    # Replace Startup Variables
    STARTUP="$PLUTONIUM_DIRECTORY/bin/plutonium-bootstrapper-win32.exe $MODE $MODE_PATH -dedicated $LAN +start_map_rotate +set key $SERVER_KEY +set net_port $SERVER_PORT +set sv_config $CFG"
    echo "Running ${STARTUP}"

    # Run the Server (detached on a screen named plutonium-server)
    # ( cd $PLUTONIUM_DIRECTORY && pkill Xvfb || true && exec xvfb-run wine ${STARTUP} )
    ( cd $PLUTONIUM_DIRECTORY && pkill Xvfb || true && screen -S plutonium-server -dm bash -c "exec xvfb-run wine ${STARTUP}" )
    # ( cd $PLUTONIUM_DIRECTORY && pkill Xvfb || true && screen -S plutonium-server -dm bash -c "exec xvfb-run wine /t6server/plutonium/bin/plutonium-bootstrapper-win32.exe t6zm /t6server/server/Zombie -dedicated -lan +start_map_rotate +set key YOUR_KEY_HERE +set net_port 4976 +set sv_config dedicated_zm.cfg" )
else
    echo "Missing Plutonium files!! Add them manually!"
    exit 1
fi

# Launch IW4Admin
if [ -e $IW4ADMIN_DIRECTORY/StartIW4MAdmin.sh ]; then
    echo "IW4Admin files exist!"
    echo "Starting IW4Admin..."
    # Replace Startup Variables
    echo "Running $IW4ADMIN_DIRECTORY/StartIW4MAdmin.sh"

    # Run IW4Admin (detached on a screen named admin-panel)
    # ( cd $IW4ADMIN_DIRECTORY && $IW4ADMIN_DIRECTORY/StartIW4MAdmin.sh )
    ( cd $IW4ADMIN_DIRECTORY && screen -S admin-panel -dm bash -c "$IW4ADMIN_DIRECTORY/StartIW4MAdmin.sh" )
else
    echo "Missing IW4Admin files!! Add them manually!"
    exit 1
fi

# Keep the container alive
tail -f /dev/null
