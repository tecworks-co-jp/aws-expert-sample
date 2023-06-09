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

output "example_instance_id" {
  value = aws_instance.example.id
}

module "example_instance" {
  source        = "./instance"
  instance_type = var.example_instance_type
  name          = "YOUR-EC2-INSTANCE-NAME"
  subnet_id     = aws_subnet.private_0.id
}
