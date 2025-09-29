variable "pilvio" {
  type = object({
    api_key            = string
    billing_account_id = number
  })
  description = "Pilvio account credentials"
  sensitive   = true
  
  validation {
    condition = (
      length(var.pilvio.api_key) > 0
    )
    error_message = "pilvio.api_key check."
  }
  
  validation {
    condition = (
      var.pilvio.billing_account_id > 0
    )
    error_message = "pilvio.billing_account_id should be positive value."
  }
}

variable "ssh" {
  sensitive   = true
  type = object({
    public_key_path = string
    private_key_path = string
    known_hosts_path = string

  })
  default = {
    public_key_path = "~/.ssh/id_rsa.pub"
    private_key_path  = "~/.ssh/id_rsa"
    known_hosts_path  = "~/.ssh/known_hosts"
  }
}

variable "vm" {
  type = object({
    name  = string
    username = string
    password = string
    vcpu  = number
    memory  = number
    disk  = number
    os_name = string
    os_version = string
  })
  description = "VM configuration"

  default = {
    name  = "server.example.com"
    username  = "ubuntu"
    password  = ""
    vcpu  = 1
    memory  = 1024
    disk  = 20
    os_name = "ubuntu"
    os_version = "24.04"
  }

  validation {
    condition = (
      length(var.vm.name) > 0
    )
    error_message = "vm.name check."
  }

  validation {
    condition = (
      length(var.vm.username) >= 3 &&
      length(regexall("[[:space:]]", var.vm.username)) == 0
    )
    error_message = "vm.username at least 3 without spaces."
  }

  validation {
    condition = (
      var.vm.vcpu   >= 1 &&
      var.vm.memory >= 512 &&
      var.vm.disk   >= 20
    )
    error_message = "vm.vcpu >= 1, vm.memory >= 512MB, vm.disk >= 20GB."
  }

  validation {
    condition = (
      var.vm.password == "" ||
      (
        length(var.vm.password) >= 8 &&
        length(regexall("[A-Z]", var.vm.password)) > 0 &&
        length(regexall("[a-z]", var.vm.password)) > 0 &&
        length(regexall("[0-9]", var.vm.password)) > 0
      )
    )
    error_message = "vm.password check."
  }
}

variable "pilvio_location" {
  description = "Pilvio datacenter location"
  type        = string
  default     = "tll01"

  validation {
    condition     = contains(["tll01", "jhvi", "jhv02"], var.pilvio_location)
    error_message = "Location must be one of: tll01, jhvi, jhv02"
  }
}

variable "timezone" {
  description = "Timezone for the server"
  type        = string
  default     = "Europe/Tallinn"
}

variable "floating_ip" {
  type    = string
  default = ""
}

variable "admin_email" {
  type    = string
}

variable "s3_sse_key" {
  type    = string
  sensitive = true
}

variable "nextcloud_subdomain" {
  type = string
  default = "nextcloud"
}

variable "traefik_subdomain" {
  type = string
  default = "traefik"
}

variable "s3_bucket_name" {
  type = string
}
