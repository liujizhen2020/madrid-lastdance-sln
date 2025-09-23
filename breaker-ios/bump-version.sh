#!/bin/bash

sed -i "" "s/Version:.*/Version: `date +%y%m%d%H%M`/g" layout/DEBIAN/control
sed -i "" "s/BIZ_VERSION.*;/BIZ_VERSION = @\"`date +%y%m%d%H%M`\";/g" common/defines.h

if [ $# -lt 1 ]; then
    echo "**** auto commit ~~~ at `date +%y-%m-%d_%H:%M`"
    git commit -m "ver `date +%y-%m-%d_%H:%M` (auto) " layout/DEBIAN/control common/defines.h
else
    echo "**** skip commit"
fi

