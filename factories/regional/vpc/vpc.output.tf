// return VPC ID as output
output "app-vpc-id" {
  value = aws_vpc.app-vpc.id
}

// return VPC default security Group ID
output "default-sg-id" {
  value = aws_vpc.app-vpc.default_security_group_id
}

// return the list of pubic subnets
output "public-subnets" {
  value = aws_subnet.public-subnets[*].id
}

// return the list of private subnets
output "private-subnets" {
  value = aws_subnet.private-subnets[*].id
}