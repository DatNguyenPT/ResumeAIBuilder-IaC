resource "aws_instance" "this" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  key_name        = var.key_name
  vpc_security_group_ids = [var.security_group_id]
  subnet_id              = var.subnet_id
  root_block_device {
    volume_size = var.volume_size
  }
  
  user_data = var.user_data_script != "" ? file(var.user_data_script) : null
}

