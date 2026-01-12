# Terraform AWS VPC

This module creates the following resources.
* vpc
* IGW (Internet Gateway)
* 2 public subnets in us-east-1a & us-east-1b
* 2 private subnets in us-east-1a & us-east-1b
* 2 databse subnets in us-east-1a & us-east-1b
* public route table
* private route table
* databse route table
* EIP (Elastic IP) for NAT
* NAT Gatewat in public subnet 1a AZ
* IGW route is added to public route
* NAT gateway route to private & databse route tables
* Route table association with subnets
* VPC to default VPC peering
* public route table to default VPC route
* Default VPC main route table to create VPC route

### Inputs

* vpc_cidr - (Required). User must supply the CIDR for VPC.
* project_name - (Required). User must supply the project name. 
* environment - (Required). user must supply the environment name.
* public_subnet_cidrs - (Required). user must supply the publc CIDRs
* private_subnet_cidrs - (Required). user must supply the private CIDRs
* databse_subnet_cidrs - (Required). user must supply the Database CIDRs.
* is_peering_required - (Required). user should supply either "TRUE" or "FALSE" by default the peering is set to True.

### Outputs

* vpc_id - shows VPC name
* public_subnet_ids - shows the user how many public subnet IDs are created
* private_subnet_ids - shows the user how many private subnet IDs are created
* database_subnet_ids - shows the user how many databse subnet IDs are created

