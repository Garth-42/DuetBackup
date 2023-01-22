#!/bin/bash

# Setup instructions for this backup script:
# 1. Place this folder with the backup.sh and install.sh script on a folder on the Raspberry Pi connected to your Duet
# Open a terminal at that folder location
# Run chmod u+x install.sh in terminal to set permissions
# run this file to install the backup program, setting remote to the value you set up for your remote while setting up Rclone

Remote="backblaze:/PrinterConfigBackup/"

Source="/opt/dsf/sd/"
echo "$Source" >> "$PWD/$my_dir""Source.txt"
echo "$Remote" >> "$PWD/$my_dir""Remote.txt"
# Setup a cron job for backing up
{ crontab -l; echo "* * * * * cd $PWD/$my_dir && $PWD/$my_dir/backup.sh"; } | crontab -
chmod u+x "$PWD/$my_dir""backup.sh" # make backup script executable