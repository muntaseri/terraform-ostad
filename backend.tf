# Create the S3 bucket first, then uncomment and configure this block.
# Backend settings cannot use Terraform input variables.
#
# terraform {
#   backend "s3" {
#     bucket       = "replace-with-your-state-bucket"
#     key          = "terraform-ostad/terraform.tfstate"
#     region       = "us-east-1"
#     encrypt      = true
#     use_lockfile = true
#   }
# }
