# Usage

> [!NOTE]
> Some features or functionality are only accessible if the server is running AND [rcon](./install.md#rcon-installation) is installed and correctly configured.

## Broadcast Message

> [!NOTE]
> Requires install and configured [rcon](./install.md#rcon-installation)

Sends a broadcast message to the server in the chat. Whitespaces are automatically replaced with underscores (\_).


## World Settings

The World Settings page reads the `$SERVER_DIR/Config/LinuxServer/PalWorldSettings.ini` file and displays it in a manner for easier configuration.
It starts by reading the `DefaultPalWorldSettings.ini` and replacing all existing values with values from the `PalWorldSettings.ini`, if there are any.

If you want to add new fields to settings, just update the `DefaultPalWorldSettings.ini` in the server directory manually.

> [!IMPORTANT]
> Please note the following information about syntax when editing the World Settings:
> * NEVER use commas (,) or equalsigns (=) ANYWHERE. (no, not even in the server name)
> * Always use point (.) for decimals.
> * Use double quotes "" when they are already present (e.g. for text inputs).

## Config Files

The Config Files page allows for editing of all files that are placed inside `$SERVER_DIR/Config/LinuxServer/` (yes, event `PalWorldSettings.ini`) but with a plain editor.

## Active Player List
> [!NOTE]
> * [rcon](./install.md#rcon-installation) required
> * Server must be running

Displays all active players on the server with their:
* PlayerName
* PlayerUID
* SteamID

And allows for kicking / banning a player using the rcon client.

## Banned Player

Reads the `banlist.txt` and allows for removing / adding ban entries