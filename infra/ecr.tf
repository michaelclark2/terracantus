resource "aws_ecr_repository" "webapp" {
  name = "webapp"
}

output "ecr_repo_url" {
  value = aws_ecr_repository.webapp.repository_url
}
