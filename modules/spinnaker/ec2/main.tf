data "aws_ami" "ubuntu_1604" {
  most_recent = true

  filter {
    name = "image-id"
    values = ["ami-0e82959d4ed12de3f"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

data "aws_iam_role" "ssm_session" {
  name = "ssm_session_role"
}

resource "aws_key_pair" "spinnaker" {
  key_name = "spinnaker_key"
  public_key = file("~/.ssh/spinnaker-key.pub")
}

resource "aws_iam_instance_profile" "ssm_session" {
  name = "ssm_profile"
  role = data.aws_iam_role.ssm_session.name
}

resource "aws_security_group" "spinnaker" {
  name        = "spinnaker_sg"
  description = "Security Group for Spinnaker"
  vpc_id      = var.spinnaker_vpc_id

  tags = {
    name = "allow_tls"
  }
}

resource "aws_security_group_rule" "outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  security_group_id = aws_security_group.spinnaker.id
}
resource "aws_instance" "spinnaker" {
  ami = data.aws_ami.ubuntu_1604.image_id
  instance_type = var.spinnaker_instance_type
  key_name = aws_key_pair.spinnaker.key_name
  iam_instance_profile = aws_iam_instance_profile.ssm_session.name
  security_groups = []

  tags = {
    name = "spinnaker"
  }
}
