resource "aws_db_subnet_group" "subnet_group" {
    name = "wordpress"
    subnet_ids = var.private_subnet_id

    tags = {
      Name = "aurora-db-subnet-group"
    }
}

resource "aws_rds_cluster" "wordpress" {
    cluster_identifier = "wordpress-aurora"
    engine = "aurora-mysql"
    
}