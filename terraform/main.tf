module "kubernetes" {
  source = "git::https://github.com/mdv-devops/terraform-hcloud-kubernetes.git?ref=v3.30.2"

  cluster_name = "creagen"
  hcloud_token = var.hcloud_token

  cluster_kubeconfig_path  = "kubeconfig"
  cluster_talosconfig_path = "talosconfig"

  cert_manager_enabled       = true
  cilium_gateway_api_enabled = true

  talos_upgrade_reboot_mode = "default"
  talos_reboot_mode         = "default"

  hcloud_ccm_load_balancers_location = "nbg1"

  cluster_delete_protection = true

  control_plane_nodepools = [
    {
      name     = "control-plane"
      type     = "cpx22"
      location = "nbg1"
      count    = 1
    }
  ]

  worker_nodepools = [
    {
      name     = "worker"
      type     = "cpx32"
      location = "nbg1"
      count    = var.worker_count
    }
  ]
}
