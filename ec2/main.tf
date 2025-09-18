data "aws_iam_policy_document" "ec2_assume_role_policy" {
    statement {
      effect = "Allow"
      principals {
        type        = "Service"
        identifiers = ["ec2.amazonaws.com"]
      }

      actions = ["sts:AssumeRole"]
    }
  }

  resource "aws_iam_role" "this" {
    name               = var.iam_role_name
    assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
  }

  resource "aws_iam_role_policy_attachment" "admin" {
    count      = var.attach_admin_policy ? 1 : 0
    role       = aws_iam_role.this.name
    policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  }

  resource "aws_iam_role_policy_attachment" "ssm" {
    role       = aws_iam_role.this.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  resource "aws_iam_instance_profile" "this" {
    name = "${var.name}-instance-profile"
    role = aws_iam_role.this.name
  }

  resource "aws_key_pair" "this" {
    count = var.public_key_path != "" ? 1 : 0
    key_name   = var.key_name
    public_key = file(var.public_key_path)
  }

  resource "aws_security_group" "this" {
    name   = "${var.name}-sg"
    vpc_id = var.vpc_id

    description = "Security group for ${var.name}"

    ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.ssh_cidr_blocks
    }

    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags = merge({ Name = "jump-jenkins-vpc" }, var.tags)
  }

  data "aws_ami" "al2023" {
    most_recent = true
    owners      = ["amazon"]
    filter {
      name   = "name"
      values = ["al2023-ami-2023.*-x86_64"]
    }
    filter {
      name   = "architecture"
      values = ["x86_64"]
    }
  }

  resource "aws_instance" "this" {
    ami                         = var.ami_id != "" ? var.ami_id : data.aws_ami.al2023.id
    instance_type               = var.instance_type
    subnet_id                   = var.subnet_id
    vpc_security_group_ids      = [aws_security_group.this.id]
    iam_instance_profile        = aws_iam_instance_profile.this.name
    key_name                    = var.key_name
    # If associate_public_ip is false, do not associate public IP (instance will be private-only)
    associate_public_ip_address = var.associate_public_ip

    # Optional explicit private IP
    private_ip = var.private_ip != "" ? var.private_ip : null
    # User data: install AWS CLI and run the provided IAM user creation script
      user_data = file("${path.module}/userdata.sh")


    tags = merge({ Name = var.name }, var.tags)
  }

  resource "aws_eip" "this" {
    count = var.associate_public_ip ? 1 : 0
    depends_on = [aws_instance.this]
  }

  resource "aws_eip_association" "this" {
    count = var.associate_public_ip ? 1 : 0
    allocation_id = aws_eip.this[0].allocation_id
    instance_id   = aws_instance.this.id
  }

