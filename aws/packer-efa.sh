# EFA
echo Sleeping 15 seconds...
sleep 15
wget --quiet https://s3-us-west-2.amazonaws.com/aws-efa-installer/aws-efa-installer-latest.tar.gz && tar xf aws-efa-installer-latest.tar.gz && cd aws-efa-installer && sudo ./efa_installer.sh --yes --no-verify
#fi_info -p efa
cd

# Remove EFA from path
sudo rm /etc/profile.d/efa.sh

# EFA will put a bunch of shit in /opt/amazon/efa/lib. We want to cherry pick libfabric
# But ignore outdated other stuff
sudo mkdir /usr/local/lf
sudo cp /opt/amazon/efa/lib/libfabric.* /usr/local/lf

echo '/usr/local/lf' | sudo tee -a /etc/ld.so.conf.d/efa-libfabric-only.conf
sudo chmod +x /etc/ld.so.conf.d/efa-libfabric-only.conf
sudo ldconfig

exit
