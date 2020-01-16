#!/bin/bash

# FVCOM Setup and Compilation
# Download FVCOM from Blob

sudo chmod -R 777 /opt
azcopy copy "$SAS_FVCOM_CODE" /opt --recursive=true

sudo chmod -R 777 /opt/code

cd /opt/code/FVCOM41/Configure/
for i in config/*
do
    echo "Compiling `basename $i` ..."
    cd /opt/code/FVCOM41/Configure/
    ./setup -a UBUNTU-16.04-GCC -c `basename $i`
    make clean
    make libs -j
    make gotm -j
    make fvcom -j
    make -j
    sudo mv /opt/code/FVCOM41/FVCOM_source/fvcom /usr/local/bin/fvcom_`basename $i`
    echo "Compiled and installed fvcom_`basename $i`" >> /opt/code/compile.txt
done