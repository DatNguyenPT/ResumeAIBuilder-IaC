# locals {
#   sg_configs = {
#     jenkins = {
#       name        = "jenkins-sg"
#       description = "Security group for Jenkins Master"
#       ingress     = [{ port = 22 }, { port = 8080 }]
#     }
#     jenkins_worker = {
#       name        = "jenkins-worker-sg"
#       description = "Security group for Jenkins Worker"
#       ingress     = [{ port = 22 }, { port = 8080 }]
#     }
#     sonarqube = {
#       name        = "sonarqube-sg"
#       description = "Security group for SonarQube"
#       ingress     = [{ port = 22 }, { port = 9000 }]
#     }
#     database = {
#       name        = "database-sg"
#       description = "Security group for Database Server"
#       ingress     = [{ port = 22 }, { port = 3306, cidr_blocks = ["10.0.0.0/16"] }]
#     }
#     monitoring = {
#       name        = "monitoring-sg"
#       description = "Security group for Monitoring Server"
#       ingress     = [{ port = 22 }, { port = 3000 }, { port = 9090 }]
#     }
#   }
# }

# resource "aws_security_group" "instance_sg" {
#   for_each = { for k, v in local.sg_configs : k => v if contains(var.enabled_security_groups, k) }

#   name        = each.value.name
#   description = each.value.description
#   vpc_id      = var.vpc_id

#   dynamic "ingress" {
#     for_each = each.value.ingress
#     content {
#       from_port   = ingress.value.port
#       to_port     = ingress.value.port
#       protocol    = "tcp"
#       cidr_blocks = lookup(ingress.value, "cidr_blocks", ["0.0.0.0/0"])
#     }
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# output "instance_security_groups" {
#   value = { for k, sg in aws_security_group.instance_sg : k => sg.id }
# }


resource "aws_security_group" "server_access_sg" {
  for_each    = var.config
  name        = "${each.key}-sg"
  description = "The security group for ${each.key}"
  vpc_id      = var.vpc_id

  # Add ingress rules based on the ports configuration
  dynamic "ingress" {
    for_each = each.value.ports
    content {
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = "tcp"
      cidr_blocks = ingress.value.source == "::/0" ? null : [ingress.value.source]
      ipv6_cidr_blocks = ingress.value.source == "::/0" ? [ingress.value.source] : null
    }
  }

  # Add a default egress rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Server"   = each.key
    "Provider" = "Terraform"
  }
}