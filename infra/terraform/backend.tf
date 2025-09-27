terraform {
  backend "s3" {
    bucket = "tfstate-26"
    key    = "multi-region/infra.tfstate"
    region = "us-east-1"
    dynamodb_table = "tfstate-lock-26"
    encrypt = true
  }
}
