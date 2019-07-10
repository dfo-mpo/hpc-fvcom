#!/bin/bash

# FVCOM Setup and Compilation
# Download FVCOM from Blob

sudo mkdir /opt
sudo chmod -R 777 /opt
azcopy copy "$SAS_URL" /opt --recursive=true

cd /opt
chmod -R 755 fvcom
cd fvcom/FVCOM41/Configure/
./setup -a UBUNTU-18.04-GCC -c wvi_inlets4_heating

make clean
make libs -j
make gotm -j
make fvcom -j
make -j

sudo cp /opt/fvcom/FVCOM41/FVCOM_source/fvcom /usr/local/bin
