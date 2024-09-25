resource "aws_secretsmanager_secret" "patient_rds_secret_credentials" {
  name        = "patient_rds_secret_credentials"
  description = "Patient secret credentials"
}

resource "random_password" "patient_password" {
  length           = 20
  special          = false
  override_special = "_%@"
}

resource "aws_secretsmanager_secret_version" "db_patient_credentials_version" {
  secret_id = aws_secretsmanager_secret.patient_rds_secret_credentials.id
  secret_string = jsonencode({
    username = "postgres",
    password = random_password.patient_password.result
  })
}

resource "aws_db_instance" "patient" {
  allocated_storage      = 20
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  engine                 = "postgres"
  identifier             = "dev-patient-db"
  engine_version         = "13"
  instance_class         = "db.t3.micro"
  db_name                = var.patient_db_name
  username               = jsondecode(aws_secretsmanager_secret_version.db_patient_credentials_version.secret_string).username
  password               = jsondecode(aws_secretsmanager_secret_version.db_patient_credentials_version.secret_string).password
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.allow_db.id]
}

resource "aws_iam_role" "rds_patient_access_role" {
  name = "rds_patient_access_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow",
        Principal = {
          Service = "rds.amazonaws.com"
        },
      }
    ]
  })
}


resource "aws_iam_policy" "rds_patient_secret_policy" {
  name = "rds_patient_secret_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = aws_secretsmanager_secret.patient_rds_secret_credentials.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_patient_secret_policy_attachment" {
  role       = aws_iam_role.rds_patient_access_role.name
  policy_arn = aws_iam_policy.rds_patient_secret_policy.arn
}
