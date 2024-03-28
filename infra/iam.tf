resource "aws_iam_group" "administrators" {
	name = "Administrators"
	path = "/"
}

data "aws_iam_policy" "admin_access" {
	name = "AdministratorAccess"
}

resource "aws_iam_group_policy_attachment" "administrators" {
	group = aws_iam_group.administrators.name
	policy_arn = data.aws_iam_policy.admin_access.arn
}

resource "aws_iam_user" "admin" {
	name = "Administrator"
}

resource "aws_iam_user_group_membership" "admin-dev" {
	user = aws_iam_user.admin.name
	groups = [aws_iam_group.administrators.name]
}

resource "aws_iam_access_key" "admin_access_key" {
	user = aws_iam_user.admin.name
}

resource "aws_iam_user_login_profile" "administrator" {
	user = aws_iam_user.admin.name
	password_reset_required = true
}

output "secret" {
	value = aws_iam_access_key.admin_access_key.secret
	sensitive = true
}

output "password" {
	value = aws_iam_user_login_profile.administrator.password
	sensitive = true
}

