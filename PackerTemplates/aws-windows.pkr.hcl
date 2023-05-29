
data "amazon-ami" "windows_2019r2" {
  filters = {
    name = "*Windows_Server-2019-English-Full-Base-*"
  }
  most_recent = true
  owners      = ["801119661308"]
  region      = "us-east-1"
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }


source "amazon-ebs" "windows-2019r2" {
  ami_name       = "my-Windows_Server-2019-aws-{{timestamp}}"
  communicator   = "winrm"
  instance_type  = "t2.micro"
  region         = "us-east-1"
  source_ami     = "${data.amazon-ami.windows_2019r2.id}"
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
  sources = ["source.amazon-ebs.windows-2019r2"]

  provisioner "powershell" {
    inline = ["C:\\ProgramData\\Amazon\\EC2-Windows\\Launch\\Scripts\\InitializeInstance.ps1 -Schedule"]
  }

  provisioner "powershell" {
    inline = ["cd C:/", "echo pwd", "mkdir SomeDir"]
  }

  # provisioner "file" {
  #   destination = "C:\\SomeDir\\robo_copy.ps1"
  #   source = "D:\\Devraj\\Study\\Packer\\PackerTemplates\\scripts\\robo_copy.ps1"
  # }

  provisioner "powershell" {
    elevated_execute_command = powershell -executionpolicy bypass "& { if (Test-Path variable:global:ProgressPreference){$ProgressPreference='SilentlyContinue'};. {{.Vars}}; &'{{.scripts\\robo_copy.ps1}}'; exit $LastExitCode }"
  }

  post-processor "manifest" {
  }
}