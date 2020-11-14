resource "aws_kms_key" "ssm_session" {
  description             = "Key to be used for SSM Session traffic encryption"
  deletion_window_in_days = 7

  tags = {
    name = "ssm_session_key"
  }
}

resource "aws_iam_role" "ssm" {
  name               = "ssm_session_role"
  description        = "IAM Role to provide instance access via SSM"
  path               = "/"
  assume_role_policy = file("${path.root}/policy_templates/ssm_baseline/json/ssm_base_role_policy.json")
}

resource "aws_iam_role_policy" "ssm_session" {
  name = "ssm_session_policy"
  role = aws_iam_role.ssm.id
  policy = templatefile("${path.root}/policy_templates/ssm_baseline/tmpl/ssm_policy.tmpl",
    {
      ssm_session_key_arn = aws_kms_key.ssm_session.arn
    }
  )
}