#!/bin/bash

# Number of instances to run
export TF_VAR_instance_count=3
export TF_VAR_resource_location="South Central US"

echo building infrastructure...
terraform init
terraform apply -auto-approve

# If Azure is having a bad day (more often then not) it takes some time for VM's to be available
echo "Resources created, delay then configuring..."
sleep 180
ansible-playbook fvcom-packer-azure.yml

echo "Science is done. Destroying VM's in 30 seconds..."
sleep 30
terraform destroy -auto-approve
echo finished!
