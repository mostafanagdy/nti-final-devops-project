# Define the VPC
resource "aws_vpc" "jenkins_vpc" {
  cidr_block = "192.168.0.0/16"  
}
# Define the subnet
# Define the subnet
resource "aws_subnet" "public_jenkins_subnet" {
  vpc_id            = aws_vpc.jenkins_vpc.id        
  cidr_block        = "192.168.1.0/24"  
  availability_zone = "us-east-1a"       
  map_public_ip_on_launch = true            
}
resource "aws_subnet" "private_jenkins_subnet" {
  vpc_id            = aws_vpc.jenkins_vpc.id        
  cidr_block        = "192.168.2.0/24"  
  availability_zone = "us-east-1a"       
  map_public_ip_on_launch = true            
}

#Create security group 
resource "aws_security_group" "myjenkins_sg" {
  name        = "jenkins_sg20"
  description = "Allow inbound ports 22, 8080"
  vpc_id      = aws_vpc.jenkins_vpc.id  

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


# Create S3 bucket for Jenkins Artifacts
resource "aws_s3_bucket" "nagdy_jenkins_s3_bucket" {
  bucket = "jenkins-mostafa-s3-nagdy"

  tags = {
    Name = "jenkins-ec2"
  }
}

# Create another S3 bucket
resource "aws_s3_bucket" "my_s3_bucket" {
  bucket = "mostafa-nagdy-s3-bucket"  # Replace with your desired bucket name
 # acl    = "private"
  tags = {
    Name = "MyS3Bucket"
  }
}

# Define ACL for the second bucket
resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  bucket = aws_s3_bucket.my_s3_bucket.id
  acl    = "private"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.my_s3_bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}


######

resource "aws_internet_gateway" "jenkins_igw" {
  vpc_id = aws_vpc.jenkins_vpc.id   
}


 

# Define a route table for the public subnet
resource "aws_route_table" "jenkins_public_route_table" {
  vpc_id = aws_vpc.jenkins_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jenkins_igw.id
  }
}

# Associate the public route table with the public subnet
resource "aws_route_table_association" "public_route_association" {
  subnet_id      = aws_subnet.public_jenkins_subnet.id 
  route_table_id = aws_route_table.jenkins_public_route_table.id
}
#####
resource "aws_instance" "jenkins-ec2" {
  ami                    = "ami-04e5276ebb8451442"
  instance_type          = "t2.micro"
  key_name        = "jenkins_server_key_pair"
  user_data       = file("install_jenksin.sh")
  vpc_security_group_ids      = [aws_security_group.myjenkins_sg.id]
   subnet_id              = aws_subnet.public_jenkins_subnet.id 
  tags = {
    Name = "jenkins-ec2"
  } 
}
####
# an empty resource block
resource "null_resource" "name" {
  # ssh into the ec2 instance 
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/Downloads/jenkins_server_key_pair.pem")
    host        = aws_instance.jenkins-ec2.public_ip
  }

  # copy the install_jenkins.sh file from your computer to the ec2 instance 
  provisioner "file" {
    source      = "install_jenksin.sh"
    destination = "/tmp/install_jenksin.sh"
  }

  # set permissions and run the install_jenkins.sh file
  provisioner "remote-exec" {
    inline = [
        "sudo chmod +x /tmp/install_jenksin.sh",
        "sh /tmp/install_jenksin.sh",
    ]
  }

  # wait for ec2 to be created
  depends_on = [aws_instance.jenkins-ec2]
}



# print the url of the jenkins server
output "website_url" {
  value     = join ("", ["http://", aws_instance.jenkins-ec2.public_dns, ":", "8080"])
}


####

resource "aws_db_instance" "jenkins_db_instance" {
  identifier        = "my-db-instance"
  instance_class    = "db.t2.micro"
  allocated_storage = 20  # Set the allocated storage size
  engine            = "mysql"
  password         ="mostafanagdy" 
  username               = "admin" 
  # Define your complete RDS instance configuration here
}



resource "aws_kms_key" "kms_key" {
  description             = "KMS key for encryption"
  deletion_window_in_days = 10  # Optionally specify the key deletion window
  enable_key_rotation     = true
}

resource "aws_backup_vault" "jenkins_backup_vault" {
  name        = "jenkins-backup-vault"
  kms_key_arn = aws_kms_key.kms_key.arn  # Optionally, specify KMS key for encryption
}

resource "aws_backup_plan" "jenkins_backup_plan" {
  name = "jenkins-backup-plan"

  rule {
    rule_name         = "tf_backup_rule"
    target_vault_name = aws_backup_vault.jenkins_backup_vault.name  # Reference the correct backup vault
    schedule          = "cron(0 12 * * ? *)"  # Daily backup at 12:00 PM UTC

    lifecycle {
      delete_after = 14  # Retain backups for 14 days
    }
  }

  advanced_backup_setting {
    backup_options = {
      WindowsVSS = "enabled"
    }
    resource_type = "EC2"
  }
}


