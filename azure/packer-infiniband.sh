#!/bin/bash

# Set various configurations for InfiniBand in Azure (Hc Hb series)

high_key=`sort -r /sys/class/infiniband/mlx5_0/ports/1/pkeys/* | head -1`
modified_key=$(printf '0x%04X\n' "$((high_key ^ 0x8000))")

echo Setting UCX_IB_KEY to $modified_key
export UCX_IB_PKEY=$modified_key

echo Updating /etc/profile.d/ucx_pkey.sh
echo "export UCX_IB_PKEY=$modified_key" | sudo tee -a /etc/profile.d/ucx_pkey.sh



echo "Updating limits.conf for InifiniBand..."
cat << EOF | sudo tee -a /etc/security/limits.conf
*               hard    memlock         unlimited
*               soft    memlock         unlimited
*               hard    nofile          65535
*               soft    nofile          65535
EOF
