#!/bin/bash

env GOOS=windows GOARCH=amd64 go build -o proxy-fetcher.exe .