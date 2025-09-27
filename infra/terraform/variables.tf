variable "default_region" {
  type    = string
  default = "us-east-1"
}

variable "regions" {
  description = "Map of region => cluster_name"
  type = map(string)
  default = {
    "us-east-1" = "prod-eks-use1"
    "us-west-2" = "prod-eks-usw2"
  }
}

variable "cluster_k8s_version" {
  type    = string
  default = "1.32"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "vpc_cidr_per_region" {
  type = map(string)
  default = {
    "us-east-1" = "10.10.0.0/16"
    "us-west-2" = "10.20.0.0/16"
  }
}
