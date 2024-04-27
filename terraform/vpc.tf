
resource "aws_vpc" "nti_devops_vpc" {
  cidr_block       = "10.0.0.0/16" 
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "nti_devops_vpc"
  }
}

output "vpc_id" {
  value = aws_vpc.nti_devops_vpc.id
}
