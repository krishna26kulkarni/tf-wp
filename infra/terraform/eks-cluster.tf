# create provider aliases for each region
data "aws_availability_zones" "available" {
  for_each = var.regions
  provider = aws
  state = "available"
  # uses provider's region (but we will create provider alias per region)
}

# Create provider aliases
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "us-west-2"
  region = "us-west-2"
}

# Better: dynamically create providers using locals and for_each - simplified above.

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  for_each = var.regions
  providers = {
    aws = aws.${each.key}
  }

  cluster_name    = each.value
  cluster_version = var.cluster_k8s_version
  vpc_id          = aws_vpc.vpc[each.key].id
  subnet_ids      = aws_subnet.private[each.key.*].[*].id # this is conceptual
  # Node groups
  node_groups = {
    on_demand = {
      desired_capacity = 2
      max_capacity     = 4
      min_capacity     = 1
      instance_types   = ["t3.medium"]
    }
    spot = {
      desired_capacity = 1
      max_capacity     = 3
      min_capacity     = 0
      instance_types   = ["t3.medium"]
      capacity_type    = "SPOT"
    }
  }

  manage_aws_auth = true
  map_users = []
  map_roles = []
  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "local_file" "kubeconfigs" {
  for_each = toset(var.regions)
  content  = templatefile("${path.module}/kubeconfig.tpl", {
    cluster_name     = module.eks[each.key].cluster_name
    cluster_endpoint = module.eks[each.key].cluster_endpoint
    cluster_ca       = module.eks[each.key].cluster_certificate_authority_data
  })
  filename = "${path.module}/kubeconfig_${each.key}"
}

