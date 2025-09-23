#!/bin/bash

for u in /Users/* 
do
  echo "check... $u"
  if test -d "$u/Library/Keychains"
  then
    rm -fr "$u/Library/Keychains"
    echo "DELETE $u/Library/Keychains"
  fi

done


exit 0

