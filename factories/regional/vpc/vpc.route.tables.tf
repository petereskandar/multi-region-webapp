###########################################
## Public Route Table & Subnet Association
##########################################


# Creating Route Table for the public subnets
resource "aws_route_table" "public-subnets-rt" {
  provider = aws.dst
  vpc_id   = aws_vpc.app-vpc.id

  # Internet Rule
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "APP-VPC Public Route Table"
  }
  depends_on = [aws_internet_gateway.internet_gateway]
}

# Creating a resource for the Route Table Association!
resource "aws_route_table_association" "rt-public-association" {
  provider       = aws.dst
  count          = length(aws_subnet.public-subnets)
  subnet_id      = aws_subnet.public-subnets[count.index].id
  route_table_id = aws_route_table.public-subnets-rt.id
}

###########################################
## Private Route Table & Subnet Association
##########################################

# Creating an Elastic IP for the NAT Gateway!
resource "aws_eip" "nat-gateway-eip" {
  provider = aws.dst
  vpc      = true
}

# Creating a NAT Gateway!
resource "aws_nat_gateway" "nat-gateway" {
  provider = aws.dst
  # Allocating the Elastic IP to the NAT Gateway!
  allocation_id = aws_eip.nat-gateway-eip.id

  # Associating it in the Public Subnet!
  subnet_id = aws_subnet.public-subnets[0].id
  tags = {
    Name = "APP-VPC NAT Gateway"
  }
  depends_on = [aws_internet_gateway.internet_gateway]
}

# Creating a Route Table for the Private Subnets
resource "aws_route_table" "private-subnets-rt" {
  provider = aws.dst
  vpc_id   = aws_vpc.app-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gateway.id
  }

  tags = {
    Name = "APP-VPC Private Route Table"
  }
  depends_on = [aws_internet_gateway.internet_gateway]
}

# Creating a resource for the Route Table Association!
resource "aws_route_table_association" "rt-private-association" {
  provider       = aws.dst
  count          = length(aws_subnet.private-subnets)
  subnet_id      = aws_subnet.private-subnets[count.index].id
  route_table_id = aws_route_table.private-subnets-rt.id
}