# Создание ВМ с помощью модуля

module "yandex_instance_1" {
  source                = "./modules/create_vm"
  disk_size             = "40"
  disk_type             = "network-ssd"
  disk_name             = "srv-sys"
  is_second_disk        = "false"
  disk2_size            = "60"
  disk2_type            = "network-ssd"
  disk2_name            = "data"
  cores                 = "2"
  memory                = "4"
  core_fract            = "20"
  instance_family_image = "ubuntu-2204-lts"
  instance_subnet_name  = "a-ru-central1-a"
  instance_name         = "srv"
  instance_description  = "Logging, monitoring and deploying server"
  zone_name             = "ru-central1-a"
  is_ex_static_ipv4     = "false"
  ex_ipv4_name          = "ex-ip-test"
}

module "yandex_instance_2" {
  source                = "./modules/create_vm"
  disk_size             = "60"
  disk_type             = "network-ssd"
  disk_name             = "master-sys"
  is_second_disk        = "false"
  disk2_size            = "60"
  disk2_type            = "network-ssd"
  disk2_name            = "data"
  cores                 = "4"
  memory                = "6"
  core_fract            = "50"
  instance_family_image = "ubuntu-2204-lts"
  instance_subnet_name  = "a-ru-central1-a"
  instance_name         = "kub-master"
  instance_description  = "K8s master"
  zone_name             = "ru-central1-a"
  is_ex_static_ipv4     = "false"
  ex_ipv4_name          = "ex-ip-test"
}

module "yandex_instance_3" {
  source                = "./modules/create_vm"
  disk_size             = "60"
  disk_type             = "network-ssd"
  disk_name             = "app-sys"
  is_second_disk        = "false"
  disk2_size            = "60"
  disk2_type            = "network-ssd"
  disk2_name            = "data"
  cores                 = "4"
  memory                = "6"
  core_fract            = "50"
  instance_family_image = "ubuntu-2204-lts"
  instance_subnet_name  = "a-ru-central1-a"
  instance_name         = "kub-app"
  instance_description  = "K8s working node"
  zone_name             = "ru-central1-a"
  is_ex_static_ipv4     = "false"
  ex_ipv4_name          = "ex-ip-test"
}
