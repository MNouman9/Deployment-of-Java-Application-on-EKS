environment                      = "dev"
region                           = "us-east-2"
application                      = "javaapp"

eks_worker_node_instance_type    = "t2.medium"
public_access_cidr_blocks        = ["0.0.0.0/0"]
eks_node_group_desired_size      = 1
eks_node_group_min_size          = 1
eks_node_group_max_size          = 2
eks_kubernetes_version           = "1.32"
eks_map_users = []

lb_name                          = "alb-ingress"
app_domain_name                  = "javaapp.com"
