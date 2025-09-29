resource "null_resource" "cleanup_known_hosts" {
  triggers = {
    ip = local.ip_address
  }

  provisioner "local-exec" {
    when    = destroy
    command = "ssh-keygen -R ${self.triggers.ip} || true"
  }
}