module "yc-vpc" {
  source              = "git@github.com:terraform-yc-modules/terraform-yc-vpc.git"
  network_name        = "sandbox-vpc"
  network_description = "sandbox-vpc"

  create_sg = false

  public_subnets = [
    {
      name           = "app-subnet-a"
      zone           = "ru-central1-a"
      v4_cidr_blocks = ["10.10.0.0/24"]
    }
  ]
  private_subnets = [
    {
      name           = "app-subnet-aa"
      zone           = "ru-central1-a"
      v4_cidr_blocks = ["10.10.10.0/24"]
    }
  ]
}
