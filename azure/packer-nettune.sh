#!/bin/bash
sudo sysctl -w net.core.rmem_max=2147483647
sudo sysctl -w net.core.wmem_max=2147483647
sudo sysctl -w net.ipv4.tcp_rmem='4096 87380 2147483647'
sudo sysctl -w net.ipv4.tcp_wmem='4096 65536 2147483647'
#sudo sysctl -w net.core.netdev_max_backlog=30000
sudo sysctl -w net.core.rmem_default=16777216
sudo sysctl -w net.core.wmem_default=16777216
sudo sysctl -w net.ipv4.tcp_mem='16777216 16777216 16777216'
sudo sysctl -w net.ipv4.route.flush=1

# https://access.redhat.com/sites/default/files/attachments/20150325_network_performance_tuning.pdf
# Prevent the CPU from idling ever, avoiding overhead of waking up from idle
echo "GRUB_CMDLINE_LINUX_DEFAULT=\"intel_idle.max_cstate=1\"" | sudo tee -a /etc/default/grub.d/66-hpc.cfg
sudo update-grub


