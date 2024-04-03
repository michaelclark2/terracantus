variable "DB_PASSWORD" {
  type = string
}

resource "aws_db_instance" "postgresql" {
  allocated_storage       = 20
  engine                  = "postgres"
  identifier              = "tc-postgres"
  db_name                 = "terracantus"
  username                = "terracantus"
  password                = var.DB_PASSWORD
  instance_class          = "db.t3.micro"
  storage_encrypted       = false
  skip_final_snapshot     = true
  publicly_accessible     = false
  vpc_security_group_ids  = [aws_security_group.rds.id]
  db_subnet_group_name    = aws_db_subnet_group.production.name
  multi_az                = false
  storage_type            = "gp2"
  backup_retention_period = 7
}

resource "aws_db_subnet_group" "production" {
  name       = "main"
  subnet_ids = [aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id]
}

locals {
  db_url = "postgres://${aws_db_instance.postgresql.username}:${aws_db_instance.postgresql.password}@${aws_db_instance.postgresql.address}:${aws_db_instance.postgresql.port}/${aws_db_instance.postgresql.db_name}"
}

output "db_url" {
  value     = local.db_url
  sensitive = true
}
