resource "aws_instance" "rhel" {
  ami           = "ami-096fda3c22c1c990a"
  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.generated_key.key_name}"
  vpc_security_group_ids = [aws_security_group.ab_sg.id]
  tags = {
    Name        = "terraform_instance"
  }
}

output "myEC2IP" { 
  value = "${aws_instance.rhel.public_ip}"
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "mykey1"
  public_key = tls_private_key.example.public_key_openssh

provisioner "local-exec" { # Create "myKey.pem" to your computer!!
    command = "echo '${tls_private_key.example.private_key_pem}' > ./myKey.pem"
  }
}

resource "aws_security_group" "ab_sg" {
  name        = "allow_ssh"
  vpc_id      = "vpc-0ce999ece68c5aa40"
  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
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
  tags = {
    Name = "allow_ssh"
  }
}



