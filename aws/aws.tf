provider "aws" {
    region  = "us-east-1"
}
variable instance_count {
	description = "Defines the number of VMs to be provisioned."
	default     = "1"
}
variable app_name {
	description = "Application Name"
	default = "FVCOM"
}

variable "instance_type" {
    default = "c5.large"
}

variable "aws_region" {
    default = "us-east-1"
}

resource "aws_key_pair" "hpc" {
    key_name   = "hpc"
    public_key = "${file("../../hpc-aws.key.pub")}"
}

resource "aws_instance" "vm" {
    count         = "${var.instance_count}"
    ami           = "ami-0e8543553d836774e"
    instance_type = "${var.instance_type}"
    key_name      = "${aws_key_pair.hpc.key_name}"
    vpc_security_group_ids = [ "sg-0beee46423a9746a2" ]
    
}


resource "null_resource" "prep_ansible" {
	triggers = {
		build_number = "${timestamp()}"
	}
	depends_on = ["aws_instance.vm"]

	provisioner "local-exec" {
		command = "echo [default] ${join(" ", aws_instance.vm.*.public_ip)} | tr \" \" \"\n\" > ansible.hosts"
	}
}