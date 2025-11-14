variable "region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "public_key_path" {
  description = "Path to your SSH public key"
}

variable "jenkins_port" {
  default = 8080
}
