#!/bin/bash
EXEC_USER=$USER
[[ -d /home/$EXEC_USER/Desktop/BuildServer ]] || mkdir /home/$EXEC_USER/Desktop/BuildServer
[[ -d /home/$EXEC_USER/Desktop/BuildServer/Automation ]] || mkdir /home/$EXEC_USER/Desktop/BuildServer/Automation
[[ -d /home/$EXEC_USER/Desktop/BuildServer/Release ]] || mkdir /home/$EXEC_USER/Desktop/BuildServer/Release

sudo mount.cifs -o vers=1.0 //192.168.128.6/Automation /home/$EXEC_USER/Desktop/BuildServer/Automation
sudo mount.cifs -o vers=1.0 //192.168.128.6/Release /home/$EXEC_USER/Desktop/BuildServer/Release
