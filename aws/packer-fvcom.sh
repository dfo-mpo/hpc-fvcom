#!/bin/bash

# FVCOM Setup and Compilation
# Download FVCOM from Blob

sudo chmod -R 777 /opt
azcopy copy "$SAS_FVCOM_CODE" /opt --recursive=true

cd /opt
chmod -R 755 code
cd code/FVCOM41/Configure/
./setup -a UBUNTU-16.04-GCC -c wvi_inlets4_heating

make clean
make libs -j
make gotm -j
make fvcom -j
make -j

sudo cp /opt/code/FVCOM41/FVCOM_source/fvcom /usr/local/bin
