provider "aws" {
    region = var.region
  
}

#Ability zone 
data "aws_vpc" "default_vpc" {
    default = true
  
}
data "aws_subnet" "az-1" {
    availability_zone = "${var.region}a"
  
}
data "aws_subnet" "az-2" {
    availability_zone = "${var.region}b"
  
}
data "aws_subnet" "az-3" {
    availability_zone = "${var.region}c"
  
}

# building Security group 
resource "aws_security_group" "instancias" {
    name = "intancias"
    vpc_id = data.aws_vpc.default_vpc.id
    ingress {
        security_groups=[aws_security_group.internet.id]
        to_port=var.port-web
        from_port=var.port-web
        protocol="TCP"

    }
    ingress {
        cidr_blocks = [ var.anyip ]
        to_port = var.ssh-port
        from_port = var.ssh-port
        protocol = "TCP"
    }
    egress {
        cidr_blocks = [var.anyip]
        from_port = 0
        to_port = 0
        protocol = "-1"
    }
  
}
resource "aws_security_group" "EFS" {
    name = "EFS_SG"
    vpc_id = data.aws_vpc.default_vpc.id
    ingress  {
        security_groups = [ aws_security_group.instancias.id ]
        to_port = var.EFS-port
        from_port = var.EFS-port
        protocol="TCP"
    }
    egress {
        cidr_blocks=[var.anyip]
        from_port = 0
        to_port = 0
        protocol = "-1"
    }
  
}
resource "aws_security_group" "internet" {
    name = "acceso a internet "
    vpc_id = data.aws_vpc.default_vpc.id
    ingress {
            cidr_blocks=[var.anyip]
            to_port=var.port-web
            from_port=var.port-web
            protocol="TCP"
    }
    egress{
        cidr_blocks = [ var.anyip ]
        from_port = 0
        to_port = 0
        protocol = "-1"
    }
}


resource "aws_efs_file_system" "efs_web" {
    availability_zone_name = "${var.region}a"

    tags = {
      Name = "EFS-web"
    }
  
}

resource "aws_efs_mount_target" "instancias" {
    file_system_id = aws_efs_file_system.efs_web.id
    subnet_id = data.aws_subnet.az-1.id
    security_groups = [ aws_security_group.EFS.id ]
  
}


#instance building 
resource "aws_instance" "intancia1" {
    ami = var.amazon-linux
    instance_type = var.IntanceType
    vpc_security_group_ids = [aws_security_group.instancias.id]
    subnet_id = data.aws_subnet.az-1.id
    user_data = <<-EOF
            #!/bin/bash
            yum update 
            yum upgrade
            yum install httpd -y 
            sudo systemctl start httpd 
            sudo systemctl enable httpd 
            echo "${aws_efs_file_system.efs_web.dns_name}:/ /var/www/html nfs4" >> /etc/fstab
            sudo mount -t efs ${aws_efs_file_system.efs_web.dns_name}:/ /var/www/html 
            sudo mount -a
            EOF
    associate_public_ip_address = true
    tags = {
      Name = "servidor-1"
    }
  
}


resource "aws_instance" "instacia2" {
    ami= var.amazon-linux
    instance_type = var.IntanceType
    vpc_security_group_ids = [aws_security_group.instancias.id]
    subnet_id = data.aws_subnet.az-1.id
        user_data = <<-EOF
            #!/bin/bash
            yum update 
            yum upgrade
            yum install httpd -y 
            sudo systemctl start httpd 
            sudo systemctl enable httpd 
            echo "${aws_efs_file_system.efs_web.dns_name}:/ /var/www/html nfs4" >> /etc/fstab
            sudo mount -t efs ${aws_efs_file_system.efs_web.dns_name}:/ /var/www/html 
            sudo mount -a 
            EOF
    associate_public_ip_address = true

  tags = {
    Name = "servidor-2"
  }
}

resource "aws_lb" "alb" {
    name = "alb-terraform"
    load_balancer_type = "application"
    security_groups = [ aws_security_group.internet.id ]
    subnets = [ data.aws_subnet.az-1.id ,data.aws_subnet.az-2.id,data.aws_subnet.az-3.id]
}

resource "aws_lb_target_group" "grupo-destino" {
    name = "grupo-destino-alb"
    port = var.port-web
    protocol = "HTTP"
    vpc_id = data.aws_vpc.default_vpc.id

    health_check {
      enabled = true
      matcher = "200"
      path = "/"
      port = var.port-web
      protocol = "HTTP"
    }
}

resource "aws_lb_target_group_attachment" "instancia1" {
    target_group_arn = aws_lb_target_group.grupo-destino.arn
    target_id =  aws_instance.intancia1.id
    port = var.port-web
  
}
resource "aws_lb_target_group_attachment" "instacia2" {
    target_id = aws_instance.instacia2.id
    target_group_arn = aws_lb_target_group.grupo-destino.arn
    port = var.port-web
  
}
resource "aws_alb_listener" "agente_escucha" {
    load_balancer_arn = aws_lb.alb.arn
    port = var.port-web

    default_action {
      target_group_arn = aws_lb_target_group.grupo-destino.arn
      type = "forward"
    }
  
}


