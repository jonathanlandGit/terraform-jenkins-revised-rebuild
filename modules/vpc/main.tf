data "aws_availability_zones" "azs" {}

data "aws_vpc" "vpc" {
  cidr_block = "172.31.0.0/16"
}

data "aws_internet_gateway" "igw" {
  filter {
    name   = "attachment.vpc-id"
    values = [var.vpc_id]
  }
}

# resource "aws_subnet" "vpc_subnets" {
#   count                   = 2
#   vpc_id                  = var.vpc_id
#   cidr_block              = cidrsubnet(data.aws_vpc.vpc.cidr_block, 8, var.subnet_segment_start + count.index)
#   map_public_ip_on_launch = true
#   availability_zone       = data.aws_availability_zones.azs.names[count.index]

#   tags = {
#     Name = "${var.app}-${var.env}-subnet${count.index}"
#     App  = "${var.app}"
#     Env  = "${var.env}"
#   }
# }

data "aws_subnet" "vpc_subnets" {
  id = "subnet-34bcc152"
}

# resource "aws_default_network_acl" "acl" {
#   default_network_acl_id = var.vpc_id

#   ingress {
#     protocol   = -1
#     rule_no    = 100
#     action     = "allow"
#     cidr_block = "0.0.0.0/0"
#     from_port  = 0
#     to_port    = 0
#   }
#   egress {
#     protocol   = -1
#     rule_no    = 100
#     action     = "allow"
#     cidr_block = "0.0.0.0/0"
#     from_port  = 0
#     to_port    = 0
#   }

#   tags = {
#     Name = "${var.app}-${var.env}-acl"
#     App  = "${var.app}"
#     Env  = "${var.env}"
#   }
# }

resource "aws_default_route_table" "default_rt" {
  default_route_table_id = "rtb-a87367d6"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.igw.id
  }

  # tags = {
  #   Name = "${var.app}-${var.env}-default-rt"
  #   App  = "${var.app}"
  #   Env  = "${var.env}"
  # }
}
