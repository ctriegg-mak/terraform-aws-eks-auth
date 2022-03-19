locals {
  name = "ex-${replace(basename(path.cwd), "_", "-")}"
}

################################################################################
# EKS Module
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = ">= 18.0.0"

  cluster_name = local.name
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnets

  eks_managed_node_groups = {
    foo = {}
  }
}

################################################################################
# EKS Auth Module
################################################################################

module "eks_auth" {
  source = "../../"
  eks    = module.eks
}
