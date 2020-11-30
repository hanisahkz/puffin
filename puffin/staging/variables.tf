# Reference: https://www.terraform-best-practices.com/naming

variable "project_id" {
   default = "labs-297800"
}

variable "region" { 
   default = "us-central1"
}

variable "zone" {
   default = "us-central1-c"
}

variable "environment" {
   default = "staging"
}

# Network
variable "network_name" {
   default = "puffin-staging"
}

variable "cidrs" {
  default = "10.0.0.0/16"
}

# Compute Engine
variable "web_vm_name" { default = "web-vm" }
variable "web_vm_machine_type" { default = "f1-micro" }
variable "web_vm_disk_image" { default = "debian-cloud/debian-9" }
variable "web_vm_tags" { default = ["web"] }