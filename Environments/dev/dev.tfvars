environment = "dev"
region      = "us-east-2"
application = "javaapp"

vpc_cidr_block                  = "172.16.0.0/21"
vpc_cidr_block_private_subnet_a = "172.16.0.0/24"
vpc_cidr_block_private_subnet_b = "172.16.1.0/24"
vpc_cidr_block_private_subnet_c = "172.16.2.0/24"
vpc_cidr_block_public_subnet_a  = "172.16.4.0/24"
vpc_cidr_block_public_subnet_b  = "172.16.5.0/24"
vpc_cidr_block_public_subnet_c  = "172.16.6.0/24"

eks_worker_node_instance_type = "t2.medium"
public_access_cidr_blocks     = ["0.0.0.0/0"]
eks_node_group_desired_size   = 1
eks_node_group_min_size       = 1
eks_node_group_max_size       = 2
eks_kubernetes_version        = "1.32"
eks_map_users                 = []

lb_name         = "alb-ingress"
app_domain_name = "javaapp.com"
