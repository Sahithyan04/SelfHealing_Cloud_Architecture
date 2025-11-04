# SECURITY GROUP
resource "aws_security_group" "selfheal_sg" {
  name_prefix = "selfheal-sg-"
  description = "Allow SSH and HTTP"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "selfheal-sg"
  }
}

# IAM ROLE for EC2 (so it can send CloudWatch metrics/logs)
resource "aws_iam_role" "ec2_role" {
  name = "selfheal-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Effect = "Allow"
    }]
  })
}

# Attach CloudWatch policy
resource "aws_iam_role_policy_attachment" "cw_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Instance Profile for EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "selfheal-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# EC2 INSTANCE
resource "aws_instance" "selfheal_ec2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.selfheal_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  # Optional user data setup (runs setup.sh on boot)
  user_data = file("${path.module}/../Scripts/setup.sh")

  tags = {
    Name = "selfheal-instance"
  }
}
