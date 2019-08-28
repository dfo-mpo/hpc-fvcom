provider "aws" {
    region  = "us-east-1"
}
variable instance_count {
	description = "Defines the number of VMs to be provisioned."
	#default     = "2"
}

variable "instance_type" {
    #default = "c5n.18xlarge"   # EFA (will not work with Terraform yet)
    default = "c5.18xlarge"    # 72vCPU (36 physical core)
    #default = "c5.24xlarge"    # 96vCPU (48 physical core)
    #default = "c5.metal"       # 96vCPU (48 physical core), metal
    #default = "m4.large"
}

variable "aws_region" {
    default = "us-east-1"
}

resource "aws_key_pair" "sshkey" {
    key_name   = "ubuntu"
    public_key = "${file("~/ubuntu.key.pub")}"
}

resource "aws_instance" "vm" {
    count                   = "${var.instance_count}"
    #ami                    = "ami-024a64a6685d05041"   # Ubuntu 18.04LTS
    ami                     = "ami-050a044d963650907"    # Packer-HPC, August 28
    instance_type           = "${var.instance_type}"
    key_name                = "${aws_key_pair.sshkey.key_name}"
    vpc_security_group_ids  = [ "sg-078a0d89b28b2da97" ]
    placement_group         = "cluster"
    root_block_device {
        volume_type = "gp2"
        volume_size = 128
    }

}


resource "null_resource" "prep_ansible" {
	triggers = {
		build_number = "${timestamp()}"
	}
	depends_on = ["aws_instance.vm"]

	provisioner "local-exec" {
		command = "echo [default] ${join(" ", aws_instance.vm.*.public_ip)} | tr \" \" \"\n\" > ansible.hosts"
	}
    provisioner "local-exec" {
        command = "echo ${join("@", formatlist("Host %s @  User ubuntu@  Hostname %s@  IdentityFile ~/ubuntu.key", aws_instance.vm.*.public_ip, aws_instance.vm.*.public_ip))} | tr \"@\" \"\n\" > ~/vscode.hosts"
    }

}