terraform {
  backend "s3" {
    bucket = "terra-jenkins-eks2"
    key    = "jump-server/terraform.tfstate"
    region = "us-east-1"
    profile = "default"
  }
}