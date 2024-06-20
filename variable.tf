variable "port-web" {
    description = "Puerto http para web"
    default = 80
    type = number
  
}

variable "ssh-port" {
    description = "puerto ssh "
    default = 22
    type = number
}
variable "IntanceType" {
    description = "tipo de instancia utilizado "
    default = "t2.micro"
    type = string
  
}

variable "anyip" {
    description = "Cualquier destino "
    default = "0.0.0.0/0"
    type = string
  
}
variable "EFS-port" {
    description = "puerto para EFS"
    default = 2049
    type = number
  
}
variable "amazon-linux" {
    description = "Ami de amazon linux x86"
    default = "ami-08a0d1e16fc3f61ea"
    type = string
}

variable "ubuntu" {
    description = "Ami de ubuntu x86"
    default = "ami-04b70fa74e45c3917"
    type = string
}

variable "region" {
  description = "Region utilizada"
  default = "us-east-1"
  type = string
}
