output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "nat_gateway_ids" {
  value = module.vpc.natgw_ids
}

output "route_table_ids" {
  value = {
    public  = module.vpc.public_route_table_ids
    private = module.vpc.private_route_table_ids
  }
}
output "vpc_endpoint_ids" {
  value = {
    s3 = aws_vpc_endpoint.s3.id
  }
}