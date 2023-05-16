
data "amazon-ami" "windows_2012r2" {
  filters = {
    name = "Windows_Server-2012-R2_RTM-English-64Bit-Base-*"
  }
  most_recent = true
  owners      = ["AccountNumber"]
  region      = "us-east-1"
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }


source "amazon-ebs" "windows-2012r2" {
  ami_name       = "my-windows-2012-aws-{{timestamp}}"
  communicator   = "winrm"
  # access_key     = "SOME_ACCESS_KEY"
  # secret_key     = "SOME_SECRET_KEY"
  instance_type  = "t2.micro"
  region         = "us-east-1"
  source_ami     = "${data.amazon-ami.windows_2012r2.id}"
  user_data_file = "./scripts/SetUpWinRM.ps1"
  winrm_insecure = true
  winrm_use_ssl  = true
  winrm_username = "Administrator"
  tags = {
    "Name"        = "MyWindowsImage"
    "Environment" = "Production"
    "OS_Version"  = "Windows"
    "Release"     = "Latest"
    "Created-by"  = "Packer"
  }
}

build {
  sources = ["source.amazon-ebs.windows-2012r2"]

  post-processor "manifest" {
  }
}