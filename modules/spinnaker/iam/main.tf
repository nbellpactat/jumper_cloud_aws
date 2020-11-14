data "aws_iam_policy" "power_user" {
  arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_iam_role" "spinnaker_base_role" {
  name               = var.spinnaker_base_role_name
  description        = var.spinnaker_base_role_desc
  path               = "/"
  assume_role_policy = file("${path.root}/policy_templates/spinnaker/json/spinnaker_base_role_policy.json")
}

resource "aws_iam_role" "spinnaker_role" {
  name               = var.spinnaker_role_name
  description        = var.spinnaker_role_desc
  path               = "/"
  assume_role_policy = file("${path.root}/policy_templates/spinnaker/json/spinnaker_base_role_policy.json")
  force_detach_policies = true
}

resource "aws_iam_role_policy" "spinnaker_passrole" {
  name = "spinnaker_passrole_role_policy"
  role = aws_iam_role.spinnaker_role.id
  policy = templatefile("${path.root}/policy_templates/spinnaker/tmpl/spinnaker_passrole_role_policy.tmpl",
    {
      spinnaker_base_role_arn = aws_iam_role.spinnaker_base_role.arn,
    }
  )
}

resource "aws_iam_user" "spinnaker_iam_user" {
  name          = var.spinnaker_iam_user_name
  path          = "/"
  force_destroy = true
}

resource "aws_iam_user_policy" "spinnaker_passrole" {
  name = "spinnaker_passrole_user_policy"
  user = aws_iam_user.spinnaker_iam_user.name

  policy = templatefile("${path.root}/policy_templates/spinnaker/tmpl/spinnaker_passrole_policy.tmpl",
    {
      spinnaker_base_role_arn = aws_iam_role.spinnaker_base_role.arn,
    }
  )
}

// Is PowerUserAccess needed on this user?
resource "aws_iam_user_policy_attachment" "spinnaker_poweruser" {
  user       = aws_iam_user.spinnaker_iam_user.name
  policy_arn = data.aws_iam_policy.power_user.arn
}

// Is PowerUserAccess needed on this Role?
resource "aws_iam_role_policy_attachment" "spinnaker_poweruser" {
  role       = aws_iam_role.spinnaker_role.name
  policy_arn = data.aws_iam_policy.power_user.arn
}

/*
Because the Secret Access Key is written to state as the aws_iam_access_key.spinnaker_access_key.secret
this resource should be generated in the console for now, until a better method can be obtained for safeguarding
the credentials
*/
//resource "aws_iam_access_key" "spinnaker_access_key" {
//  user = aws_iam_user.spinnaker_iam_user.name
//}
