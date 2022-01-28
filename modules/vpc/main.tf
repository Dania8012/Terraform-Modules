terraform {
  required_version = ">= 0.15.5" # introduction of Local Values configuration language feature
}

locals {
  #max_subnet_length = "${max(length(var.private_subnets), length(var.private_subnets), length(var.internet_access_subnets))}"
  nat_gateway_count = 1

  # Use `local.vpc_id` to give a hint to Terraform that subnets should be deleted before secondary CIDR blocks can be free!
  vpc_id = aws_vpc.this[0].id
}

######
# VPC
######
resource "aws_vpc" "this" {
  count = var.create_vpc ? 1 : 0

  cidr_block                       = var.cidr
  instance_tenancy                 = var.instance_tenancy
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_dns_support               = var.enable_dns_support
  assign_generated_ipv6_cidr_block = var.assign_generated_ipv6_cidr_block

  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tags,
    var.vpc_tags,
  )
}

resource "aws_vpc_ipv4_cidr_block_association" "this" {
  count = var.create_vpc && length(var.secondary_cidr_blocks) > 0 ? length(var.secondary_cidr_blocks) : 0

  vpc_id = local.vpc_id

  cidr_block = element(var.secondary_cidr_blocks, count.index)
}

###################
# DHCP Options Set
###################
resource "aws_vpc_dhcp_options" "this" {
  count = var.create_vpc && var.enable_dhcp_options ? 1 : 0

  domain_name          = var.dhcp_options_domain_name
  domain_name_servers  = var.dhcp_options_domain_name_servers
  ntp_servers          = var.dhcp_options_ntp_servers
  netbios_name_servers = var.dhcp_options_netbios_name_servers
  netbios_node_type    = var.dhcp_options_netbios_node_type

  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tags,
    var.dhcp_options_tags,
  )
}

###############################
# DHCP Options Set Association
###############################
resource "aws_vpc_dhcp_options_association" "this" {
  count = var.create_vpc && var.enable_dhcp_options ? 1 : 0

  vpc_id          = local.vpc_id
  dhcp_options_id = aws_vpc_dhcp_options.this[0].id
}

###################
# Internet Gateway
###################
resource "aws_internet_gateway" "this" {
  #count = 1

  vpc_id = local.vpc_id

  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tags,
    var.igw_tags,
  )
}

################
# Publiс routes
################
resource "aws_route_table" "public" {
  #count = 1

  vpc_id = local.vpc_id

  tags = merge(
    {
      "Name" = format("%s-${var.public_subnet_suffix}", (var.subnet_prefix))
    },
    var.tags,
    var.public_route_table_tags,
  )
}


# Internet Gateway Routing
resource "aws_route" "public_internet_gateway" {
  #count = 1

  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id

  timeouts {
    create = "5m"
  }
}

#################
# Private routes
# There are so many routing tables as the largest amount of subnets of each type (really?)
#################
resource "aws_route_table" "private" {
  vpc_id = local.vpc_id
  tags = merge(
    {
      "Name" = format("%s-${var.private_subnet_suffix}", (var.subnet_prefix))
    },
    var.tags,
    var.private_route_table_tags,
  )
}


#################
# Internet_Access routes
#################
resource "aws_route_table" "internet_access" {
  count  = var.enable_nat_gateway ? 1 : 0
  vpc_id = local.vpc_id
  tags = merge(
    {
      "Name" = format("%s-${var.internet_access_subnet_suffix}", (var.subnet_prefix))
    },
    var.tags,
    var.internet_access_route_table_tags,
  )
}

################
# Public subnet
################
resource "aws_subnet" "public" {
  count = var.create_vpc && length(var.public_subnets) > 0 && false == var.one_nat_gateway_per_az || length(var.public_subnets) >= length(var.azs) ? length(var.public_subnets) : 0

  vpc_id                  = local.vpc_id
  cidr_block              = element(concat(var.public_subnets, [""]), count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    {
      "Name" = format(
        "%s-${var.public_subnet_suffix}",
        #var.name,
        var.subnet_prefix,
      )
    },
    var.tags,
    var.public_subnet_tags,
  )
}

