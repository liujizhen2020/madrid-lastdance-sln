#!/bin/bash

./bump-version.sh

test -d packages && rm -fr packages/*
make clean package


APT=../apt
if [ -d $APT ]; then 
	echo "... Refreshing APT Repo ..."
	rm -fr $APT/com.yourcompany.certextractor_*
	cp packages/* $APT/
	cd $APT && make gen
	echo "... Done ..."
fi


