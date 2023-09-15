###########################################
## Gateway Endpoints Creation
##########################################

// S3 Gateway Endpoint
resource "aws_vpc_endpoint" "s3" {
  provider        = aws.dst
  vpc_id          = aws_vpc.app-vpc.id
  service_name    = "com.amazonaws.${data.aws_region.current.name}.s3"
  route_table_ids = ["${aws_route_table.public-subnets-rt.id}", "${aws_route_table.private-subnets-rt.id}"]

  tags = merge(var.tags, {
    Name = "S3-Gateway-Endpoint"
  })
}

// DynamoDB Gateway Endpoint
resource "aws_vpc_endpoint" "dynamodb" {
  provider        = aws.dst
  vpc_id          = aws_vpc.app-vpc.id
  service_name    = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  route_table_ids = ["${aws_route_table.public-subnets-rt.id}", "${aws_route_table.private-subnets-rt.id}"]

  tags = merge(var.tags, {
    Name = "S3-Gateway-Endpoint"
  })
}