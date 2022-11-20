#!/bin/bash

mkdir -p ./1.16.5-server/mods
cp ./1.16.5/forge-1.16.5-36.2.34-installer.jar ./1.16.5/run.sh ./1.16.5-server/
cp ./1.16.5/mods/server/* ./1.16.5/mods/universal/* ./1.16.5-server/mods/
cd ./1.16.5-server
java -jar forge-1.16.5-36.2.34-installer.jar --installServer
