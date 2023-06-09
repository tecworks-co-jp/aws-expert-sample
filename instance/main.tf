# Define variables
variable "instance_type" {}
variable "name" {}
variable "subnet_id" {}

# EC2 Instance
output "example_instance_id" {
  value = aws_instance.example.id
}

data "aws_ami" "recent_amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_instance" "example" {
  ami           = data.aws_ami.recent_amazon_linux_2.image_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  tags = {
    "Name" = var.name
  }
}
