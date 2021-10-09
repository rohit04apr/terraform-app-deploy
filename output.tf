// Use the endpoint to connect to application
output "alb_endpoint" {
  value = aws_lb.alb.arn
}