module "vpc_module" {
  source = "../../modules/vpc"
  vpc_cidr = "10.0.0.0/16"
  public_subnet_cidrs = {
    ap-northeast-1a = "10.0.0.0/24",
    ap-northeast-1c = "10.0.1.0/24",
    ap-northeast-1d = "10.0.2.0/24",
  }
  private_subnet_cidrs = {
    ap-northeast-1a = "10.0.10.0/24",
    ap-northeast-1c = "10.0.11.0/24",
    ap-northeast-1d = "10.0.12.0/24",
  }
  azs = ["ap-northeast-1a","ap-northeast-1c","ap-northeast-1d"]
}

module "sg_module" {
  source = "../../modules/sg"

  vpc_id = module.vpc_module.vpc_id
}

module "alb_module" {
  source = "../../modules/alb"
  alb_sg_id = module.sg_module.alb_sg_id
  vpc_id =  module.vpc_module.vpc_id
  public_subnet_id = module.vpc_module.public_subnet_id
  private_subnet_id = module.vpc_module.private_subnet_id
  log_bucket_id = module.s3_module.log_bucket
  domain_name = "*.michinoku-study.com"
}

module "s3_module" {
  source = "../../modules/s3"
}

module "ecs_module" {
  source = "../../modules/ecs"
  ecs_sg_id = module.sg_module.ecs_sg_id
  private_subnet_id = module.vpc_module.private_subnet_id
  tg_arn = module.alb_module.tg_arn
  listener = module.alb_module.listner
  listener_arn = module.alb_module.listener_arn
  db_name = var.db_name
  db_endpoint = module.aurora_module.db_endpoint
  db_username = var.db_username
  db_password_arn = module.aurora_module.db_password_arn
  efs_file_system_id =  module.efs_module.aws_efs_file_system_id
  efs_access_point_id = module.efs_module.aws_efs_access_point_id
  s3_content_bucket_arn = module.s3_module.content_bucket_arn
}

module "aurora_module" {
  source = "../../modules/aurora"
  private_subnet_id = module.vpc_module.private_subnet_id
  aurora_sg_id = module.sg_module.aurora_sg_id
  db_name = var.db_name
  db_username = var.db_username
  db_instance_class = "db.t3.medium"
  # メンテナンスウィンドウ日本時間火曜日の3:00~4:00
  maintenance_window = "mon:18:00-mon:19:00"
}

module "route53_module" {
  source = "../../modules/route53"
  host_zone_name = "michinoku-study.com"
  alb_dns_name = module.alb_module.alb_dns_name
  alb_zone_id = module.alb_module.alb_zone_id
}

module "efs_module" {
  source = "../../modules/efs"
  private_subnet_id = module.vpc_module.private_subnet_id
  efs_sg_id = module.sg_module.efs_sg_id
}

module "sns_module" {
  source = "../../modules/sns"
  sns_mail_address = "kokoneko.it+handson1@gmail.com"
}

module "cloudwatch_module" {
  source = "../../modules/cloudwatch"
  sns_topic_arn = module.sns_module.sns_topic_arn
  ecs_cluster_name = module.ecs_module.ecs_cluster_name
  ecs_service_name = module.ecs_module.ecs_service_name
  db_writer_instance_id = module.aurora_module.db_writer_instance_id
}

module "eventbridge_module" {
  source = "../../modules/eventbridge"
  ecs_cluster_arn = module.ecs_module.ecs_cluster_arn
  sns_topic_arn = module.sns_module.sns_topic_arn
}