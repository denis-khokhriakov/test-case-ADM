#Setting up AWS multi-AZ RDS

resource "aws_db_subnet_group" "rds-private-subnet" {
  name = "rds-private-subnet-group"
  subnet_ids = module.vpc.database_subnets
}

resource "aws_security_group" "rds-sg" {
  name   = "my-rds-sg"
  vpc_id = module.vpc.vpc_id

}

# Ingress Security Port 3306
resource "aws_security_group_rule" "mysql_inbound_access" {
  from_port         = 3306
  protocol          = "tcp"
  security_group_id = aws_security_group.rds-sg.id
  to_port           = 3306
  type              = "ingress"
  cidr_blocks       = ["add you address here in 1.2.3.4/32 format"]
}

resource "aws_db_instance" "test_mysql" {
  identifier                  = "test-mysql"
  allocated_storage           = 10
  storage_type                = "gp2"
  engine                      = "mysql"
  engine_version              = "5.7"
  instance_class              = "db.t2.small"
  name                        = "testwpdb"
  username                    = "admin"
  password                    = #Enter your password here
  parameter_group_name        = "default.mysql5.7"
  db_subnet_group_name        = aws_db_subnet_group.rds-private-subnet.name
  vpc_security_group_ids      = [aws_security_group.rds-sg.id]
  allow_major_version_upgrade = true
  auto_minor_version_upgrade  = true
  backup_retention_period     = 35
  backup_window               = "22:00-23:00"
  maintenance_window          = "Sat:00:00-Sat:03:00"
  multi_az                    = true
  skip_final_snapshot         = true
}
