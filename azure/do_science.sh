#!/bin/bash

# Number of instances to run
export TF_VAR_instance_count=1

echo building infrastructure...
terraform init
terraform apply -auto-approve
sleep 5
ansible-playbook fvcom-packer-azure.yml
sleep 5
terraform destroy -auto-approve
echo finished!


