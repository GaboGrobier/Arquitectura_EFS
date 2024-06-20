output "alb_tf" {
    value = "http://${aws_lb.alb.dns_name}"
  
}
