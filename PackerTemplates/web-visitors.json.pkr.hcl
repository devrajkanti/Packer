
variable "aws_source_ami" {
  type    = string
  default = "ami-039a49e70ea773ffc"
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebs" "autogenerated_1" {
  ami_name      = "tmp-${local.timestamp}"
  instance_type = "t1.micro"
  region        = "us-east-1"
  source_ami    = "${var.aws_source_ami}"
  ssh_pty       = "true"
  ssh_username  = "ubuntu"
  tags = {
    Created-by = "Packer"
    OS_Version = "Ubuntu"
    Release    = "Latest"
  }
}

build {
  sources = ["source.amazon-ebs.autogenerated_1"]

  provisioner "shell" {
    inline = ["mkdir ~/src", "cd ~/src", "git clone https://github.com/hashicorp/demo-terraform-101.git", "cp -R ~/src/demo-terraform-101/assets /tmp", "sudo sh /tmp/assets/setup-web.sh"]
  }

}