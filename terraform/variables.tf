variable "hcloud_token" {
  type      = string
  sensitive = true
}

variable "worker_count" {
  type    = number
  default = 3
}
