data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "isucon" {
  count = 3

  ami = data.aws_ami.ubuntu.id
  # instance_type = "t3.medium"
  instance_type = "t3.nano"
  key_name      = "isucon"

  vpc_security_group_ids = [aws_security_group.default.id]

  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    iops                  = 100
    delete_on_termination = true
  }

  tags = {
    Name = "isucon9-${count.index + 1}"
  }
}
