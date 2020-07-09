sudo chmod -R 777 /opt
azcopy copy "$HPC_CONFIG_PATH$HPC_CONFIG_SAS" /opt --recursive
sudo chmod -R 777 /opt/code


# XIOS has it's own copy of boost built in (or something..)
# Boost
#wget --quiet https://dl.bintray.com/boostorg/release/1.73.0/source/boost_1_73_0.tar.gz && tar zxvf boost_1_73_0.tar.gz && cd boost_1_73_0
#./bootstrap.sh --prefix=/usr
#echo "using mpi ;" >> project-config.jam
#./b2 -j8 -target=shared,static
#sudo ./b2 install
#cd


# XIOS 2.5 (svn v1566)
cd
svn checkout http://forge.ipsl.jussieu.fr/ioserver/svn/XIOS/branchs/xios-2.5

cd xios-2.5/arch/
cp /opt/nemo/arch-GCC_local.env .
cp /opt/nemo/arch-GCC_local.fcm .
cp /opt/nemo/arch-GCC_local.path .
cd ..
./make_xios --full --prod --arch GCC_local --job `nproc` --build_path /opt/xios |& tee compile_log.txt
cd

# NEMO 3.6
svn checkout http://forge.ipsl.jussieu.fr/nemo/svn/NEMO/releases/release-3.6 nemo3.6
cd nemo3.6/NEMOGCM/ARCH
cp /opt/nemo/arch-gfortran_local.fcm .
cd ..
MY_CONFIG=NEP36
cd CONFIG
./makenemo -n $MY_CONFIG clean_config
./makenemo -m gfortran_local -n $MY_CONFIG -j0
cp /opt/nemo/cpp_NEP36.fcm ./$MY_CONFIG/
./makenemo -m gfortran_local -n $MY_CONFIG -j`nproc`