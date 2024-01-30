# Paldmin
A [Webmin](https://webmin.com/) module for easy configure and control of a Palworld Server.

This module is still big **Work In Progress**.

## Current Features
* Starting, Stopping, Restarting Server via daemon
* Basic Info

![Screenshot of Paldmin](./docs/images/readme_01.PNG)

## Upcoming Features
* Set Backup Plan
* Set Schedule Restart
* Edit PalWorldSettings.ini (or any other .ini file)
* Connect RCON / Base Commands
	* Broadcast
	* Playerlist
	* Kick / Ban Player
	* ...
* RCON Specific commands
* Import & Convert savegames

# Installation

This module was developed using Debian 12 (bookworm). Please note that other OS may not work as expected (open an issue).

1. Get a Debian Server
2. Install [Webmin](https://www.howtoforge.com/how-to-install-webmin-on-debian-12/)
3. Follow **strictly** [this](https://github.com/A1RM4X/HowTo-Palworld/tree/main) tutorial to install Palworld Server on Linux
4. Install the Module
	- Go to [releases](https://github.com/riffy/paldmin/releases) and copy the link to the source code (.tar.gz)
	- Go to your webmin: `Webmin -> Webmin Configuration -> Webmin Modules -> Install` and choose `From HTTP or FTP URL`
	- Paste the link and click `Install Module`

![Installation Step 1](./docs/images/readme_02.PNG)

You should now see `Palworld Admin` under the `Servers` category.

**Note**: If you installed a firewall, add the Palworld Server Port to the allowed list

# Usage

This module is heavily based on the tutorial provided by **A1RM4X** and assumes that a daemon `palworld.service` exists, but the [Module Configuration](#moduleconfig) allows to control or fine tune the environment.

## <a name="moduleconfig"></a>Module Configuration



# FAQs

# Thanks

* [A1RM4X](https://github.com/A1RM4X) - For the initial tutorial of the linux palword server