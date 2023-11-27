module "yc-db" {
  source = "git@github.com:terraform-yc-modules/terraform-yc-postgresql.git"

  network_id  = module.yc-vpc.vpc_id
  name        = "app-db"
  description = "PostgreSQL cluster for app"

  pg_version = 14

  performance_diagnostics = {
    enabled = false
  }

  security_groups_ids_list = [yandex_vpc_security_group.db_sg.id]

  hosts_definition = [
    {
      zone             = "ru-central1-a"
      assign_public_ip = false
      subnet_id        = module.yc-vpc.private_subnets["10.10.10.0/24"].subnet_id
    }
  ]

  postgresql_config = {
    max_connections                = 395
    enable_parallel_hash           = true
    default_transaction_isolation  = "TRANSACTION_ISOLATION_READ_COMMITTED"
    work_mem                       = 41943040
  }

  default_user_settings = {
    default_transaction_isolation = "read committed"
    log_min_duration_statement    = 1000
  }

  databases = [
    {
      name       = var.db_name
      owner      = "application"
      lc_collate = "ru_RU.UTF-8"
      lc_type    = "ru_RU.UTF-8"
      extensions = ["pg_stat_statements"]
    }
  ]

  owners = [
    {
      name       = "application"
      conn_limit = 50
    }
  ]

  users = [
    {
      name        = var.db_user
      conn_limit  = 30
      permissions = ["application"]
      settings = {
        pool_mode                   = "transaction"
        prepared_statements_pooling = true
      }
    }
  ]
}
