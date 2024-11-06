resource "aws_vpc" "sam-vpc" {
  cidr_block           = "10.124.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "first-vpc"
  }
}

resource "aws_subnet" "pub-subnet" {
  vpc_id                  = aws_vpc.sam-vpc.id
  cidr_block              = "10.124.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"
  tags = {
    Name = "first-public-subnet"
  }
}

resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.sam-vpc.id

  tags = {
    Name = "internet-gw"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.sam-vpc.id

  tags = {
    Name = "my-rt"
  }
}

resource "aws_route" "default-route" {
  route_table_id         = aws_route_table.public-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my-igw.id
}

resource "aws_route_table_association" "public-rt-assoc" {
  subnet_id      = aws_subnet.pub-subnet.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_security_group" "sam-sg" {
  name        = "my-sg"
  description = "My Security Group"
  vpc_id      = aws_vpc.sam-vpc.id

  ingress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "entry-auth" {
  key_name   = "bombay-key"
  public_key = file("C:/Users/sande/.ssh/id_rsa.pub")
}

resource "aws_instance" "new-ec2" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.server-ami.id
  key_name               = aws_key_pair.entry-auth.id
  vpc_security_group_ids = [aws_security_group.sam-sg.id]
  subnet_id              = aws_subnet.pub-subnet.id
  user_data              = file("ud.tpl")

  tags = {
    Name = "my-ec2-instance"
  }

  root_block_device {
    volume_size = 10
  }


  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-config.tpl", {
      hostname     = self.public_ip,
      USER         = "ubuntu",
      identityfile = "C:/Users/sande/.ssh/bombay-key"
    })
    interpreter = var.host_os == "windows" ? ["Powershell","-Command"] : ["bash","-c"]
  }
}
