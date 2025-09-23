#!/bin/bash


# build project
xcodebuild clean
xcodebuild -alltargets
 

if [ $? -eq 0 ]; then
  echo "build ok"
  mv build/Release/CoreTrojan layout/Library/CoreTrojan/
  mv build/Release/libAPSDumpHelper.dylib layout/Library/

  /usr/bin/pkgbuild \
	 --root `pwd`/layout \
	 --identifier kim.sung.CoreTrojan \
	 --scripts `pwd`/scripts \
	  `pwd`/CoreTrojan.pkg

  echo "Done."

else 
  echo "Fatal...build error"
  exit 1
fi
