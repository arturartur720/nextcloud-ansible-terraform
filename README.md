# nextcloud-ansible-terraform

Terraform project that provisions a VM on **Pilvio.com** and deploys a full **Nextcloud stack** with:

- **Traefik** as reverse proxy with TLS certificates  
- **Nextcloud**, **Redis**, and **MariaDB**  
- User files stored in **Pilvio S3** with server-side encryption (SSE key)  

## Usage
1. Configure `terraform/terraform.tfvars` from example with Pilvio credentials, VM settings, S3 bucket and SSE key.
2. Fill `ansible/group_vars/all/main.yml` or update variables.
3. Run:
```bash
terraform init
terraform apply
