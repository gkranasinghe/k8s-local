variable "master_count" {
  type    = number
  default = 1
}
variable "worker_count" {
  type    = number
  default = 1
}



variable "lxd_cidr" {
  type    = string
  default = "10.140.19.1/24"
}

variable "nfs_ip" {
  type    = string
  default = "10.140.19.30"
}

variable "ansible_dir" {
  type    = string
  default = "./ansible/"
}

variable "nfs_source" {
  type    = string
  default ="/dev/disk/by-id/nvme-Micron_2200V_MTFDHBA512TCK__19402444B82D-part5"
}
