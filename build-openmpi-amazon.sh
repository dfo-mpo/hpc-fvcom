# Get stuff
sudo yum -y update
sudo yum -y install git gcc gcc-c++ patch make cmake autoconf flex automake pkgconfig rpm-build kernel-devel-$(uname -r)
sudo yum -y install libibverbs libibverbs-utils libfabric libfabric-devel rdma-core rdma-core-devel librdmacm-utils numactl-devel numactl-libs
sudo yum -y install gcc-gfortran libgfortran

sudo amazon-linux-extras install epel -y
sudo yum-y install hdf5-devel zlib-devel curl-devel

# Make OpenUCX
https://github.com/openucx/ucx/releases/download/v1.5.1/ucx-1.5.1.tar.gz
tar xzf ucx-1.5.1.tar.gz
cd ucx-1.5.1
./contrib/configure-release --prefix=/opt/ucx-1.5.1
make -j `nproc`
sudo make install

# Make OpenMPI
wget https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.1.tar.gz
tar zxvf openmpi-4.0.1.tar.gz
cd openmpi-4.0.1
./configure --prefix=/opt/openmpi-4.0.1 --enable-static --with-ucx=/opt/ucx-1.5.1
make clean > /dev/null &>/dev/null
make all -j `nproc`
sudo make install

# Add to path for everyone
echo 'pathmunge /opt/openmpi-4.0.1/bin after' | sudo tee -a /etc/profile.d/openmpi.sh
sudo chmod +x /etc/profile.d/openmpi.sh

# AzCopy Install
wget --content-disposition https://aka.ms/downloadazcopy-v10-linux
tar zxvf azcopy_linux_amd64_*.tar.gz
sudo cp azcopy_linux_amd64*/azcopy /usr/local/bin/

# NetCDF
https://github.com/Unidata/netcdf-c/archive/v4.7.0.tar.gz
tar zxvf v4.7.0.tar.gz
cd netcdf-c-4.7.0
#./configure --prefix=/opt/netcdf-4.7.0
./configure --prefix=/opt/netcdf-4.7.0 --enable-remote-fortran-bootstrap
make -j `nproc`

# NetCDF-Fortran
wget https://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-fortran-4.4.5.tar.gz
tar zxvf netcdf-fortran-4.4.5.tar.gz
cd netcdf-fortran-4.4.5/
export NCDIR=/opt/netcdf-4.7.0
export LD_LIBRARY_PATH=${NCDIR}/lib:${LD_LIBRARY_PATH}
export CPPFLAGS=-I${NCDIR}/include LDFLAGS=-L${NCDIR}/lib \

./configure --prefix=/opt/netcdf-fortran-4.4.5 CPPFLAGS=-I${NCDIR}/include LDFLAGS=-L${NCDIR}/lib
make -j `nproc`
sudo make install

# fvcom
F90FLAGS  = -ffree-line-length-0 -g -I/opt/netcdf-fortran-4.4.5/include
LDFLAGS   = -L/opt/netcdf-fortran-4.4.5/lib

cd fvcom/FVCOM41/Configure/
./setup -a FEDORA-GCC -c wvi_inlets4_heating

make clean
make libs gotm fvcom -j `nproc`
make -j `nproc`
cd
cp fvcom/FVCOM41/FVCOM_source/fvcom fvcom/_run