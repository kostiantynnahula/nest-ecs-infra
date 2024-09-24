output "organization_db_address" {
  value = aws_db_instance.organization.address
}

output "organization_db_port" {
  value = aws_db_instance.organization.port
}

output "organization_db_name" {
  value = aws_db_instance.organization.db_name
}

output "organization_db_username" {
  value = aws_db_instance.organization.username
}

output "patient_db_address" {
  value = aws_db_instance.patient.address
}

output "patient_db_port" {
  value = aws_db_instance.patient.port
}

output "patient_db_name" {
  value = aws_db_instance.patient.db_name
}

output "patient_db_username" {
  value = aws_db_instance.patient.username
}

