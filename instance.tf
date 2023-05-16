# Not recommended to create terraform bucket using terraform 
resource "aws_s3_bucket" "terraform" {
  bucket = "YOUR-TERRAFORM-BUCKET-NAME"
}

resource "aws_s3_bucket_acl" "terraform" {
  bucket = aws_s3_bucket.terraform.id
  acl    = "private"
}

# EC2 Instance
variable "example_instance_type" {
  default = "t3.micro"
}

locals {
  example_instance_type = "t3.micro"
}

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
  instance_type = var.example_instance_type
  subnet_id     = aws_subnet.private_0.id

  tags = {
    "Name" = "YOUR-EC2-INSTANCE-NAME"
  }
}
