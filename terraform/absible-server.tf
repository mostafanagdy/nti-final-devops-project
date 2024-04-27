# Define the VPC
resource "aws_vpc" "ansible_vpc" {
  cidr_block = "192.168.0.0/16"  
}
# Define the subnet
# Define the subnet
resource "aws_subnet" "public_ansible_subnet" {
  vpc_id            = aws_vpc.ansible_vpc.id        
  cidr_block        = "192.168.3.0/24"  
  availability_zone = "us-east-1b"       
  map_public_ip_on_launch = true            
}
resource "aws_subnet" "private_ansible_subnet" {
  vpc_id            = aws_vpc.ansible_vpc.id        
  cidr_block        = "192.168.4.0/24"  
  availability_zone = "us-east-1a"       
  map_public_ip_on_launch = true            
}



###############################


####################################
#Create security group 
resource "aws_security_group" "myansible_sg" {
  name        = "ansible_sg20"
  description = "Allow inbound ports 22, 8080"
  vpc_id      = aws_vpc.ansible_vpc.id  

  #Allow incoming TCP requests on port 22 from any IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
#Allow incoming TCP requests on port 443 from any IP
  ingress {
    description = "Allow HTTPS Traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Allow incoming TCP requests on port 8080 from any IP
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}






resource "aws_internet_gateway" "ansible_igw" {
  vpc_id = aws_vpc.ansible_vpc.id   
}


 

# Define a route table for the public subnet
resource "aws_route_table" "ansible_public_route_table" {
  vpc_id = aws_vpc.ansible_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ansible_igw.id
  }
}

# Associate the public route table with the public subnet
resource "aws_route_table_association" "ansible_public_route_association" {
  subnet_id      = aws_subnet.public_ansible_subnet.id 
  route_table_id = aws_route_table.ansible_public_route_table.id
}
#####
resource "aws_instance" "ansible-ec2" {
  ami                    = "ami-04e5276ebb8451442"
  instance_type          = "t2.micro"
  key_name        = "ansible_mo_nagdy_server"
  vpc_security_group_ids      = [aws_security_group.myansible_sg.id]
   subnet_id              = aws_subnet.public_ansible_subnet.id 
  tags = {
    Name = "ansible-ec2"
  } 
}