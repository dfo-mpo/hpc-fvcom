provider "aws" {
    region  = "us-east-1"
}
variable instance_count {
	description = "Defines the number of VMs to be provisioned."
	default     = "1"
}

variable "instance_type" {
    default = "c5n.18xlarge"
    #default = "c5.xlarge"
    #default = "c5.18xlarge"
    #default = "c5.24xlarge"
    #default = "c5.metal"
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
    ami                     = "ami-024a64a6685d05041"   # Ubuntu 18.04LTS
    #ami                     = "ami-00213cf1aa442f159"    # Packer-HPC
    instance_type           = "${var.instance_type}"
    key_name                = "${aws_key_pair.sshkey.key_name}"
    vpc_security_group_ids  = [ "sg-0beee46423a9746a2" ]
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