#!/bin/bash

# Setup instructions for backing up your files:
# Copy/Paste this file to a folder on the Raspberry Pi connected to your Duet
# Run chmod u+x backup.sh in terminal to set permissions
# Create a conjob script

# The below commands will sync the folders from the RPI to the setup remote (in this case a backblaze server).
# A /Bak/ directory will house previous versions of the files. These directories won't delete old files, and will continue to accumulate.
# Backblaze has file versioning and deletion functionality, and you can also run the sync command such that it only keeps the most recent version.
rclone sync /opt/dsf/sd/sys/ backblaze:/PrinterConfigBackup/Latest/sys --suffix=`date +%Y-%m-%d_%H-%M-%S` --suffix-keep-extension --backup-dir=backblaze:/PrinterConfigBackup/Bak/sys # Backup the sys folder
rclone sync /opt/dsf/sd/macros/ backblaze:/PrinterConfigBackup/Latest/macros --suffix=`date +%Y-%m-%d_%H-%M-%S` --suffix-keep-extension --backup-dir=backblaze:/PrinterConfigBackup/Bak/macros # Backup the macros folder
rclone sync /opt/dsf/sd/filaments/ backblaze:/PrinterConfigBackup/Latest/filaments --suffix=`date +%Y-%m-%d_%H-%M-%S` --suffix-keep-extension --backup-dir=backblaze:/PrinterConfigBackup/Bak/filaments # Backup the macros folder

# Additional information:
# rclone source directory for files that you edit via Duet Web Control: = /opt/dsf/sd/
# setup a cronjob in order to schedule this script
# This directory contains the gcodes, filament, macros, sys, and www folders that you may want to backup.
# The rclone destination for sending files is setup using the rclone config command on the command line.
# In this example we are backing up to a backblaze server remote destination that is setup using the rclone config command, called "backblaze:"
# rclone documentation: https://rclone.org/docs/
# Backblaze setup guide: https://help.backblaze.com/hc/en-us/articles/1260804565710-Quickstart-Guide-for-Rclone-and-B2-Cloud-Storage