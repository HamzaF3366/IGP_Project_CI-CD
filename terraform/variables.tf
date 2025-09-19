variable "project" { type = string }
variable "region" { type = string }
variable "zone" { type = string, default = "europe-west10-a" }
variable "jenkins_ssh_pub" { type = string }
variable "machine_type" { type = string, default = "e2-medium" }
