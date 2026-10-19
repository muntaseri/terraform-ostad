# terraform-ostad

Reusable Terraform configuration for AWS.

## Configure and validate

Copy `terraform.tfvars.example` to `terraform.tfvars` and set the values for
your deployment. The local `terraform.tfvars` file is ignored by Git.

```sh
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
```

The AWS provider uses `aws_region`. It applies `Project`, `Environment`, and
`Owner` as default tags to supported resources. `environment` accepts only
`dev` or `prod`.

## Enable the S3 remote backend

The S3 bucket for Terraform state must be created manually before enabling the
backend. Use a unique bucket name, enable bucket versioning and server-side
encryption, and block public access. The configured AWS identity also needs
permissions to access the bucket and manage the `.tflock` object.

After creating the bucket, edit `backend.tf`: uncomment the `terraform` block
and replace `replace-with-your-state-bucket` with your bucket name. Set the
backend `region` to the bucket's AWS region. Backend configuration cannot use
Terraform variables. The configuration enables S3 encryption and native S3
state locking with `use_lockfile`.

Initialize the backend and migrate any existing local state when prompted:

```sh
terraform init -migrate-state
```

## Recreate the module directory layout

Run this Bash snippet from the repository root to create the module folders and
their standard Terraform files:

```bash
for module in vpc security_groups alb app rds s3 bastion; do
  mkdir -p "modules/$module"
  touch "modules/$module/main.tf" \
    "modules/$module/variables.tf" \
    "modules/$module/outputs.tf"
done
```
