output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id # "*" meanig how many are created it gives/shows those results 
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id # "*" meanig how many are created it gives/shows those results 
}

output "database_subnet_ids" {
  value = aws_subnet.database[*].id # "*" meanig how many are created it gives/shows those results 
}