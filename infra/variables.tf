variable "azs" {
  description = "US East Availablility Zones"
  type = list(string)
  default = [ "us-east-1a", "us-east-1b", "us-east-1c" ]
}

variable "public_subnet_cidr" {
  description = "public_subnet_IPaddresses"
  type = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "private_subnet_cidr" {
  description = "private_subnet_IPaddresses"
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "EC2_type" {
  description = "EC2_instance_type"
  type = string
  default = "t2.micro"
}

variable "S3_name" {
  description = "S3 name"
  type = string
  default = "my-ansible-bucket500"
}

variable "db_user" {
  description = "MySQL user"
  type = string
  default = "admin123"
}

variable "db_password" {
  description = "MySQL password"
  type = string
  default = "adminweewee123"
  sensitive = true
}

