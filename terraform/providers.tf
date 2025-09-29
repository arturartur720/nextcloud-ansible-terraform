terraform {
  required_version = ">= 1.3.0"
  
  required_providers {
    pilvio = {
      source  = "pilvio-com/pilvio"
      version = ">= 1.0.16"
    }
    ansible = {
      source  = "ansible/ansible"
      version = ">= 1.3.0"
    }
  }
}