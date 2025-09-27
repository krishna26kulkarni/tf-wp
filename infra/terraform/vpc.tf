
resource "aws_vpc" "vpc" {
  for_each = var.regions
  provider = {
      aws = local.region_providers[each.key]
  }
  cidr_block = var.vpc_cidr_per_region[each.key]
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "${each.value}-vpc-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_subnet" "private" {
  for_each = var.regions
  provider = aws.${each.key}
  count = 3
  vpc_id = aws_vpc.vpc[each.key].id
  cidr_block = cidrsubnet(aws_vpc.vpc[each.key].cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available[each.key].names[count.index]
  tags = { Name = "${each.value}-private-${count.index}" }
}

# You probably want better subnet sizing — simplified here for example.
