variable "hcloud_token" {
  type      = string
  sensitive = true
  default   = ""
}

variable "worker_count" {
  type    = number
  default = 3
}
