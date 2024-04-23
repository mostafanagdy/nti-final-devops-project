# Public Subnets
resource "aws_subnet" "public_subnet_a" {
  vpc_id     = aws_vpc.nti_devops_vpc.id
  cidr_block = "10.0.1.0/24"  
  availability_zone = "us-east-1a"  
  map_public_ip_on_launch = true  

  tags = {
    Name = "public-subnet-a"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/demo"      = "owned"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id     = aws_vpc.nti_devops_vpc.id
  cidr_block = "10.0.2.0/24"  
  availability_zone = "us-east-1b"  
  map_public_ip_on_launch = true 

  tags = {
    Name = "public-subnet-b"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/demo"      = "owned"
  }
}

# Private Subnets
resource "aws_subnet" "private_subnet_a" {
  vpc_id     = aws_vpc.nti_devops_vpc.id
  cidr_block = "10.0.3.0/24"  
  availability_zone = "us-east-1a"  

  tags = {
    Name = "private-subnet-a"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/demo"      = "owned"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id     = aws_vpc.nti_devops_vpc.id
  cidr_block = "10.0.4.0/24"  
  availability_zone = "us-east-1b"  

  tags = {
    Name = "private-subnet-b"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/demo"      = "owned"
  }
}

output "public_subnet_ids" {
  value = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
}

output "private_subnet_ids" {
  value = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
}