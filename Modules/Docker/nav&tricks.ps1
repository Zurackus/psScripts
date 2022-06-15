#To enter WSL from Powershell
bash

#Convert a docker run to a rough docker compose
#https://www.composerize.com/

#Mounting a thing in fstab
#https://www.youtube.com/watch?v=A7xH74o6kY0
#Create a directory
$ sudo mkdir /mnt/share
#Mount a share to a specific directory - Temporary
$ sudo mount -t drvfs '\\server\share' /mnt/share
#Auto-remount a share on reboot
sudo nano /etc/fstab #file to be edited
    #'crtl+O' (Save), 'Enter' (Confirm), and then exit file with 'ctrl+X'
/dev/sdb1 /mnt/v ext4 defaults 0 1
    or
'\\server\share' /mnt/share drvfs defaults 0 0

#Unmount a share from a directory
$ sudo umount /mnt/share

#Delete file
sudo rm filename

#Delete Folder
sudo rm -rf dir1

sudo mkdir /mnt/v
sudo mount -t drvfs V: /mnt/v


0 - Not really used anylonger
1 - File system check needed
	-could just be 0

/dev/sdb1 /mnt/v ext4 defaults 0 0
