terraform {
  backend "s3" {
    bucket         = "mdv-terraform-state"
    key            = "creagen-project/infra/hetzner/kubernetes/test/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tfstate_locks"
    encrypt        = true
  }
}