#################
# Private subnets
#################
resource "aws_subnet" "private" {
  count = var.create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  vpc_id = local.vpc_id
  #cidr_block        = var.private_subnets[count.index]
  cidr_block        = element(concat(var.private_subnets, [""]), count.index)
  availability_zone = element(var.azs, count.index)

  tags = merge(
    {
      "Name" = format(
        "%s-${var.private_subnet_suffix}",
        #var.name,
        var.subnet_prefix,
      )
    },
    var.tags,
    var.private_subnet_tags,
  )
}


##################
# Internet_Access subnet
##################
resource "aws_subnet" "internet_access" {
  count = var.create_vpc && var.enable_nat_gateway && length(var.internet_access_subnets) > 0 ? length(var.internet_access_subnets) : 0

  vpc_id = local.vpc_id
  #cidr_block        = var.internet_access_subnets[count.index]
  cidr_block        = element(concat(var.internet_access_subnets, [""]), count.index)
  availability_zone = element(var.azs, count.index)

  tags = merge(
    {
      "Name" = format(
        "%s-${var.internet_access_subnet_suffix}",
        #var.name,
        var.subnet_prefix,
      )
    },
    var.tags,
    var.internet_access_subnet_tags,
  )
}


##############
# NAT Gateway
##############
# Workaround for interpolation not being able to "short-circuit" the evaluation of the conditional branch that doesn't end up being used
# Source: https://github.com/hashicorp/terraform/issues/11566#issuecomment-289417805
#
# The logical expression would be
#
#    nat_gateway_ips = var.reuse_nat_ips ? var.external_nat_ip_ids : aws_eip.nat.*.id
#
# but then when count of aws_eip.nat.*.id is zero, this would throw a resource not found error on aws_eip.nat.*.id.
locals {
  nat_gateway_ips = split(
    ",",
    var.reuse_nat_ips ? join(",", var.external_nat_ip_ids) : join(",", aws_eip.nat.*.id),
  )
}

resource "aws_eip" "nat" {
  count = var.create_vpc && var.enable_nat_gateway && false == var.reuse_nat_ips ? local.nat_gateway_count : 0

  vpc = true

  tags = merge(
    {
      "Name" = format(
        "%s-%s",
        var.name,
        element(var.azs, var.single_nat_gateway ? 0 : count.index),
      )
    },
    var.tags,
    var.nat_eip_tags,
  )
}

