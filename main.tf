resource "aws_vpc" "default_vpc" {  # default vpc
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "default_subnet" {
  vpc_id = aws_vpc.default_vpc.id
  cidr_block = "10.0.1.0/24"

  availability_zone = "ap-southeast-1a"

  tags = {
    Name = "default_subnet"
  }
}

resource "aws_internet_gateway" "default_gateway" {
  vpc_id = aws_vpc.default_vpc.id

  tags = {
    Name = "default_gateway"
  }
}

resource "aws_route_table" "default_route" {
  vpc_id = aws_vpc.default_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default_gateway.id
  }

  tags = {
    Name = "default_route"
  }
}

resource "aws_route_table_association" "main" {
  subnet_id = aws_subnet.default_subnet.id
  route_table_id = aws_route_table.default_route.id
}

resource "aws_security_group" "instance" {
  vpc_id = aws_vpc.default_vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 2377
    to_port = 2377
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  
  ingress {
    from_port = 6443
    to_port = 6443
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "instance_sg"
  }
}

resource "aws_instance" "k8s_nodes" {
  for_each = {
    node_1 = "t2.micro"
    node_2 = "t3.small"
    node_3 = "t2.micro"
    node_4 = "t2.micro"
  }
  ami = "ami-060e277c0d4cce553"
  instance_type = each.value
  subnet_id = aws_subnet.default_subnet.id
  security_groups = [aws_security_group.instance.id]
  associate_public_ip_address = true
  key_name = "docker-swarm-ubuntu"

  tags = {
    Name = "k8s-node-${each.key}"
  }
  
  depends_on = [ aws_security_group.instance ]
}
