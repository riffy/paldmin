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
3. Follow **strictly** [this](https://github.com/A1RM4X/HowTo-Palworld/tree/main) tutorial

**Note**: If you installed a firewall, add the Palworld Server Port to the allowed list

# Thanks

* [A1RM4X](https://github.com/A1RM4X) - For the initial tutorial of the linux palword server