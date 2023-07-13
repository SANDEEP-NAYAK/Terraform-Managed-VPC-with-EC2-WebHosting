# Create a VPC
resource "aws_vpc" "proj_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "proj-VPC"
  }
}

#create public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.proj_vpc.id
  cidr_block = var.public_subnet
  availability_zone = "us-east-1a"

  tags = {
    Name = "Public subnet"
  }
}

#create private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.proj_vpc.id
  cidr_block = var.private_subnet
  availability_zone = "us-east-1b"
  tags = {
    Name = "Private subnet"
  }
}

#create IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.proj_vpc.id

  tags = {
    Name = "proj_vpc_igw"
  }
}

#public route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.proj_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_rt"
  }
}

resource "aws_route_table_association" "public_rt-public_subnet" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_eip" "lb" {

  domain   = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "NAT in public_subnet"
  }

  depends_on = [aws_internet_gateway.igw]
}

#private route table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.proj_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "private_rt"
  }
}

resource "aws_route_table_association" "private_rt-private_subnet" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_security_group" "allow_all" {
  name        = "allow everthing"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.proj_vpc.id

  ingress {
    description      = "SSH"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "public_ec2 group"
  }
}

#creating an ec2 instance in public subnet
resource "aws_instance" "public_ec2" {
  ami           = var.publicEC2_ami
  instance_type = var.public_ec2_instanceType
  key_name =      var.key-name
  subnet_id = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.allow_all.id]
 
  root_block_device {
    volume_size = var.root_vol_size
    delete_on_termination = true
    volume_type = "gp2"

    tags = {
      Name = "Root Volume of Public Subnet"
    }
  }

  tags = {
    Name = "web-server"
  }
}

resource "null_resource" "remote_exec" {

  depends_on = [ aws_instance.public_ec2 ]
   connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("D:\\AWS Masters\\pem files\\master.pem")
      host        = aws_instance.public_ec2.public_ip
    }

    provisioner "remote-exec" {
    inline = [
      "sudo yum update",
      "sudo yum install httpd -y",
      "sudo systemctl start httpd",
      "sudo yum install git -y",
      "cd /",
      "sudo git clone https://github.com/SANDEEP-NAYAK/Terraform-Yoga-Project.git ",
      "sudo cp -r Terraform-Yoga-Project/* /var/www/html/"
    ]   
  }

}