#!/bin/bash
# UBUNTU 18.04 LTS
# Goal is to manually compile all requirements so we can use this anywhere (AWS or Azure)

# EFA
wget https://s3-us-west-2.amazonaws.com/aws-efa-installer/aws-efa-installer-latest.tar.gz && tar -xf aws-efa-installer-latest.tar.gz && cd aws-efa-installer && sudo ./efa_installer.sh -y
fi_info -p efa
echo '/opt/amazon/efa/lib' | sudo tee -a /etc/ld.so.conf.d/efa-libfabric.conf
sudo chmod +x /etc/ld.so.conf.d/efa-libfabric.conf
sudo ldconfig
cd


# Get stuff
sudo apt update
export DEBIAN_FRONTEND=noninteractive
sudo apt -y install cmake git makedepf90 gfortran gcc patch htop iptraf-ng zlib1g-dev libcurl4-openssl-dev pkg-config git gcc gcc-opt cmake patch autoconf flex doxygen texlive-latex-base librdmacm-dev libnuma-dev
sudo apt -y install nvidia-cuda-dev
sudo apt -y install libfabric-dev # Not needed if EFA is installed, fails gracefully

# AWS CLI Install
sudo apt -y install awscli


# Make OpenUCX - (c5.18xl 22sec)
wget https://github.com/openucx/ucx/releases/download/v1.5.1/ucx-1.5.1.tar.gz && tar xzf ucx-1.5.1.tar.gz && cd ucx-1.5.1
./contrib/configure-release --prefix=/usr
make -j && sudo make install
cd

# Make OpenMPI - (c5.18xl 3m30s)
wget https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.1.tar.gz && tar zxvf openmpi-4.0.1.tar.gz && cd openmpi-4.0.1
# AWS EFA
./configure --prefix=/usr --enable-static --enable-shared --with-cuda=/usr/include --with-libfabric=/opt/amazon/efa
# Other
#./configure --prefix=/usr --enable-static --enable-shared --with-cuda=/usr/include
make all -j && sudo make install
cd

# HDF5 (c5.18xl 51s)
wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.5/src/hdf5-1.10.5.tar.gz && tar zxvf hdf5-1.10.5.tar.gz && cd hdf5-1.10.5/
./configure --prefix=/usr --enable-fortran --enable-shared --enable-static #--enable-parallel
make -j && sudo make install
cd


# NetCDF
wget https://github.com/Unidata/netcdf-c/archive/v4.7.0.tar.gz && tar zxvf v4.7.0.tar.gz && cd netcdf-c-4.7.0
./configure --prefix=/usr
make -j `nproc` && sudo make install
cd

# NetCDF-Fortran
wget https://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-fortran-4.4.5.tar.gz && tar zxvf netcdf-fortran-4.4.5.tar.gz && cd netcdf-fortran-4.4.5/
./configure --prefix=/usr 
make -j `nproc` && sudo make install
cd

