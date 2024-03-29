# Paldmin
A [Webmin](https://webmin.com/) module for easy configure and control of a Palworld Server.

### Current Features
* Starting, Stopping, Restarting Server via daemon
* Basic Info
* Edit PalWorldSettings.ini (or any other .ini file)
* Full RCON Support (Kick / Ban Player, Broadcast, List Player, ...)
	* With Terminal
* Restart Scheduler with automated Announcements

![Screenshot of Paldmin](./docs/images/readme_01.PNG)

### Upcoming Features
* Extend OS compatibility
* Wine Support for [Modded Linux Server](https://github.com/CuteNatalie/Palworld-Modded-Server-Linux)
* Discord Bot Integration 
* Restart Scheduler with RAM Usage
* Set Backup Plan
* List Player
	* List / Download .sav File (hex GUID)
* Savegame / SaveFile Editor
	* Download Players (as .sav / as .json)
	* Download World (as .sa / as .json)
	* Upload & Overwrite
* Logs
	* Player login/logout
* Javascript Module
	* A bun wrapper to allow custom javascript to run and listen for events (player joined, player left, etc.) allowing for incode access to rcon  

## Installation

Please follow the [installation guide](./docs/install.md)

## Usage

Please follow the [usage guide](./docs/usage.md)

## Update Module

Please follow the [update guide](./docs/update.md)

## FAQs

(TBD)

## Thanks

* [A1RM4X](https://github.com/A1RM4X) - For the initial tutorial of the linux palword server
