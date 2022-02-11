output "vpc_id" {
  value = data.aws_vpc.vpc.id
}

output "subnets" {
  value = data.aws_subnet.vpc_subnets.*.id
}
