provider "pilvio" {
  apikey   = var.pilvio.api_key
  host     = "api.pilvio.com"
  location = var.pilvio_location
}

resource "pilvio_bucket" "s3_bucket" {
  name               = join("-", [var.s3_bucket_name, var.vm.name])
  billing_account_id = var.pilvio.billing_account_id
  lifecycle {
    ignore_changes = [name]
  }
}

data "http" "s3_credentials" {
  url = "https://api.pilvio.com/v1/storage/user"
  request_headers = {
    apikey = var.pilvio.api_key
  }
}

locals {
  parsed = jsondecode(data.http.s3_credentials.response_body)
}

resource "pilvio_vm" "nextcloud" {
  name               = var.vm.name
  os_name            = var.vm.os_name
  os_version         = var.vm.os_version
  memory             = var.vm.memory
  vcpu               = var.vm.vcpu
  disks              = var.vm.disk
  username           = var.vm.username
  password           = var.vm.password
  public_key         = trimspace(file(var.ssh.public_key_path))
  billing_account_id = var.pilvio.billing_account_id
  location           = var.pilvio_location

  cloud_init = jsonencode({
    packages = ["python3", "python3-pip", "curl", "git"],
    runcmd = [
      "apt-get update",
      "echo 'Server provisioned successfully' > /var/log/provision.log"
    ]
  })
}

resource "pilvio_floatingip" "nextcloud_floating_ip" {
  count              = var.floating_ip == "" ? 1 : 0
  name               = "${var.vm.name}-ip"
  billing_account_id = var.pilvio.billing_account_id
  location           = var.pilvio_location
  assigned_to        = pilvio_vm.nextcloud.uuid
  lifecycle {
    ignore_changes = [name]
  }
}

resource "pilvio_floatingip_assignment" "assign_existing" {
  count       = var.floating_ip != "" ? 1 : 0
  assigned_to = pilvio_vm.nextcloud.uuid
  address     = var.floating_ip
}

locals {
  ip_address = var.floating_ip != "" ? var.floating_ip : (length(pilvio_floatingip.nextcloud_floating_ip) > 0 ? pilvio_floatingip.nextcloud_floating_ip[0].address : "")
}

resource "null_resource" "add_known_host" {
  provisioner "local-exec" {
    command = "ssh-keyscan -H ${local.ip_address} >> ${var.ssh.known_hosts_path}"
  }

  triggers = {
    ip = local.ip_address
  }
}

resource "ansible_group" "group" {
  name  = "nextcloud"
}

resource "ansible_host" "host" {
  name   = local.ip_address
  groups = [ansible_group.group.id]
}

resource "ansible_playbook" "nextcloud" {
  name  = ansible_host.host.id
  groups  = [ansible_group.group.id]
  playbook = "${path.module}/../ansible/playbook.yml"
  replayable = true

  extra_vars = {
    timezone          = var.timezone
    admin_email       = var.admin_email
    vm_hostname       = var.vm.name
    nextcloud_subdomain = var.nextcloud_subdomain
    traefik_password  = var.vm.password
    traefik_user      = var.vm.username
    traefik_subdomain = var.traefik_subdomain
    s3_bucket         = pilvio_bucket.s3_bucket.name
    s3_access_key     = local.parsed.s3Credentials[0].accessKey
    s3_secret_key     = local.parsed.s3Credentials[0].secretKey
    s3_sse_key        = var.s3_sse_key
    ansible_user      = var.vm.username
    ANSIBLE_CONFIG    = "${path.module}/../ansible/ansible.cfg"
  }

  depends_on = [
    pilvio_vm.nextcloud,
    pilvio_floatingip.nextcloud_floating_ip,
    pilvio_floatingip_assignment.assign_existing,
    data.http.s3_credentials,
    null_resource.add_known_host,
    ansible_host.host
  ]
}

resource "local_file" "ansible_log_file" {
  content  = ansible_playbook.nextcloud.ansible_playbook_stdout
  filename = "${path.module}/ansible.log"
}

resource "local_file" "ansible_err_file" {
  content  = ansible_playbook.nextcloud.ansible_playbook_stderr
  filename = "${path.module}/ansible-err.log"
}

resource "local_file" "inventory_file" {
  content  = ansible_playbook.nextcloud.temp_inventory_file
  filename = "${path.module}/ansible-temp-inventory.ini"
}

resource "local_file" "ansible_args_file" {
  content  = join("\n", ansible_playbook.nextcloud.args)
  filename = "${path.module}/ansible-args.log"
}