#To enter WSL from Powershell
bash

#Convert a docker run to a rough docker compose
#https://www.composerize.com/

$ sudo mkdir /mnt/share
$ sudo mount -t drvfs '\\server\share' /mnt/share
$ sudo umount /mnt/share

#Delete file
sudo rm filename

#Delete Folder
sudo rm -rf dir1