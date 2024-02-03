provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3"{
    bucket = "devops-work-said-240302"
    key = "terraformstate/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    dynamodb_table = "terraformstate"
  }
}