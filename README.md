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

## VPC layout

The VPC module selects two available AZs in `aws_region` and creates public,
private application, and isolated database subnets in each. Subnet CIDRs are
calculated from `vpc_cidr` with `cidrsubnet()`. The public subnets route through
an Internet Gateway; private subnets route outbound through NAT; database
subnets have no internet route.

`single_nat_gateway` defaults to `true` in `dev` and `false` in `prod`. Set it
explicitly in `terraform.tfvars` to override that behavior. A single NAT costs
less but is shared across both AZs; two NAT gateways provide per-AZ egress
availability. Root outputs expose the VPC ID and the public, private, database,
and combined subnet ID lists.

## Security groups

The security group module follows a tiered trust model: public HTTP/HTTPS
reaches the ALB; app HTTP is allowed only from the ALB; and MySQL is allowed
only from the app security group. Bastion SSH ingress is disabled by default.
To enable it, set `allowed_ssh_cidr` to your public IPv4 address in `/32`
notation; app SSH is accepted only from the bastion security group.

Egress is scoped to the required paths: ALB to app on TCP 80, app to database
on TCP 3306 and outbound HTTP/HTTPS via NAT, and bastion to app on TCP 22.
Security groups are stateful, so return traffic for allowed connections does
not require a broad reverse-direction rule. The database security group has no
initiated egress rule.

## Self-healing nginx web tier

The internet-facing ALB listens on HTTP port 80 and forwards to an instance
target group with an HTTP `/` health check. The app module launches the latest
Amazon Linux 2023 x86_64 AMI in the private subnets, installs nginx, starts the
AMI's preinstalled SSM agent, and serves a page showing the instance hostname,
availability zone, and environment.

The launch template requires IMDSv2, encrypts the root EBS volume, and assigns
an instance profile with `AmazonSSMManagedInstanceCore`. The Auto Scaling Group
uses ELB health checks, a rolling instance refresh, and target tracking at 50%
average CPU. Capacity and instance type are configurable with `app_min_size`,
`app_desired_capacity`, `app_max_size`, and `app_instance_type`.

After applying in an AWS account, get the web endpoint with:

```sh
terraform output -raw alb_dns_name
```

Open `http://<alb_dns_name>` or repeatedly run `curl` against that URL to
observe requests served by registered instances. The endpoint output does not
exist until the infrastructure has been applied.

For Session Manager, select an instance in the Auto Scaling Group and connect
without SSH keys:

```sh
aws ssm start-session --target <instance-id>
```

For a controlled replacement drill, terminate one instance without decreasing
the desired capacity:

```sh
aws autoscaling terminate-instance-in-auto-scaling-group \
  --instance-id <instance-id> \
  --no-should-decrement-desired-capacity
```

Verify in the Auto Scaling Group activity history that a replacement launches
and becomes healthy in the target group. For a scaling drill, connect with SSM
and run a bounded CPU workload, for example
`sudo dnf install -y stress-ng && stress-ng --cpu 2 --timeout 10m`. Observe the
CloudWatch CPU metric and Auto Scaling activity history; target tracking may
take several minutes to add capacity. These drills can incur AWS charges.

## RDS and S3 data protection

The RDS module creates a MySQL DB subnet group from the isolated database
subnets and a storage-encrypted, non-public DB instance protected by the
database security group. RDS generates and manages the master password in
Secrets Manager. Terraform exposes only the endpoint and secret ARN, never the
password. The app instance role can call `secretsmanager:GetSecretValue` for
that one secret so an authorized Session Manager session can connect to MySQL.

Database defaults follow the environment: dev uses Single-AZ, no deletion
protection, one day of backups, and skips the final snapshot; prod uses
Multi-AZ, deletion protection, seven days of backups, and retains a final
snapshot. Override these with `db_multi_az`, `db_deletion_protection`,
`db_backup_retention_period`, and `db_skip_final_snapshot`. The class and
initial database name use `db_instance_class` and `db_name`.

The S3 module creates a globally unique bucket with a random suffix, versioning,
AES-256 server-side encryption, bucket-owner-enforced ownership, all public
access blocks, and a bucket policy that denies non-TLS requests.

### Verify database secret access from an app instance

After applying, copy the following endpoint and secret ARN values from
`terraform output` into the Session Manager shell on an app instance. The
instance role grants read access only to this RDS-generated secret. This uses a
temporary, permission-restricted MySQL client file so the password is not put
on the command line:

```sh
DB_HOST="<hostname from terraform output -raw db_endpoint, without :3306>"
SECRET_ARN="<value from terraform output -raw db_master_user_secret_arn>"
DB_NAME="<value from terraform output -raw db_name>"
SECRET_JSON="$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_ARN" \
  --query SecretString --output text)"
MYSQL_CNF="$(mktemp)"
chmod 600 "$MYSQL_CNF"
printf '[client]\nhost=%s\nuser=%s\npassword=%s\n' \
  "$DB_HOST" \
  "$(jq -r .username <<< "$SECRET_JSON")" \
  "$(jq -r .password <<< "$SECRET_JSON")" > "$MYSQL_CNF"
mysql --defaults-extra-file="$MYSQL_CNF" "$DB_NAME"
# At the mysql> prompt, run: SELECT CURRENT_USER(), DATABASE();
# Type exit to return to the shell, then remove the temporary credentials file:
rm -f "$MYSQL_CNF"
unset SECRET_JSON
```

Capture the successful MySQL query in the Session Manager terminal for the
compliance evidence. Avoid printing the secret JSON or password in screenshots
or logs.

### Verify S3 denies HTTP

With AWS CLI credentials authorized to write to the bucket, upload a temporary
object, create a short-lived presigned URL, then change only its scheme to
HTTP. The HTTPS request should succeed and the HTTP request should receive
`403 AccessDenied` from the `aws:SecureTransport` bucket-policy deny:

```sh
BUCKET="$(terraform output -raw s3_bucket_name)"
printf 'TLS policy check\n' > /tmp/s3-tls-check.txt
aws s3 cp /tmp/s3-tls-check.txt "s3://$BUCKET/tls-check.txt"
URL="$(aws s3 presign "s3://$BUCKET/tls-check.txt" --expires-in 60)"
curl -i "$URL"
curl -i "${URL/https:/http:}"
aws s3 rm "s3://$BUCKET/tls-check.txt"
rm -f /tmp/s3-tls-check.txt
```

Capture the HTTP response showing `403 AccessDenied` for the evidence. Remove
the temporary object afterward if no longer needed.

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
