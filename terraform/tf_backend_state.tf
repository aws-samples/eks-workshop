/*
    S3 Backend setup for TF-STATE mgmt with state locking using dynamodb
    to facilitate concurrent development on environment
*/

# S3 Bucket to hold state.
resource "aws_s3_bucket" "s3_backend" {
  count  = "${var.create_s3_bucket}"
  acl    = "private"
  bucket = "${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}-${var.dnsdomain}-terraform-state-store"
  region = "${data.aws_region.current.name}"

  versioning {
    enabled = "${var.use_bucket_versioning}"
  }

  lifecycle {
    prevent_destroy = false
  }

  tags {
    Name      = "TF remote state test"
    Terraform = "true"
  }
}

# DynamoDB table to lock state during applies
resource "aws_dynamodb_table" "terraform_state_lock" {
  count          = "${var.create_dynamodb_lock_table}"
  name           = "${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}-dynamodb-terraform-lock-table"
  read_capacity  = 2
  write_capacity = 2
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags {
    Purpose = "Terraform state lock for state in ${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}-${var.dnsdomain}-terraform-state-store:${var.s3_key} "
  }
}

/* Local file for next init to move state to s3.
   After initial apply, run
    terraform init -force-copy
   to auto-copy state up to s3
*/
resource "local_file" "terraform_tf" {
  content = <<EOF
    terraform {
      backend "s3" {
        bucket         = "${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}-${var.dnsdomain}-terraform-state-store"
        key            = "${var.s3_key}"
        region         = "${data.aws_region.current.name}"
        encrypt        = false
        dynamodb_table = "${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}-dynamodb-terraform-lock-table"
      }
    }
    EOF

  filename = "${path.root}/terraform.tf"
}

data "aws_region" "current" {
  current = true
}

variable "create_dynamodb_lock_table" {
  default     = true
  description = "Boolean:  If you have a dynamoDB table already, use that one, else make this true and one will be created"
}

variable "create_s3_bucket" {
  default     = true
  description = "Boolean.  If you have an S3 bucket already, use that one, else make this true and one will be created"
}

variable "use_bucket_encryption" {
  default     = true
  description = "Boolean.  Encrypt bucket with account default CMK"
}

variable "use_bucket_versioning" {
  default     = false
  description = "Boolean.  disabled for easy destroys... enable for production level usage"
}

variable "s3_key" {
  default = "terraform.tfstate"
  description = "Path to your state.  Examples: dev/tf.state, prod/tf.state, dev/frontend/tf.state, dev/db-tier.tf, etc.."

}
