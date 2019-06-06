# Goal - compile as little as possible and use the libfabric/openmpi from the EFA installer.

# EFA
wget https://s3-us-west-2.amazonaws.com/aws-efa-installer/aws-efa-installer-latest.tar.gz
tar -xf aws-efa-installer-latest.tar.gz
cd aws-efa-installer
sudo ./efa_installer.sh -y
fi_info -p efa
cd

# RELOGIN

# Get stuff
sudo yum -y install git gcc gcc-c++ patch make cmake autoconf flex automake pkgconfig rpm-build libibverbs libibverbs-utils libfabric libfabric-devel rdma-core rdma-core-devel librdmacm-utils numactl numactl-devel numactl-libs gcc-gfortran libgfortran htop
sudo amazon-linux-extras install epel -y
sudo yum -y install hdf5-devel zlib-devel curl-devel


# AzCopy Install
wget --content-disposition https://aka.ms/downloadazcopy-v10-linux
tar zxvf azcopy_linux_amd64_*.tar.gz
sudo cp azcopy_linux_amd64*/azcopy /usr/local/bin/
rm -rf azcopy_lin*

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


## RE-LOGin or RESOURCE path here

# fvcom
cd
azcopy copy "$SAS_URL" ./ --recursive
chmod 755 -R fvcom

cd fvcom/FVCOM41/Configure/
./setup -a greg -c wvi_inlets4_heating

make clean
make libs gotm fvcom -j `nproc`
make -j `nproc`
cd
cp fvcom/FVCOM41/FVCOM_source/fvcom fvcom/_run

sudo mkdir /mnt
sudo mkdir /mnt/fvcom
sudo chmod 777 -R /mnt/fvcom/

mpirun --bind-to core --mca btl self,vader,tcp -x LD_LIBRARY_PATH=/opt/netcdf-fortran-4.4.5/lib:/opt/netcdf-4.7.0/lib/:/opt/amazon/efa/lib64/:${LD_LIBRARY_PATH} ./fvcom --CASENAME=wvi_inlets4
