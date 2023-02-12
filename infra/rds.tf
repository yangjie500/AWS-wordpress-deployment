resource "aws_security_group" "my_rds_sg" {
  name = "my-rds-sg"
  description = "Allow inbound TCP at Port 3306"
  vpc_id = aws_vpc.my_vpc.id
  ingress {
    description      = "Inbound port 3306"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_db_subnet_group" "my_rds_subnet" {
  name = "my_rds_subnet"
  subnet_ids = aws_subnet.my_subnet_private[*].id
}

resource "aws_db_instance" "my_rds" {
  instance_class = "db.t3.micro"
  allocated_storage = 5
  engine = "mysql"
  engine_version = "8.0"
  username = var.db_user
  password = var.db_password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot = true
  db_subnet_group_name = aws_db_subnet_group.my_rds_subnet.name
  vpc_security_group_ids = [aws_security_group.my_rds_sg.id]
  db_name = "wp_database"
}