# Reference: https://www.terraform-best-practices.com/naming

variable "project_id" { default = "labs-297800" }
variable "region" { default = "us-central1" }
variable "zone" { default = "us-central1-c" }
variable "environment" { default = "staging" }

# Network
variable "network_name" { default = "puffin-staging" }
variable "cidrs" { default = "10.0.0.0/16" }

# Compute Engine
variable "web_vm_name" { default = "puffin-staging" }
variable "web_vm_machine_type" { default = "f1-micro" }
variable "web_vm_disk_image" { default = "debian-cloud/debian-9" }
variable "web_vm_tags" { default = ["web"] }
variable "web_vm_instance_groups_tags" { default = ["allow-lb-service"] }
variable "web_vm_instance_group_manager_name" { default = "puffin-staging-igm" }
variable "web_vm_autoscaler_min_replicas" { default ="2" }
variable "web_vm_autoscaler_max_replicas" { default = "3" }
variable "web_vm_autoscaler_cooldown" { default = "60" }
variable "web_vm_autoscaler_cpu_util" { default = "0.5" }
variable "web_vm_target_pool_name" { default = "puffin-staging-be" }
variable "web_vm_instance_lb_name" { default = "puffin-staging-lb" }