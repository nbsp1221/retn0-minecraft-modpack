#!/bin/bash

mkdir ./1.16.5-server
mkdir ./1.16.5-server/config
mkdir ./1.16.5-server/mods
cp ./1.16.5/forge-1.16.5-36.2.34-installer.jar ./1.16.5/run.sh ./1.16.5-server/
cp ./1.16.5/mods/server/*.jar ./1.16.5/mods/universal/*.jar ./1.16.5-server/mods/
cp ./1.16.5/config/server.properties ./1.16.5-server/
cd ./1.16.5-server
java -jar forge-1.16.5-36.2.34-installer.jar --installServer
