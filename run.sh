#!/bin/bash

zip -r modpack.zip overrides/ manifest.json modlist.html
docker compose up -d
