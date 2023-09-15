data "aws_availability_zones" "available" {
  provider = aws.dst
}

####################################
## Public Subnets Creation
####################################

# Creating Public subnets
resource "aws_subnet" "public-subnets" {
  provider = aws.dst
  count    = length(data.aws_availability_zones.available.names)
  vpc_id   = aws_vpc.app-vpc.id

  # Generate CIDRs based on the number of the AZs
  cidr_block = cidrsubnet(var.vpc_cidr_block, 8, count.index + 1)

  # Subnet AZ
  availability_zone = data.aws_availability_zones.available.names[count.index]

  # Enabling automatic public IP assignment on instance launch!
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "PUBLIC-SUBNET-${count.index + 1}"
  })
}

####################################
## Private Subnets Creation
####################################

resource "aws_subnet" "private-subnets" {
  provider = aws.dst
  count    = length(data.aws_availability_zones.available.names)
  vpc_id   = aws_vpc.app-vpc.id

  # Generate CIDRs based on the number of the AZs
  cidr_block = cidrsubnet(var.vpc_cidr_block, 8, count.index + 10)

  # Subnet AZ
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(var.tags, {
    Name = "PRIVATE-SUBNET-${count.index + 1}"
  })
}