resource "aws_nat_gateway" "this" {
  count = var.create_vpc && var.enable_nat_gateway ? local.nat_gateway_count : 0

  allocation_id = element(
    local.nat_gateway_ips,
    var.single_nat_gateway ? 0 : count.index,
  )
  subnet_id = element(
    aws_subnet.public.*.id,
    var.single_nat_gateway ? 0 : count.index,
  )

  tags = merge(
    {
      "Name" = format(
        "%s-%s",
        var.name,
        element(var.azs, var.single_nat_gateway ? 0 : count.index),
      )
    },
    var.tags,
    var.nat_gateway_tags,
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route" "internet_access_nat_gateway" {
  count                  = var.create_vpc && var.enable_nat_gateway ? local.nat_gateway_count : 0
  route_table_id         = aws_route_table.internet_access[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id

  timeouts {
    create = "5m"
  }
}

######################
# VPC Endpoint for S3
######################
data "aws_vpc_endpoint_service" "s3" {
  count = var.create_vpc && var.enable_s3_endpoint ? 1 : 0

  service = "s3"
}

resource "aws_vpc_endpoint" "s3" {
  count = var.create_vpc && var.enable_s3_endpoint ? 1 : 0

  vpc_id       = local.vpc_id
  service_name = data.aws_vpc_endpoint_service.s3[0].service_name
}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  count = var.create_vpc && var.enable_s3_endpoint ? local.nat_gateway_count : 0

  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = element(aws_route_table.private.*.id, count.index)
}

resource "aws_vpc_endpoint_route_table_association" "internet_access_s3" {
  count = var.create_vpc && var.enable_nat_gateway && var.enable_s3_endpoint && length(var.internet_access_subnets) > 0 ? 1 : 0

  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = element(aws_route_table.internet_access.*.id, 0)
}

resource "aws_vpc_endpoint_route_table_association" "public_s3" {
  count = var.create_vpc && var.enable_s3_endpoint && length(var.public_subnets) > 0 ? 1 : 0

  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
  route_table_id  = aws_route_table.public.id
}

##########################
# Route table association
##########################
# Production
resource "aws_route_table_association" "private" {
  count = var.create_vpc && length(var.subnet_prefix) > 0 ? length(var.subnet_prefix) : 0

  subnet_id = element(aws_subnet.private.*.id, count.index)

  #route_table_id = "${element(aws_route_table.private.*.id, (var.single_nat_gateway ? 0 : count.index))}"
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "internet_access" {
  count = var.create_vpc && var.enable_nat_gateway && length(var.internet_access_subnets) > 0 ? length(var.internet_access_subnets) : 0

  subnet_id      = element(aws_subnet.internet_access.*.id, count.index)
  route_table_id = aws_route_table.internet_access[0].id
  #route_table_id = "${element(coalescelist(aws_route_table.internet_access.*.id, aws_route_table.private.*.id), (var.single_nat_gateway || var.create_internet_access_subnet_route_table ? 0 : count.index))}"
}

resource "aws_route_table_association" "public" {
  count = var.create_vpc && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

##############
# Network ACLs
##############

resource "aws_network_acl" "public" {
  vpc_id     = local.vpc_id
  subnet_ids = aws_subnet.public.*.id
  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "public"
  }
}


resource "aws_network_acl" "internet_access" {
  vpc_id     = local.vpc_id
  subnet_ids = aws_subnet.internet_access.*.id
  count      = var.enable_nat_gateway ? 1 : 0

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "internet_access"
  }
}

resource "aws_network_acl" "private" {
  vpc_id     = local.vpc_id
  subnet_ids = aws_subnet.private.*.id

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "private"
  }
}

##############
# VPN Gateway
##############
resource "aws_vpn_gateway" "this" {
  count = var.create_vpc && var.enable_vpn_gateway ? 1 : 0

  vpc_id          = local.vpc_id
  amazon_side_asn = var.amazon_side_asn

  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tags,
    var.vpn_gateway_tags,
  )
}

resource "aws_vpn_gateway_attachment" "this" {
  count = var.vpn_gateway_id != "" ? 1 : 0

  vpc_id         = local.vpc_id
  vpn_gateway_id = var.vpn_gateway_id
}

resource "aws_vpn_gateway_route_propagation" "public" {
  count = var.create_vpc && var.propagate_public_route_tables_vgw && var.enable_vpn_gateway || var.vpn_gateway_id != "" ? 1 : 0

  route_table_id = element(aws_route_table.public.*.id, count.index)
  vpn_gateway_id = element(
    concat(
      aws_vpn_gateway.this.*.id,
      aws_vpn_gateway_attachment.this.*.vpn_gateway_id,
    ),
    count.index,
  )
}

resource "aws_vpn_gateway_route_propagation" "private" {
  count = var.create_vpc && var.propagate_private_route_tables_vgw && var.enable_vpn_gateway || var.vpn_gateway_id != "" ? length(var.subnet_prefix) : 0

  route_table_id = element(aws_route_table.private.*.id, count.index)
  vpn_gateway_id = element(
    concat(
      aws_vpn_gateway.this.*.id,
      aws_vpn_gateway_attachment.this.*.vpn_gateway_id,
    ),
    count.index,
  )
}

###########
# Defaults
###########
resource "aws_default_vpc" "this" {
  count = var.manage_default_vpc ? 1 : 0

  enable_dns_support   = var.default_vpc_enable_dns_support
  enable_dns_hostnames = var.default_vpc_enable_dns_hostnames
  enable_classiclink   = var.default_vpc_enable_classiclink

  tags = merge(
    {
      "Name" = format("%s", var.default_vpc_name)
    },
    var.tags,
    var.default_vpc_tags,
  )
}
