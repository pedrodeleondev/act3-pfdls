provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "vpc_act3_pfdls" {
  cidr_block           = "10.10.0.0/20"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "act3-vpc-pfdls"
  }
}

# Subred pública
resource "aws_subnet" "subred_publica_act3_pfdls" {
  vpc_id                  = aws_vpc.vpc_act3_pfdls.id
  cidr_block              = "10.10.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "act3-subred-publica-pfdls"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw_act3_pfdls" {
  vpc_id = aws_vpc.vpc_act3_pfdls.id
  tags = {
    Name = "act3-gateway-pfdls"
  }
}

# Tabla de rutas
resource "aws_route_table" "rt_publica_act3_pfdls" {
  vpc_id = aws_vpc.vpc_act3_pfdls.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_act3_pfdls.id
  }

  tags = {
    Name = "act3-rt-publica-pfdls"
  }
}

# Asociación de tabla de rutas
resource "aws_route_table_association" "asociacion_rt_act3_pfdls" {
  subnet_id      = aws_subnet.subred_publica_act3_pfdls.id
  route_table_id = aws_route_table.rt_publica_act3_pfdls.id
}
# Security Group para Jump Server
resource "aws_security_group" "sg_jump_act3_pfdls" {
  name        = "act3-sg-jump-pfdls"
  description = "Permitir SSH desde internet - PFDLS"
  vpc_id      = aws_vpc.vpc_act3_pfdls.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "act3-sg-jump-pfdls"
  }
}
# Security Group para Web Servers
resource "aws_security_group" "sg_web_act3_pfdls" {
  name        = "act3-sg-web-pfdls"
  description = "Permitir HTTP publico y SSH desde Jump - PFDLS"
  vpc_id      = aws_vpc.vpc_act3_pfdls.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_jump_act3_pfdls.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "act3-sg-web-pfdls"
  }
}

# Jump Server
resource "aws_instance" "jump_act3_pfdls" {
  ami                         = "ami-084568db4383264d4"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subred_publica_act3_pfdls.id
  key_name                    = "vockey"
  vpc_security_group_ids      = [aws_security_group.sg_jump_act3_pfdls.id]
  associate_public_ip_address = true

  tags = {
    Name = "act3-jump-server-pfdls"
  }
}

# Web Servers (x3)
resource "aws_instance" "web_act3_pfdls" {
  count                       = 3
  ami                         = "ami-084568db4383264d4"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subred_publica_act3_pfdls.id
  key_name                    = "vockey"
  vpc_security_group_ids      = [aws_security_group.sg_web_act3_pfdls.id]
  associate_public_ip_address = true

  tags = {
    Name = "act3-web-server-${count.index + 1}-pfdls"
  }
}