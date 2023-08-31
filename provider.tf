terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
   backend "s3" {
       bucket         = "bucket-ravi-terra-proj1"
       key            = "terraform.tfstate"
       region         = "us-west-2"
       dynamodb_table = "dydb-terra-ravi-proj1"
     }
  
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
  
}



# Create a VPC
resource "aws_vpc" "terravpc" {
  cidr_block = "172.17.0.0/16"

  tags = {
    Name = "ravi_vpc"
    Project =	"Project-1"
  }
}

# Create public subnet 

resource "aws_subnet" "terravpc-pub1" {
  vpc_id = aws_vpc.terravpc.id
  cidr_block = "172.17.1.0/24"
  availability_zone = "us-west-2c"
  tags = {
    Name = "terravpc public1"
    Project =	"Project-1"
    }
}


resource "aws_subnet" "terravpc-pub2" {
  vpc_id = aws_vpc.terravpc.id
  cidr_block = "172.17.2.0/24"
  availability_zone = "us-west-2d"
  tags = {
    Name = "terravpc public2"
    Project =	"Project-1"
  }
}

# Create Pvt subnet

resource "aws_subnet" "terravpc-pvt1" {
  vpc_id = aws_vpc.terravpc.id
  cidr_block = "172.17.3.0/24"
  availability_zone = "us-west-2a"
  tags = {
    Nmae = "terravpc pvt-subnet1"
    Project =	"Project-1"
  }
}

resource "aws_subnet" "terravpc-pvt2" {
  vpc_id = aws_vpc.terravpc.id
  cidr_block = "172.17.4.0/24"
  availability_zone = "us-west-2b"
  tags = {
    Name = "terravpc pvt-subnet2"
    Project =	"Project-1"
  }
}

# Create Ineternet Gatway

resource "aws_internet_gateway" "igw_terra" {
  vpc_id = aws_vpc.terravpc.id
tags = {
  Name = "terrvpc internet GW"
  Project =	"Project-1"
}
}

###############################################################

resource "aws_route_table" "pub_rtb_proj1" {
vpc_id = aws_vpc.terravpc.id
route{
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw_terra.id
} 
tags = {
  Name = "public route table"
}
}
resource "aws_route_table_association" "rt_proj1-tb1" {
  subnet_id = aws_subnet.terravpc-pub1.id
  route_table_id = aws_route_table.pub_rtb_proj1.id
  }
resource "aws_route_table_association" "rt_proj1-tb2" {
  subnet_id = aws_subnet.terravpc-pub2.id
  route_table_id = aws_route_table.pub_rtb_proj1.id
  
}







##########################################################

# # Create  Route Table

# resource "aws_route_table" "public_route" {
#   vpc_id = aws_vpc.terravpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = "aws_internet_gateway.igw_terra.id"
#   }

#   tags = {
#     Name = "terravpc rt"
#     Project =	"Project-1"
#   }
# }



# resource "aws_route_table_association" "rt_proj1-tb1" {
#   subnet_id = aws_subnet.terravpc-pub1.id
#   route_table_id = aws_route_table.public_route.id
# }

# resource "aws_route_table_association" "rt_proj1-tb2" {
#   subnet_id = aws_subnet.terravpc-pub2.id
#   route_table_id = aws_route_table.public_route.id
# }

#### Nat IP

resource "aws_eip" "terra_nat_ip" {
 domain = "vpc"
}

#### Nat Gatway

resource "aws_nat_gateway" "terrvpc-nat-gw" {
  allocation_id = aws_eip.terra_nat_ip.id
  subnet_id  = aws_subnet.terravpc-pub2.id

  tags = {
    Name = "terravpc NAT GW"
    Project =	"Project-1"
  }
}

## Elastic IP for EC2

resource "aws_eip" "eip_ec2_proj1" {
  vpc = true
}

# create EC2 instance

resource "aws_instance" "terra_ec2_proj1" {
  ami = "ami-002829755fa238bfa"
  subnet_id = aws_subnet.terravpc-pub1.id
  instance_type = "t2.micro"

  tags = {
    Name = "terra_EC2 Proj1"
    Project =	"Project-1"

  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.terra_ec2_proj1.id
  allocation_id = aws_eip.eip_ec2_proj1.id
}

# Create Subnet for RDS

resource "aws_db_subnet_group" "db_subnet_terra_proj1" {
  name = "dbsubnetgrp"
  subnet_ids = [ aws_subnet.terravpc-pvt1.id, aws_subnet.terravpc-pvt2.id]
  tags =  {
    Name = "dbsubnet Proj1"
    Project =	"Project-1"
 }
} 

# create RDS 

resource "aws_db_instance" "terra_rds-proj1" {
    allocated_storage    = 20
    storage_type         = "gp2"
    engine               = "mysql"
    engine_version       = "5.7"
    instance_class       = "db.t3.small"
    db_name              = "mydb"
    username             = "terra"
    password             = "teraapass"
    multi_az             = false
    skip_final_snapshot  = true
    db_subnet_group_name = aws_db_subnet_group.db_subnet_terra_proj1.id
  
  tags = {
    Name = "Teraa RDS"
    Project =	"Project-1" 
  }
}








