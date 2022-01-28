output "private_subnets" {
  value = aws_subnet.private
}

output "public_subnets" {
  value = aws_subnet.public
}

output "internet_access_subnets" {
  value = aws_subnet.internet_access
}

output "vpc" {
  value = aws_vpc.this
}
