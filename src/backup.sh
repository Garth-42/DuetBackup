#!/bin/bash

# This is a bash file that backs up the filaments, macros, and sys folder to a remote server using rclone.
# This program is setup through the install.sh script
# It is recommended to keep the eventlog in the gcodes directory so it doesn't continue to keep being backed up
# Two locations are created on the remote, a Latest and Bak folder. The Latest folder keeps the latest version of
# all the files. If you want to access previous versions, go into the Bak folder.

ScriptPath=`$PWD/$my_dir`
Remote=`cat $PWD/$my_dir/Remote.txt`
Source=`cat $PWD/$my_dir/Source.txt`

# This script works by creating a hash file that compares the source directories to. If the directory changes, it will no longer pass a check against the hash file.
# Only when the hash file doesn't match the directory is the remote synced to. This cuts down on API calls to the remote directory.

HashFilaments="$ScriptPath""lastHashFilaments.txt"
HashMacros="$ScriptPath""lastHashMacros.txt"
HashSys="$ScriptPath""lastHashSys.txt"

# echo `date` >> "$ScriptPath""log.txt"

function updateHashFiles {
    rclone hashsum md5 "$Source""sys" --output-file "$HashSys"
    rclone hashsum md5 "$Source""macros" --output-file "$HashMacros"
    rclone hashsum md5 "$Source""filaments" --output-file "$HashFilaments"    
}

function syncToRemote {
    rclone sync "$Source""sys" "$Remote""Latest/sys" --suffix=`date +%Y-%m-%d_%H-%M-%S` --suffix-keep-extension --backup-dir="$Remote""Bak/sys" # Backup the sys folder
    rclone sync "$Source""macros" "$Remote""Latest/macros" --suffix=`date +%Y-%m-%d_%H-%M-%S` --suffix-keep-extension --backup-dir="$Remote""Bak/macros" # Backup the macros folder
    rclone sync "$Source""filaments" "$Remote""Latest/filaments" --suffix=`date +%Y-%m-%d_%H-%M-%S` --suffix-keep-extension --backup-dir="$Remote""Bak/filaments" # Backup the filaments folder
    
}

# check if a checksum file exists:
if test -f "$HashFilaments" && test -f "$HashMacros" && test -f "$HashSys" ; then
    # echo "Hash files exist." >> "$ScriptPath""log.txt"
    true
else # if no hash exists, create one.
    # echo "Hashfiles not found. Syncing with remote and creating hash files." >> "$ScriptPath""log.txt"
    syncToRemote
    updateHashFiles
fi

# check if connection is working... if it isn't, it forces a deletion of hash files in order to force a sync to the server
# this will use up more API calls, but will make sure that the remote is always in sync, in case connection is intermittent
if rclone ls "$Remote""Latest/sys" ; then
    # error code == 0, connection is okay.
    # echo "Connection Okay" >> "$ScriptPath""log.txt"
else
    rm "$HashFilaments"
    rm "$HashMacros"
    rm "$HashSys"
    exit 2
fi

# check if there have been any changes to the source directory by checking against the hash file
if rclone checksum md5 "$HashSys" "$Source""sys" && rclone checksum md5 "$HashMacros" "$Source""macros" && rclone checksum md5 "$HashFilaments" "$Source""filaments"; then # If error code is 0
    # echo "Source file and previous hash file are the same. Not syncing to the destination" >> "$ScriptPath""log.txt"
    exit 0
else # if error code isn't zero, then a file has changed (or any other error that results in an error code)
    # echo "Source files changed. Syncing to destination and creating another hash file" >> "$ScriptPath""log.txt"
    syncToRemote
    updateHashFiles
    exit 1
fi