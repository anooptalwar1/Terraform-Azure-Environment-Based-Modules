module "dev-resource_group" {
  source = "../../resources/resource_group"
  name = "${var.name}-dev"
  location = "${var.location}"
}


module "dev-virtual_network" {
  source = "../../resources/virtual_network"
  name = "${var.name}-dev"
  location = "${var.location}"
  resource_group_name = "${module.dev-resource_group.name}"
  network_address_space = "${var.network_address_space}"
}

module "dev-subnet" {
  source = "../../resources/subnet"
  name = "${var.name}-dev"
  resource_group_name = "${module.dev-resource_group.name}"
  virtual_network_name = "${module.dev-virtual_network.name}"
  address_prefixes = "${var.subnet_address_prefixes}"
}

module "dev-storage_account" {
  source = "../../resources/storage_account"
  account_name = "${var.name}osdisks"
  resource_group_name = "${module.dev-resource_group.name}"
}

module "dev-public_ips_control" {
  name = "control-dev"
  source = "../../resources/public_ip"
  location = "${var.location}"
  resource_group_name = "${module.dev-resource_group.name}"
  control_count = "${var.control_count}"
  environment	= "${var.environment}"
}

module "dev-vms_control" {
  source = "../../resources/virtual_machines"
  name = "${var.name}-dev"
  control_count = "${var.control_count}"
  vm_name = "control"
  location = "${var.location}"
  role = "role=control"
  datacenter = "${var.datacenter}"
  resource_group_name = "${module.dev-resource_group.name}"
  subnet_ids = "${module.dev-subnet.ids}"
  storage_account_name = "${module.dev-storage_account.name}"
  storage_primary_blob_endpoint = "${module.dev-storage_account.primary_blob_endpoint}"
  admin_username = "${var.admin_username}"
  admin_password = "${var.admin_password}"
#  public_ip_addresses = "${module.dev-public_ips_control.ip_addresses}"
  public_ip_address_ids = "${module.dev-public_ips_control.ids}"
#  network_security_group_id = "${module.dev-network_security_group_default.id}"
}


resource "random_id" "name" {
  byte_length = 8
}

module "dev-sql-database" {
  source              = "../../resources/sqldatabase"
  resource_group_name = "${module.dev-resource_group.name}"
  location            = "${var.location}"
  db_name             = "${var.db_name}-${random_id.name.hex}"
  sql_admin_username  = "${var.sql_admin_username}"
  sql_password        = "${var.sql_password}"
  start_ip_address    = "${var.start_ip_address}"
  end_ip_address      = "${var.end_ip_address}"
}

module "dev-redis" {
  source  = "../../resources/redis_cache"
  name                = "${var.name}-dev"
  location            = "${var.location}"
  resource_group_name = "${module.dev-resource_group.name}"
}

module "dev-log_analytics" {
    source  = "../../resources/log_analytics"
    name                  = "${var.name}-dev"
    workspacename         = "${var.workspacename}-laworkspace"
    resource_group_name   = "${module.dev-resource_group.name}"
    location              = "${var.location}"   
}


module "dev-loadbalancer" {
  source                = "../../resources/load_balancer"
  name                  = "${var.name}-dev"
  resource_group_name   = "${module.dev-resource_group.name}"
  location              = "${var.location}"
  public_ip_address_ids = "${module.dev-public_ips_control.ids}"
  remote_port           = "${var.remote_port}"
  lb_port               = "${var.lb_port}"
}

  
module "dev-vpngw" {
    source = "../../resources/vnet_gateway"
    name = "${var.name}-dev"
    resource_group_name = "${module.dev-resource_group.name}"
    location = "${var.location}"
    subnet_ids = "${module.dev-subnet.ids}"
    sku = "VpnGw1"
    public_ip_address_ids = "${module.dev-public_ips_control.ids}"
}

