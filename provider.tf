provider "aws" {
  region  = "ap-northeast-1"
  profile = "tecup"
}

provider "github" {
  owner = "YOUR-REPOSITORY-OWNER-NAME"
}

terraform {
  required_version = "1.3.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67.0"
    }
  }
}
