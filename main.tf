provider "aws" {
  region = "ap-south-1"

  
}
resource "aws_dms_replication_instance" "dms_replication_instance" { 
  allocated_storage           = 10 
  engine_version = "3.5.2"
  apply_immediately           = true 
  auto_minor_version_upgrade  = true 
  replication_instance_class  = "dms.t3.medium" 
  replication_instance_id     = "my-dms-instance" 
  publicly_accessible         = true  # make sure you understand the security implications of making it publicly accessible 
}
 
resource "aws_dms_endpoint" "source_endpoint" { 
  endpoint_id     = "source-ec2" 
  # database_name = "vardhan"
  endpoint_type   = "source" 
  engine_name     = "mysql"  // substitute here with the name of your source database engine 
  username        = "root"  // substitute with your database username 
  password        = "Admin@123"  // substitute with your database password 
  port            = "3306"
  server_name     = "ec2-13-232-36-249.ap-south-1.compute.amazonaws.com"  // substitute with your source server name 
  depends_on = [ aws_dms_replication_instance.dms_replication_instance ]
} 
 
resource "aws_dms_endpoint" "target_endpoint" { 
  endpoint_id     = "rds-taget"
  endpoint_type   = "target" 
  # database_name = "DMSDemodb"
 port             = "3306"
  engine_name     = "mysql"  // substitute here with the name of your target database engine 
  username        = "admin"  // substitute with your database username 
  password        = "srivardhan1211"  // substitute with your database password 
  server_name     = "dms.c7s0iqse4usm.ap-south-1.rds.amazonaws.com"  // substitute with your target server name 
  depends_on = [ aws_dms_replication_instance.dms_replication_instance ]
} 
 
resource "aws_dms_replication_task" "dms_replication_task" { 
  migration_type          = "full-load-and-cdc"  // for this example we are using full-load migration type 
  replication_task_id     = "my-task" 
  replication_task_settings = file("dms.json")
  replication_instance_arn = aws_dms_replication_instance.dms_replication_instance.replication_instance_arn 
  source_endpoint_arn     = aws_dms_endpoint.source_endpoint.endpoint_arn 
  target_endpoint_arn     = aws_dms_endpoint.target_endpoint.endpoint_arn 
  table_mappings          = file("table_mappings.json") #add your table mappings here 
  depends_on = [ aws_dms_replication_instance.dms_replication_instance,aws_dms_endpoint.source_endpoint,aws_dms_endpoint.target_endpoint ]
}
