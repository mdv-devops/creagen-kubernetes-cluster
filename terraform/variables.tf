variable "hcloud_token" {
  type      = string
  sensitive = true
  default   = "0VDSDwbebl4kckRzE7D1lAnIxeagOJOtiMbhIgyvWLBcgMmEoFARWen9DDyp6qvC"
}

variable "worker_count" {
  type    = number
  default = 3
}
