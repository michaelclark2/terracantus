variable "DB_PASSWORD" {
  type = string
}

resource "aws_db_instance" "postgresql" {
  allocated_storage      = 20
  engine                 = "postgres"
  identifier             = "tc-postgres"
  db_name                = "terracantus"
  username               = "terracantus"
  password               = var.DB_PASSWORD
  instance_class         = "db.t3.micro"
  storage_encrypted      = false
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = ["sg-6887f71c"] // default, for now
}

output "db_url" {
  value     = "postgres://${aws_db_instance.postgresql.username}:${aws_db_instance.postgresql.password}@${aws_db_instance.postgresql.address}:${aws_db_instance.postgresql.port}/${aws_db_instance.postgresql.db_name}"
  sensitive = true
}
