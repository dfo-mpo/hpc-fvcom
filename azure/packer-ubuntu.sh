#!/bin/bash
# UBUNTU 18.04 LTS
# Compile all needed libraries for an HPC image

# Dependencies
sudo apt-get -yqq update
export DEBIAN_FRONTEND=noninteractive
sudo apt-get -yqq install cmake git makedepf90 gfortran gcc patch htop iptraf-ng zlib1g-dev libcurl4-openssl-dev pkg-config gcc-opt autoconf flex librdmacm-dev libnuma-dev doxygen nvidia-cuda-dev texlive-latex-base libfabric-dev

# AzCopy
wget --quiet --content-disposition https://aka.ms/downloadazcopy-v10-linux && tar zxvf azcopy_linux_amd64_*.tar.gz && sudo cp azcopy_linux_amd64*/azcopy /usr/local/bin/ && rm azcopy* -rf

# OpenUCX
#wget --quiet https://github.com/openucx/ucx/releases/download/v1.6.1/ucx-1.6.1.tar.gz && tar xzf ucx-1.6.1.tar.gz && cd ucx-1.6.1
wget --quiet https://github.com/openucx/ucx/releases/download/v1.5.1/ucx-1.5.1.tar.gz && tar xzf ucx-1.5.1.tar.gz && cd ucx-1.5.1
./contrib/configure-release --prefix=/usr
make -j && sudo make install
cd

# OpenMPI
wget --quiet https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.2.tar.gz && tar zxvf openmpi-4.0.2.tar.gz && cd openmpi-4.0.2
./configure --prefix=/usr --enable-static --enable-shared --with-cuda=/usr/include
make all -j && sudo make install
cd

# HDF5
wget --quiet https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.5/src/hdf5-1.10.5.tar.gz && tar zxvf hdf5-1.10.5.tar.gz && cd hdf5-1.10.5/
./configure --prefix=/usr --enable-fortran --enable-shared --enable-static #--enable-parallel
make -j && sudo make install
cd

# NetCDF
wget --quiet https://github.com/Unidata/netcdf-c/archive/v4.7.2.tar.gz && tar zxvf v4.7.2.tar.gz && cd netcdf-c-4.7.2
./configure --prefix=/usr
make -j `nproc` && sudo make install
cd

# NetCDF-Fortran
wget --quiet https://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-fortran-4.7.2.tar.gz && tar zxvf netcdf-fortran-4.7.2.tar.gz && cd netcdf-fortran-4.7.2/
./configure --prefix=/usr 
make -j `nproc` && sudo make install
cd

# MPI Benchmark
git clone https://github.com/intel/opa-mpi-apps/ && cd opa-mpi-apps/MpiApps/apps/imb/src
make CC=mpicc
sudo cp IMB-MPI1 /usr/local/bin
