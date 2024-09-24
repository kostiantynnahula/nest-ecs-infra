resource "aws_db_instance" "patient" {
  allocated_storage      = 20
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  engine                 = "postgres"
  identifier             = "dev-patient-db"
  engine_version         = "13"
  instance_class         = "db.t3.micro"
  db_name                = "patient"
  username               = "postgres"
  password               = var.db_password
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.allow_db.id]
}
