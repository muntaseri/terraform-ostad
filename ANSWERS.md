# MILESTONE 01

## EVIDENCE FOR MAYA

- GitHub repository with the Terraform skeleton committed:
  [muntaseri/terraform-ostad](https://github.com/muntaseri/terraform-ostad).
  Skeleton commit: [`680c1e4`](https://github.com/muntaseri/terraform-ostad/commit/680c1e44de7216135cc2053cfb250d23a2e10b7a)
  (`GitHub repo link with the skeleton`).


# Why Remote State and Locking Matter for Teams

Remote state gives everyone on a team a shared, current record of the
infrastructure Terraform manages. Without it, each person may work from a
different local state file, causing configuration drift or plans that miss
resources created by teammates. A remote backend also makes state accessible
from multiple machines and can provide centralized access controls, encryption,
and backups or versioning.

State locking prevents two Terraform operations from modifying the same state
at the same time. Without a lock, concurrent applies can overwrite state updates
or leave the state inconsistent with the actual infrastructure. Locking allows
one operation to proceed while others wait or fail safely, reducing the risk of
conflicting changes and difficult recovery.




![Terraform initialization and validation succeeded](screenshots/terra-init.jpg)



## What If Two People Run `terraform apply` at the Same Time?

Without locking, you and Sam could both plan against the same old state and
then make conflicting changes. Terraform might try to create or update the same
resources twice, and one apply could overwrite the other's state update. The
actual AWS resources and the recorded Terraform state could then disagree,
leaving duplicate or unmanaged resources and requiring manual recovery. With
locking enabled, one apply holds the state lock while it runs; the other waits
or fails safely instead of changing the state concurrently.




# MILESTONE 02

## EVIDENCE FOR MAYA

- VPC implementation: [`modules/vpc/main.tf`](modules/vpc/main.tf), with module
  inputs and outputs in [`modules/vpc/variables.tf`](modules/vpc/variables.tf)
  and [`modules/vpc/outputs.tf`](modules/vpc/outputs.tf).
- Root module call: [`main.tf`](main.tf).
- Plan summary, generated with
  `terraform plan -refresh=false -input=false -var-file=terraform.tfvars.example`:
  **Plan: 23 to add, 0 to change, 0 to destroy.** This is a plan only; no
  resources were applied.
- Network diagram: [`diagrams/vpc-network.drawio`](diagrams/vpc-network.drawio).

## DESIGN REVIEW

### 1. Why can app servers in private subnets reach the internet?

Private app subnets have no public IPs and do not route directly to the
Internet Gateway. Their route tables send outbound `0.0.0.0/0` traffic through
a NAT Gateway in a public subnet. The NAT Gateway sends that traffic out
through the Internet Gateway and translates the source address. Return traffic
is allowed back through the established connection, while unsolicited inbound
internet connections cannot directly reach the app servers.

### 2. What is the trade-off between one NAT Gateway and one per AZ?

A single NAT Gateway costs less because there is only one hourly charge and
one set of data-processing charges. Both AZs' private subnets share it, though,
so they depend on that AZ and traffic from the other AZ crosses zones, adding
latency and possible cross-AZ data-transfer cost.

One NAT Gateway per AZ costs more, but each AZ's private subnets can use their
local NAT Gateway. This avoids the cross-AZ NAT path and reduces the impact of
a single-AZ failure on outbound connectivity. The configuration defaults to
one NAT in `dev` and one per AZ in `prod`.





