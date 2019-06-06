# EFA
wget https://s3-us-west-2.amazonaws.com/aws-efa-installer/aws-efa-installer-latest.tar.gz
tar -xf aws-efa-installer-latest.tar.gz
cd aws-efa-installer
sudo ./efa_installer.sh -y
fi_info -p efa
cd


# Get stuff
sudo yum -y install git gcc gcc-c++ patch make cmake autoconf flex automake pkgconfig rpm-build libibverbs libibverbs-utils libfabric libfabric-devel rdma-core rdma-core-devel librdmacm-utils numactl numactl-devel numactl-libs gcc-gfortran libgfortran htop kernel-devel-$(uname -r)
sudo amazon-linux-extras install epel -y
sudo yum -y install hdf5-devel zlib-devel curl-devel

# Make OpenUCX
wget https://github.com/openucx/ucx/releases/download/v1.5.1/ucx-1.5.1.tar.gz
tar xzf ucx-1.5.1.tar.gz
cd ucx-1.5.1
./contrib/configure-release --prefix=/opt/ucx-1.5.1
make -j `nproc`
sudo make install
cd

# Make OpenMPI
wget https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.1.tar.gz
tar zxvf openmpi-4.0.1.tar.gz
cd openmpi-4.0.1
./configure --prefix=/opt/openmpi-4.0.1 --enable-static --with-ucx=/opt/ucx-1.5.1 --with-libfabric=/opt/amazon/efa
make clean > /dev/null &>/dev/null
make all -j `nproc`
sudo make install
cd

# Add to path for everyone
echo 'pathmunge /opt/openmpi-4.0.1/bin after' | sudo tee -a /etc/profile.d/openmpi.sh
sudo chmod +x /etc/profile.d/openmpi.sh

# AzCopy Install
wget --content-disposition https://aka.ms/downloadazcopy-v10-linux
tar zxvf azcopy_linux_amd64_*.tar.gz
sudo cp azcopy_linux_amd64*/azcopy /usr/local/bin/

# NetCDF
wget https://github.com/Unidata/netcdf-c/archive/v4.7.0.tar.gz
tar zxvf v4.7.0.tar.gz
cd netcdf-c-4.7.0
./configure --prefix=/opt/netcdf-4.7.0
make -j `nproc`
sudo make install
cd

echo 'pathmunge /opt/netcdf-4.7.0/bin after' | sudo tee -a /etc/profile.d/netcdf.sh
sudo chmod +x /etc/profile.d/netcdf.sh

# NetCDF-Fortran
wget https://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-fortran-4.4.5.tar.gz
tar zxvf netcdf-fortran-4.4.5.tar.gz
cd netcdf-fortran-4.4.5/
export NCDIR=/opt/netcdf-4.7.0
export LD_LIBRARY_PATH=${NCDIR}/lib:/opt/netcdf-fortran-4.4.5/lib:${LD_LIBRARY_PATH}
export CPPFLAGS=-I${NCDIR}/include LDFLAGS=-L${NCDIR}/lib
./configure --prefix=/opt/netcdf-fortran-4.4.5 CPPFLAGS=-I${NCDIR}/include LDFLAGS=-L${NCDIR}/lib
make -j `nproc`
sudo make install
cd

echo 'pathmunge /opt/netcdf-fortran-4.4.5/bin after' | sudo tee -a /etc/profile.d/netcdf-fortran.sh
sudo chmod +x /etc/profile.d/netcdf-fortran.sh

# fvcom
cd
azcopy copy "$SAS_URL" ./ --recursive
chmod 755 -R fvcom
#F90FLAGS  = -ffree-line-length-0 -g -I/opt/netcdf-fortran-4.4.5/include
#LDFLAGS   = -L/opt/netcdf-fortran-4.4.5/lib

cd fvcom/FVCOM41/Configure/
./setup -a greg -c wvi_inlets4_heating

make clean
make libs gotm fvcom -j `nproc`
make -j `nproc`
cd
cp fvcom/FVCOM41/FVCOM_source/fvcom fvcom/_run


echo '/opt/openmpi-4.0.1/lib:/opt/netcdf-fortran-4.4.5/lib:/opt/openmpi-4.0.1/lib' | sudo tee -a /etc/ld.so.conf.d/ompi.conf
sudo chmod +x /etc/ld.so.conf.d/ompi.conf

# /etc/ld.so.conf.d
# TODO:  Using /etc/ld.so.conf.d make it so you don't have to do the exports below


# Runtime
sudo mkdir /mnt
sudo mkdir /mnt/fvcom
sudo chmod 777 -R /mnt/fvcom/

#export OMPI_MCA_pml=cm
export OMPI_MCA_btl=self,vader,tcp

export NCDFDIR=/opt/netcdf-4.7.0
export NCDFFDIR=/opt/netcdf-fortran-4.4.5
export OMPIDIR=/opt/openmpi-4.0.1
export LD_LIBRARY_PATH=${OMPIDIR}/lib:${NCDFDIR}/lib:${NCDFFDIR}/lib:${LD_LIBRARY_PATH}:/opt/amazon/efa/lib64
cd fvcom/_run
mpirun --bind-to core ./fvcom --CASENAME=wvi_inlets4



# Working below
#  GCC Compiler Definitions (Greg)
#--------------------------------------------------------------------------
    COMPILER    = -DGFORTRAN -Df2cFortran
    NCDF_MOD	= /opt/netcdf-fortran-4.4.5/include
    F90FLAGS    = -ffree-line-length-0 -g -I/opt/netcdf-fortran-4.4.5/include
    LDFLAGS     = -L/opt/netcdf-fortran-4.4.5/lib -L/opt/netcdf-4.7.0/lib

    CPP         = /usr/bin/cpp
    CC          = mpicc
    CXX         = mpicxx
    CFLAGS      = -O3
    FC          = mpif90
    OPT         = -O3



# Single c5n.18xlarge - 0.127
