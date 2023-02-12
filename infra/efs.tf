resource "aws_security_group" "my_efs_sg" {
  name = "Allow NFS"
  description = "Allow NFS network in"
  vpc_id = aws_vpc.my_vpc.id
  ingress {
    from_port = 2049
    to_port = 2049
    protocol = "tcp"
    security_groups = ["${aws_security_group.allow_tls.id}"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_efs_file_system" "my-efs" {
  creation_token = "my-efs"
  encrypted = false
  performance_mode = "generalPurpose"
  tags = {
    Name = "my-efs"
  }
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
}

resource "aws_efs_mount_target" "name" {
  count = length(var.private_subnet_cidr)
  file_system_id = aws_efs_file_system.my-efs.id
  subnet_id = element(aws_subnet.my_subnet_public[*].id, count.index)
  security_groups = [aws_security_group.my_efs_sg.id]
}

