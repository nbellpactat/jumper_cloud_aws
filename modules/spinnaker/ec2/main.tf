data "aws_ami" "ubuntu_1604" {
  most_recent = true

  filter {
    name   = "image-id"
    values = ["ami-03657b56516ab7912"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"]
}

data "aws_iam_role" "ssm_session" {
  name = "ssm_session_role"
}

resource "aws_key_pair" "spinnaker" {
  key_name   = "spinnaker_key"
  public_key = file("~/.ssh/spinnaker-key.pub")
}

resource "aws_iam_instance_profile" "ssm_session" {
  Name = "ssm_profile"
  role = data.aws_iam_role.ssm_session.name
}

resource "aws_security_group_rule" "outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  security_group_id = var.spinnaker_security_group_id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_instance" "spinnaker" {
  ami                    = data.aws_ami.ubuntu_1604.image_id
  instance_type          = var.spinnaker_instance_type
  key_name               = aws_key_pair.spinnaker.key_name
  subnet_id              = var.subnet_id
  iam_instance_profile   = aws_iam_instance_profile.ssm_session.name
  vpc_security_group_ids = [var.spinnaker_security_group_id]

  tags = {
    Name = "spinnaker"
  }
}
