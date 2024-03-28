terraform {
  backend "s3" {
    bucket = "terracantus-terraform-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "tfstate" {
  bucket = "terracantus-terraform-state"
}
