resource "aws_vpc_peering_connection" "default" {
  count = var.is_peering_required ? 1 : 0  # "?" stands for 'TRUE' ":" for 'FALSE'
  peer_vpc_id   = data.aws_vpc.default.id # accepter of the VPC
  vpc_id        = aws_vpc.main.id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  auto_accept = true

  tags = merge(
    var.vpc_tags,
    local.comman_tags,

    {
        Name = "${local.comman_name_suffix}-default"
    }
  )
}

resource "aws_route" "public_peering" {
  count = var.is_peering_required ? 1 :0  
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id # we should use "default.index" whenever we're calling the values as a "LIST"
}

resource "aws_route" "default_peering" {
  count = var.is_peering_required ? 1 :0  
  route_table_id            = data.aws_route_table.main.id
  destination_cidr_block    = var.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id # we should use "default.index" whenever we're calling the values as a "LIST"
}