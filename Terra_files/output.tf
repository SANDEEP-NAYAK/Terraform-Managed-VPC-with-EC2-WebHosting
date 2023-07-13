output "vpc_cidr" {
    value = var.vpc_cidr
}

output "public_subnet_cidr" {
    value = var.public_subnet
}

output "private_subnet_cidr" {
    value = var.private_subnet
}

output "public_EC2_public_ip"{
    value = aws_instance.public_ec2.public_ip
}

output "public_ec2_instanceType" {
    value = aws_instance.public_ec2.instance_type
}
