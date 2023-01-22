# Application Overview
This source code is a backup utility for the files on an SBC-mode Duet3 controller. For a utility to backup files on Duet boards in standalone mode, see wilriker's excellent [RFM](https://github.com/wilriker/rfm).

## How does it work?
The backup.sh script will perform a backup of the /sys, /macros, and /filaments folders, checking for new changes to files every minute
- The backup script uses [rclone](https://rclone.org/) to perform the backup to a destination server
- The script is scheduled using a cron job on the RPI to check if it needs to perform a backup every minute. If files haven't changed, there is no action.

# Link to Video Setup Instructions
TODO

# Setup Instructions

## Definitions
Remote - the remote file system that is the backup or source location for your files

Source - the directory that you are copying to the destination server to back files up

Destination - the remote location that is where you are copying files to (generally a PC on the LAN, or a cloud service)

RPI - raspberry pi

SBC - single board computer

SBC-mode: duet board configuration wherein an SBC is connected via SPI to the board

Standalone-mode - board setup wherein the duet board doesn't have an SBC attached via SPI

For more information on SBC-mode vs standalone-mode, see the Duet3D docs, [here](https://docs.duet3d.com/User_manual/Machine_configuration/SBC_setup)

# Backing up Standalone-Mode Duet Boards
- [RFM](https://github.com/wilriker/rfm), a command-line tool by wilriker is a great tool for doing this. Accessing files via FTP using rclone on a PC on the LAN proved to be an issue, and this is simple to setup and use.
- In my testing RFM has connection issues when trying to use it with an SBC-enabled duet board.
- Since it is a command line tool you will either compile it from source, or download a pre-compiled binary
## To install and use RFM
1. Once you have downloaded the tool and extracted it from the zip-file, put it in a folder location of your choosing
2. Open a command prompt in that location and type in: rfm -help
   - You should get a message from the tool with the available commands.
3. If the tool responded without an error, you can use this tool in a bash file to perform regular backups.
   - [This forum post](https://forum.duet3d.com/topic/10880/rfm-reprapfirmware-filemanager-duetbackup-successor/62) has good content on the basics of using the tool, as well as some example scripts by community members for periodic backups.

# Backing up SBC-Mode Duet Boards
1. Install Rclone on the RPI connected to your duet board in SBC-mode
   [Rclone Install Docs](https://rclone.org/install/)
   - Install rclone on the SBC connected to the duet3
2. Using Rclone's [interactive config command](https://rclone.org/commands/rclone_config/), setup the source and remote directories so that rclone can access them to perform a backup
- Set up the source
   - The source location is on the local disk, at /opt/dsf/sd/. No action is needed to set this up.
- Set up the destination
     - You can then setup the destination remote using whichever backend you desire. In this example, I set it up with backblaze as it was a fast and easy setup. The docs for this are [here](https://help.backblaze.com/hc/en-us/articles/1260804565710-Quickstart-Guide-for-Rclone-and-B2-Cloud-Storage).
     - Check that it is working by using the rclone ls command pointing to the destination you just set up
     - Syntax:
     - a setup remote uses a colon at the end of its name to refer to it in a call.
     - For backblaze specifically, you also need to add the name of the bucket you setup to point to the root directory in that bucket.
     - For example, for a backblaze remote called "backblaze" and a bucket called "PrinterConfigBackup", you would use the following command to look at the files in the root directory (recursively): rclone ls backblaze:/PrinterConfigBackup
3. Install this (DuetBackup) folder with the backup.sh script in it to a directory of your choice. Here I chose the /home/pi/ directory to create a folder that contains this script. Note down the path to the backup.sh file.
   - You can install this script to anywhere, as long as you edit the path to the shell file in the backupDuetCron file with the noted location
   - Make it executable using: chmod u+x backup.sh in the directory that contains the file
   - Set owner of the file using: chown myusername myscript.sh in the directory that contains the file
4. Edit the crontab
- run the command crontab -e in the terminal
- If this is the first time you are editing the crontab, it will ask you to choose an editor. I think nano is the easist to use for beginners.
Copy and paste the following line into the crontab file (changing the path to the script as needed):
```
0 * * * * /home/pi/DuetBackup/backup.sh # run this script every hour for changes to files
```
- Adding this line to your crontab file will make it execute every minute, looking for changes, and uploading them to the server if they exist.
1. Enjoy automatic backups!
- Backblaze's web interface takes a couple minutes to update. Use the rclone ls command pointing to the files in the destination directory if you want to check that they uploaded after running a command.

# Notes
- You can test if rclone has the source or remote directory configured correcty by running "rclone lsd insert_your_remote_name_here:" and it should list the current directories in that folder. Alternatively you can run the ls command to list the files in the folder.
- You can also set cron to email you when a job completes with addinga MAILTO line, but additional configuration is required.

# Code Documentation
## Exit Codes
- 0 = source file and hash in sync, not synced to remote
- 1 = source file and hash not in sync, synced to remote
- 2 = getting error when sending a command to the remote, check remote's connection and config.

# Additional Resources
- https://phoenixnap.com/kb/set-up-cron-job-linux
- https://devconnected.com/cron-jobs-and-crontab-on-linux-explained/
- https://crontab.guru/every-5-minutes