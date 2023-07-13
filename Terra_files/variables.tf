variable "vpc_cidr" {
    description = "This is the new vpc created specifically for the project purpose only"
    type = string
}

variable "public_subnet" {
    description = "Public subnet for proj-VPC"
    type =  string
}


variable "private_subnet" {
    description = "Private subnet for proj-VPC"
    type =  string
}

variable "publicEC2_ami" {
    description = "ami used in public EC2"
    type = string
}

variable "public_ec2_instanceType" {
    description = "Public EC2 instance type"
    type = string
}

variable "key-name" {
    description = "Key pair to login to instance"
    type = string
}

variable "root_vol_size" {
    description = "customized size of root volume"
    type = number
  
}