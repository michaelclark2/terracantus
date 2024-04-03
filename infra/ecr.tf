resource "aws_ecr_repository" "webapp" {
  name = "webapp"
}

resource "aws_ecr_repository" "nginx" {
  name = "nginx"
}

output "nginx-ecr-url" {
  value = aws_ecr_repository.nginx.repository_url
}
