resource "aws_iam_group" "administrators" {
  name = "Administrators"
  path = "/"
}

data "aws_iam_policy" "admin_access" {
  name = "AdministratorAccess"
}

resource "aws_iam_group_policy_attachment" "administrators" {
  group      = aws_iam_group.administrators.name
  policy_arn = data.aws_iam_policy.admin_access.arn
}

resource "aws_iam_user" "admin" {
  name = "Administrator"
}

resource "aws_iam_user_group_membership" "admin-dev" {
  user   = aws_iam_user.admin.name
  groups = [aws_iam_group.administrators.name]
}

resource "aws_iam_access_key" "admin_access_key" {
  user = aws_iam_user.admin.name
}

resource "aws_iam_user_login_profile" "administrator" {
  user = aws_iam_user.admin.name
}

output "secret" {
  value     = aws_iam_access_key.admin_access_key.secret
  sensitive = true
}

output "password" {
  value     = aws_iam_user_login_profile.administrator.password
  sensitive = true
}


resource "aws_iam_group" "s3buckets" {
  name = "S3Access"
}

resource "aws_iam_group_policy" "s3access" {
  group = aws_iam_group.s3buckets.name
  policy = jsonencode({
    Version : "2012-10-17"
    Statement : [
      {
        Action : ["s3:*"]
        Effect : "Allow"
        Resource : ["arn:aws:s3:::terracantus-staticfiles", "arn:aws:s3:::terracantus-staticfiles/*"]

      }
    ]
  })
}

resource "aws_iam_user" "terracantus" {
  name = "terracantus-app"
}

resource "aws_iam_access_key" "terracantus-app" {
  user = aws_iam_user.terracantus.name
}

resource "aws_iam_group_membership" "tc-s3" {
  name  = "app-s3-access"
  users = [aws_iam_user.terracantus.name]
  group = aws_iam_group.s3buckets.name
}

output "app-access" {
  value     = aws_iam_access_key.terracantus-app.id
  sensitive = true
}

output "app-secret" {
  value     = aws_iam_access_key.terracantus-app.secret
  sensitive = true
}

locals {
  app_access = aws_iam_access_key.terracantus-app.id
  app_secret = aws_iam_access_key.terracantus-app.secret
}
