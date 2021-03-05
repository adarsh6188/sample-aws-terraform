provider "aws" {
  region = "us-east-1"
  #Add your access key and secret key below
  access_key = ""
  secret_key = ""
}

resource "aws_vpc" "test_vpc" {
  cidr_block       = "10.0.0.0/16"
 

  tags = {
    Name = "terraform"
  }
}

resource "aws_subnet" "test_subnet" {
  vpc_id     = aws_vpc.test_vpc.id
  cidr_block = var.subnet_prefix[0]
  availability_zone = "us-east-1a"

  tags = {
    Name = "prod"
  }
}
resource "aws_subnet" "test_subnet2" {
  vpc_id     = aws_vpc.test_vpc.id
  cidr_block = var.subnet_prefix[1]
  availability_zone = "us-east-1b"

  tags = {
    Name = "dev"
  }
  
}
variable "subnet_prefix" {
  description = "cidr block for the subnet"
}

resource  "aws_internet_gateway" "igw"{
  vpc_id = aws_vpc.test_vpc.id
}

resource "aws_route_table" "prod" {
  vpc_id = aws_vpc.test_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "prod"
  }
}

resource "aws_route_table_association" "asso" {
  subnet_id      = aws_subnet.test_subnet.id
  route_table_id = aws_route_table.prod.id
}

resource "aws_security_group" "web_server" {
  name        = "allow_web"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.test_vpc.id

  ingress {
    description = "https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
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
    Name = "webserver"
  }
}

resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.test_subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.web_server.id]

}

resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on =  [ aws_internet_gateway.igw ] 
}
 


 resource "aws_instance" "test" {
   ami           = "ami-00ddb0e5626798373"
   instance_type = "t2.micro"
   availability_zone = "us-east-1a"
   key_name = ""
   # Enter the .pem file name

 tags = {
     Name = "HelloWorld"
     terraform = "terraform-ec2"
     }
     network_interface {
       device_index = 0
       network_interface_id = aws_network_interface.web-server-nic.id
     }
   user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo bash -c 'echo test web > /var/www/html/index.html'
                EOF

} 
  output "server_public_ip" {
        value = aws_eip.one.public_ip  #This is used to show the public IP of the newly created instance when the execution is finished
   }
