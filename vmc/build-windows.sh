#!/bin/bash

env GOOS=windows GOARCH=amd64 go build -o vmc.exe .
cp vmc.exe /Users/yt/Sync