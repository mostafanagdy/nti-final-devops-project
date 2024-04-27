resource "aws_internet_gateway" "nti_devops_igw" {
  vpc_id =  aws_vpc.nti_devops_vpc.id
  tags = {
    Name = "nti_devops_igw"
  }
}

output "igw_id" {
  value = aws_internet_gateway.nti_devops_igw.id
}