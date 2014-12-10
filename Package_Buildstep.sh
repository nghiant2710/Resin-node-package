#!/bin/bash

# Install deps
apt-get update
apt-get install -y wget build-essential dh-make

# ENV for the build
DEBEMAIL=james@resin.io
DEBFULLNAME="resin.io"
NAME="resin-node"
VERSION="0.1"
DEPS="python, build-essential"
NODE_VERSION="0.10.22"
NODE_BASE_URL="http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-arm-pi.tar.gz"
export USER=pi
export LOGNAME=pi


# Begin of creating package
mkdir $NAME-$VERSION
cd $NAME-$VERSION
dh_make --createorig --indep --copyright gpl --yes
mkdir temp && mv debian/{changelog,compat,rules,control} temp
rm -rf debian && mv temp debian
sed -i "s/Build-Depends: /Build-Depends: $DEPS, /g" debian/control
# Need to check content of copyright file or changelog file

# Set root dir for package
echo './bin/* ./' > debian/$NAME.install

# Set up node
mkdir -p bin/usr
wget -O- -q $NODE_BASE_URL | tar xzf - -C bin/usr --no-same-owner \
    && mv bin/usr/node-v$NODE_VERSION-linux-arm-pi/* bin/usr \
    && rm -rf bin/usr/node-v$NODE_VERSION-linux-arm-pi \
    && chmod +x bin/usr/bin/*
    # && rm -rf bin/usr/bin/node/share

# Build Package
dpkg-buildpackage -uc -tc -b -rfakeroot