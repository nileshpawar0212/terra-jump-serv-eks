resource "aws_security_group" "node_sg" {
  name        = var.node_security_group_name
  description = "Security group for EKS nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      "Name" = var.node_security_group_name
    },
    var.tags
  )
}

resource "aws_security_group_rule" "cluster_to_nodes" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1" # All traffic
  source_security_group_id = var.cluster_security_group_id
  security_group_id        = aws_security_group.node_sg.id
  description              = "Allow all traffic from the EKS cluster security group"
}

resource "aws_launch_template" "this" {
  name_prefix   = var.launch_template_name
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.node_sg.id]

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 20
      volume_type = "gp3"
      encrypted   = true
      # The default AWS-managed KMS key for EBS is used by default when encrypted is true.
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "demo-eks-node"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "demo-eks-node"
    }
  }

  tags = merge(
    {
      "Name" = var.launch_template_name
    },
    var.tags
  )
}