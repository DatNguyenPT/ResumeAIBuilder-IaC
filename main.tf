# Backend
module "pre-backend" {
  source = "./backend/pre-setup"
}

module "backend" {
  source = "./backend"
}

#####################################################################################################
# VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "datnguyen-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]  
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"] 
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"] 

  enable_nat_gateway = true
  single_nat_gateway = true  # Set to true for cost savings

  tags = {
    Terraform   = "true"
    Environment = "development"
  }
}
#####################################################################################################
#SG
# module "vpc_security_groups" {
#   source = "./modules/security-groups"
#   security_group_type = "vpc"
#   vpc_id = module.vpc.vpc_id 
# }

# module "instance_security_groups" {
#   source = "./modules/security-groups"

#   security_group_type     = "instance"
#   vpc_id                  = module.vpc.vpc_id
#   enabled_security_groups = ["jenkins", "jenkins_worker", "sonarqube", "database", "monitoring"]
# }

module "security_group" {
  source = "./modules/security-groups"
  vpc_id = module.vpc.vpc_id
}


#####################################################################################################
# INTERNET GATEWAY
# module "igw" {
#   source = "./modules/igw"
#   depends_on = [module.vpc]
#   vpc_id            = module.vpc.vpc_id
#   public_subnet_ids = module.vpc.public_subnets
#   route_table_name  = "Public Route Table"
#   igw_name          = "datnguyen-igw"
#   tags              = {
#     Environment = "dev"
#     Name        = "datnguyen-igw"
#   }
# }

#####################################################################################################
# EC2
module "jenkins_master" {
  source           = "./modules/ec2"
  vpc_id = module.vpc.vpc_id
  ami_id           = "ami-05778ef68e10b91d7"
  instance_type    = "t2.medium"
  key_name         = "instance-keypair"
  subnet_id = module.vpc.public_subnets[0]
  #public_subnet_ids = module.vpc.public_subnets
  sg_name          = module.security_group.security_groups["jenkins-sg"]
  instance_name    = "jenkins-master"
  volume_size      = 80
  user_data_script = "${path.root}/scriptfiles/jenkins_setup.sh"
  tags             = {
    Environment = "dev",
    Role        = "CI"
    Name = "jenkins-master"
  }
}

module "jenkins_worker" {
  source           = "./modules/ec2"
  vpc_id = module.vpc.vpc_id
  ami_id           = "ami-05778ef68e10b91d7"
  instance_type    = "t2.medium"
  key_name         = "instance-keypair"
  subnet_id = module.vpc.public_subnets[0]
  #public_subnet_ids = module.vpc.public_subnets
  sg_name          = module.security_group.security_groups["jenkins-sg"]
  instance_name    = "jenkins-worker"
  volume_size      = 80
  user_data_script = "${path.root}/scriptfiles/jenkins_setup.sh"
  tags             = {
    Environment = "dev",
    Role        = "CI"
    Name = "jenkins-worker"
  }
}

module "sonarqube_server" {
  source           = "./modules/ec2"
  vpc_id = module.vpc.vpc_id
  ami_id           = "ami-05778ef68e10b91d7"
  instance_type    = "t2.medium"
  key_name         = "instance-keypair"
  subnet_id = module.vpc.public_subnets[0]
  #public_subnet_ids = module.vpc.public_subnets
  sg_name          = module.security_group.security_groups["sonarqube-sg"]
  instance_name    = "sonarqube"
  volume_size      = 30
  tags             = {
    Environment = "dev",
    Role        = "QA"
    Name = "sonarqube"
  }
}

module "database_server" {
  source           = "./modules/ec2"
  vpc_id = module.vpc.vpc_id
  ami_id           = "ami-05778ef68e10b91d7"
  instance_type    = "t2.medium"
  key_name         = "instance-keypair"
  subnet_id = module.vpc.public_subnets[0]
  #public_subnet_ids = module.vpc.private_subnets
  sg_name          = module.security_group.security_groups["database-sg"]
  instance_name    = "database"
  volume_size      = 30
  tags             = {
    Environment = "dev",
    Role        = "DB"
    Name = "database"
  }
}

module "monitoring_server" {
  source           = "./modules/ec2"
  vpc_id = module.vpc.vpc_id
  ami_id           = "ami-05778ef68e10b91d7"
  instance_type    = "t2.medium"
  key_name         = "instance-keypair"
  subnet_id = module.vpc.public_subnets[0]
  #public_subnet_ids = module.vpc.public_subnets
  sg_name          = module.security_group.security_groups["monitoring-sg"]
  instance_name    = "monitoring"
  volume_size      = 80
  user_data_script = "${path.root}/scriptfiles/prometheus_grafana.sh"
  tags             = {
    Environment = "dev",
    Role        = "Monitoring"
    Name = "monitoring"
  }
}

#####################################################################################################
# EIP
module "jenkins_master_eip" {
  depends_on = [module.jenkins_master]
  source      = "./modules/eip"
  instance_id = module.jenkins_master.instance_id
  tags = {
    Name = "Jenkins Master EIP"
  }
}

module "jenkins_worker_eip" {
  depends_on = [module.jenkins_worker]
  source      = "./modules/eip"
  instance_id = module.jenkins_worker.instance_id
  tags = {
    Name = "Jenkins Worker EIP"
  }
}

module "sonarqube_server_eip" {
  depends_on = [module.sonarqube_server]
  source      = "./modules/eip"
  instance_id = module.sonarqube_server.instance_id
  tags = {
    Name = "Sonarqube Server EIP"
  }
}

module "database_server_eip" {
  depends_on = [module.database_server]
  source      = "./modules/eip"
  instance_id = module.database_server.instance_id
  tags = {
    Name = "Database Server EIP"
  }
}

module "monitoring_eip" {
  depends_on = [module.monitoring_server]
  source      = "./modules/eip"
  instance_id = module.monitoring_server.instance_id
  tags = {
    Name = "Monitoring EIP"
  }
}

#####################################################################################################
# EKS
# module "eks" {
#   source                   = "./modules/eks"
#   cluster_name             = "EKS-Cluster"
#   vpc_id                   = module.vpc.vpc_id
#   private_subnets          = module.vpc.private_subnets
#   control_plane_subnet_ids = module.vpc.private_subnets
#   ami_id                   = ["ami-05778ef68e10b91d7"] 
#   instance_type            = ["t2.medium"]
#   key_name                 = "worker-keypair"

# }

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.8.4"
  cluster_name    = "eks-cluster"
  cluster_version = var.kubernetes_version
  subnet_ids      = module.vpc.private_subnets

  enable_irsa = true

  tags = {
    cluster = "demo"
  }

  vpc_id = module.vpc.vpc_id

  eks_managed_node_group_defaults = {
    ami_id               = "ami-05778ef68e10b91d7"
    instance_types         = ["t2.medium"]
  }

  eks_managed_node_groups = {

    node_group = {
      min_size     = 1
      max_size     = 2
      desired_size = 2
    }
  }
}

