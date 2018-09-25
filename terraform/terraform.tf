    terraform {
      backend "s3" {
        bucket         = "126310982896-us-east-1-eksworkshop.com-terraform-state-store"
        key            = "terraform.tfstate"
        region         = "us-east-1"
        encrypt        = false
        dynamodb_table = "126310982896-us-east-1-dynamodb-terraform-lock-table"
      }
    }
    