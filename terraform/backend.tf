terraform {
  backend "s3" {
    bucket = "hokaccha"
    key    = "isucon9/isucon9.tfstate"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  version             = "= 2.69.0"
  region              = "ap-northeast-1"
  allowed_account_ids = ["287379415997"]
}
