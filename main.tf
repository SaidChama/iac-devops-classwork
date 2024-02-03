provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "said-work-bucket" {
  bucket = "devops-work-said-240302"

  versioning {
    enabled = true
  }
}