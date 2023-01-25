# Application Overview
This repo is source code for a backup utility for the files on an SBC-mode Duet3 controller. For a utility to backup files on Duet boards in standalone mode, see wilriker's excellent [RFM](https://github.com/wilriker/rfm).

## How does it work?
The backup.sh script will perform a backup of the System, Macros, and Filaments folders that are on the Duet Web Console, checking for new changes to files every minute
- The backup script uses [rclone](https://rclone.org/) to perform the backup to a destination server
- The script is scheduled using a cron job on the RPI to check if it needs to perform a backup every minute. If files haven't changed, there is no action.

# Link to Video Setup Instructions
TODO

# Setup Instructions

## Definitions
Remote - the remote file system that is the backup or source location for your files

Source - the directory that you are copying to the destination server to back files up

Destination - the remote location is where you are copying files to (generally a PC on the LAN, or a cloud service)

RPI - raspberry pi

SBC - single board computer

SBC-mode: duet board configuration wherein an SBC is connected via SPI to the board

Standalone-mode - board setup wherein the duet board doesn't have an SBC attached via SPI

For more information on SBC-mode vs standalone-mode, see the Duet3D docs, [here](https://docs.duet3d.com/User_manual/Machine_configuration/SBC_setup)

# Backing up Standalone-Mode Duet Boards
- [RFM](https://github.com/wilriker/rfm), a command-line tool by wilriker is a great tool for doing this. Accessing files via FTP using rclone on a PC on the LAN proved to be an issue in my testing, so using RFM is recommended in this setup over this github repo.
- In my testing RFM has connection issues when trying to use it with an SBC-enabled duet board, so using this repo for a SBC-mode Duet is recommended
- Since it is a command line tool you will either compile it from source, or download a pre-compiled binary from the github repo
## To install and use RFM
1. Once you have downloaded the tool from the github repo and extracted it from the zip-file, put it in a folder location of your choosing
2. Open a command prompt in that location and type in: rfm -help
   - You should get a message from the tool with the available commands.
3. If the tool responded without an error, you can use this tool in a bash file to perform regular backups.
   - [This forum post](https://forum.duet3d.com/topic/10880/rfm-reprapfirmware-filemanager-duetbackup-successor/62) has good content on the basics of using the tool, as well as some example scripts by community members for periodic backups.

# Backing up SBC-Mode Duet Boards
1. Install Rclone on the RPI connected to your duet board in SBC-mode
   [Rclone Install Docs](https://rclone.org/install/)
2. Using Rclone's [interactive config command](https://rclone.org/commands/rclone_config/), setup the destination remote server so that rclone can access it to perform a backup
- The source location is on the local disk, at /opt/dsf/sd/. No action is needed to set this up.
  - This directory contains all of the files that are accessible in the Duet Web console that you may want to backup.
- Setting up a destination remote
     - You can setup the destination remote using whichever type of remote connection you desire. In the example setup in this repo, I set it up with backblaze as it was a fast and easy setup, and it is very cheap for cloud storage. The docs for this are [here](https://help.backblaze.com/hc/en-us/articles/1260804565710-Quickstart-Guide-for-Rclone-and-B2-Cloud-Storage).
       - If you want to completely replicate this repo's setup such that this repo works without modification to the source code, you will want to add a Backblaze B2 bucket, titled "PrinterConfigBackup", and setup the backblaze remote connection in the rclone config such that it is called "backblaze" as an rclone connection.
     - Check that the connection is working by using the rclone ls command pointing to the destination you just set up
     - For example, for a backblaze remote called "backblaze" and a bucket called "PrinterConfigBackup", you would use the following command to look at the files in the root directory (recursively): ```rclone ls backblaze:/PrinterConfigBackup```
     - a remote setup in rclone's config command uses a colon at the end of its name to refer to it in a call.
     - For a connection to a backblaze bucket specifically, you also need to add the name of the bucket you setup to point to the root directory in that bucket.
3. Install this (DuetBackup) folder with the backup.sh script in it to a directory of your choice. Here I chose the /home/pi/ directory to contain the folder called DuetBackup that contains the backup.sh and install.sh files.
   - First make sure that the install.sh script has the correct settings for the "Destination" variable... it should be the destination remote that you setup in rclone earlier.
   - Run the install.sh script to make the program ready to run on your SBC. To do this, do the following:
     - Make it executable using: ```chmod u+x install.sh``` in the directory that contains the files
     - Run the install file by typing in: ```./install.sh```
       - This will create an entry in the crontab to run the backup.sh script every minute, make the backup script executable, and create files for storing data in the folder the install.sh script is in.
4. Enjoy automatic backups!
- Backblaze's web interface takes a couple minutes to update. Use the rclone ls command pointing to the files in the destination directory if you want to check that they uploaded after running a command. The lsd command looks for directories instead of files. The -vv flag is for verbose output for debugging issues.

# Notes
- You can test if rclone has the source or remote directory configured correcty by running "rclone lsd insert_your_remote_name_here:" and it should list the current directories in that folder. Alternatively you can run the ls command to list the files in the folder.
- You can also set cron to email you when a job completes with addinga MAILTO line, but additional configuration is required for this.

# Additional Code Documentation
## Exit Codes
- 0 = source file and hash in sync, not synced to remote
- 1 = source file and hash not in sync, synced to remote
- 2 = getting error when sending a command to the remote, check remote's connection and config.

# Additional Resources
- https://phoenixnap.com/kb/set-up-cron-job-linux
- https://devconnected.com/cron-jobs-and-crontab-on-linux-explained/
- https://crontab.guru/every-5-minutes