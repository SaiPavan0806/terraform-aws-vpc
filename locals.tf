locals {
  comman_tags ={
    Project = var.project_name
    Environment = var.environment
    Terraform = true
  }
  comman_name_suffix ="${var.project_name}-${var.environment}" # roboshop-dev (shows which environment it belongs to)
  az_names = slice(data.aws_availability_zones.available.names, 0, 2 )
}
