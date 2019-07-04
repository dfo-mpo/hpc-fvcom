# EFA
echo Sleeping 15 seconds...
sleep 15
wget --quiet https://s3-us-west-2.amazonaws.com/aws-efa-installer/aws-efa-installer-latest.tar.gz && tar xf aws-efa-installer-latest.tar.gz && cd aws-efa-installer && sudo ./efa_installer.sh --yes --no-verify
#fi_info -p efa
echo '/opt/amazon/efa/lib' | sudo tee -a /etc/ld.so.conf.d/efa-libfabric.conf
sudo chmod +x /etc/ld.so.conf.d/efa-libfabric.conf
sudo ldconfig
cd
exit
