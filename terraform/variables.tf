variable "project_id" {
  type    = string
  default = "bright-airport-463914-a8"
}

variable "region" {
  type    = string
  default = "europe-west10"
}

variable "zone" {
  type    = string
  default = "europe-west10-a"
}

variable "machine_type" {
  type    = string
  default = "e2-medium"
}

variable "ssh_user" {
  type    = string
  default = "ubuntu"
}

variable "vm_count" {
  type    = number
  default = 2
}
