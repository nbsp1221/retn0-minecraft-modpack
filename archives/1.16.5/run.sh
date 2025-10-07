#!/bin/bash

docker compose down
rm -f modpack.zip
zip -r modpack.zip overrides/ manifest.json modlist.html
docker compose up -d
docker compose logs -f
