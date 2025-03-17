# variable "igw_name" {
#   description = "Name tag for the Internet Gateway"
#   type        = string
#   default     = "datnguyen-igw"
# }

# variable "route_table_name" {
#   description = "Name tag for the Public Route Table"
#   type        = string
#   default     = "Public Route Table"
# }

# variable "tags" {
#   description = "Tags to be applied to resources"
#   type        = map(string)
#   default     = {
#     Environment = "dev"
#     Name        = "datnguyen-igw"
#   }
# }

variable "kubernetes_version" {
  default     = 1.27
  description = "kubernetes version"
}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "default CIDR range of the VPC"
}
variable "aws_region" {
  default = "us-west-1"
  description = "aws region"
}
