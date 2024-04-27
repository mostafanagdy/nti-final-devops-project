# Define the VPC
resource "aws_vpc" "rds_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Define the internet gateway
resource "aws_internet_gateway" "rds_igw" {
  vpc_id = aws_vpc.rds_vpc.id
}

# Define the public subnet
resource "aws_subnet" "public_subnet_rd" {
  vpc_id            = aws_vpc.rds_vpc.id
  cidr_block        = "10.0.2.0/24"  # Public subnet CIDR block
  availability_zone = "us-east-1a"   # Adjust the availability zone as needed

  # Associate the subnet with the internet gateway to make it public
  map_public_ip_on_launch = true
}

# Define the private subnet
resource "aws_subnet" "private_subnet_rd" {
  vpc_id            = aws_vpc.rds_vpc.id
  cidr_block        = "10.0.1.0/24"  # Private subnet CIDR block
  availability_zone = "us-east-1b"   # Adjust the availability zone as needed
}

resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_rd.id, aws_subnet.public_subnet_rd.id]
}


# Define a route table for the private subnets
resource "aws_route_table" "db_private_route_table" {
  vpc_id = aws_vpc.rds_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.rds_igw.id  # Route traffic to the internet gateway
  }
}

# Associate the private route table with the private subnet
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private_subnet_rd.id
  route_table_id = aws_route_table.db_private_route_table.id
}


# Launch RDS instance in the private subnet
resource "aws_db_instance" "db_instance" {
  identifier             = "my-db-instance"  
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7.44"
  instance_class         = "db.t3.micro"
  name                   = "mydatabase"
  username               = "admin"
  password               = "mostafanagdy"
  parameter_group_name   = "default.mysql5.7"
  db_subnet_group_name = aws_db_subnet_group.my_db_subnet_group.name
  publicly_accessible    = false
  skip_final_snapshot    = true
 
  tags = {
    Name = "MyDBInstance"
  }
}



