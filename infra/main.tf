provider "aws" {
  region = var.region
}

# --- SSH KEY ---
resource "aws_key_pair" "devops_key" {
  key_name   = "devops-key"
  public_key = file(var.public_key_path)
}

# --- SECURITY GROUP FOR JENKINS ---
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow Jenkins + SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.jenkins_port
    to_port     = var.jenkins_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- SECURITY GROUP FOR APP ---
resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Allow App traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
}

# --- EC2 FOR JENKINS ---
resource "aws_instance" "jenkins" {
  ami                    = "ami-0ecb62995f68bb549" # Ubuntu 22 LTS us-east-1
  instance_type          = var.instance_type
  key_name               = aws_key_pair.devops_key.key_name
  security_groups        = [aws_security_group.jenkins_sg.name]
  associate_public_ip_address = true

  user_data = file("jenkins-userdata.sh")

  tags = {
    Name = "jenkins-server"
  }
}

# --- EC2 FOR APP ---
resource "aws_instance" "app" {
  ami                    = "ami-0ecb62995f68bb549"
  instance_type          = var.instance_type
  key_name               = aws_key_pair.devops_key.key_name
  security_groups        = [aws_security_group.app_sg.name]
  associate_public_ip_address = true

  tags = {
    Name = "app-server"
  }
}
