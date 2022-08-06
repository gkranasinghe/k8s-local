resource "lxd_container" "master" {

  count = var.master_count
  name  = "k8s-master${count.index}"

  image     = "ubuntu:20.04"
  ephemeral = false
  profiles  = ["${lxd_profile.profile-master.name}"]

  config = {
    "boot.autostart" = false
  }
  device {
    name = "eth0"
    type = "nic"

    properties = {
      nictype        = "bridged"
      parent         = "${lxd_network.localk8snw.name}"
      "ipv4.address" = "${substr(var.lxd_cidr,0,10)}1${count.index}"
    }
  }


  limits = {
    cpu = 2
  }


  provisioner "local-exec" {


    working_dir = var.ansible_dir
    command     = " ansible-playbook -i ${self.name},  k8s-master-playbook.yaml -e \" ansible_python_interpreter=/usr/bin/python3  hosttempfile_location=$PWD\" -vv "
    # on_failure = fail
  }


}

resource "lxd_container" "worker" {
  depends_on = [
    lxd_container.master
  ]
  count = var.worker_count
  name  = "k8s-worker${count.index}"

  image     = "ubuntu:20.04"
  ephemeral = false

  profiles  = ["${lxd_profile.profile-worker.name}"]

  config = {
    "boot.autostart" = false
  }
  device {
    name = "eth0"
    type = "nic"

    properties = {
      nictype        = "bridged"
      parent         = "${lxd_network.localk8snw.name}"
      "ipv4.address" = "${substr(var.lxd_cidr,0,10)}2${count.index}"
    }
  }

  provisioner "local-exec" {

    


    working_dir = var.ansible_dir
    command     = " ansible-playbook -i ${self.name},k8s-master0  k8s-worker-playbook.yaml -e \" ansible_python_interpreter=/usr/bin/python3  hosttempfile_location=$PWD\" -vv "
    on_failure  = fail
  }


}

resource "lxd_container" "nfs" {
  depends_on = [
    lxd_container.master
  ]


  name  = "k8s-nfsserver0"

  image     = "ubuntu:20.04"
  ephemeral = false
  profiles  = ["${lxd_profile.profile-nfs-server.name}"]

  config = {
    "boot.autostart" = false
  }
  device {
    name = "eth0"
    type = "nic"

    properties = {
      nictype        = "bridged"
      parent         = "${lxd_network.localk8snw.name}"
      "ipv4.address" = var.nfs_ip
    }
  }
  limits = {
    cpu = 2
  }

}

resource "null_resource" "nfs_source" {
    depends_on = [
    lxd_container.worker
  ]
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    nfs_source = var.nfs_source
  }
  provisioner "local-exec" {
    working_dir = var.ansible_dir
    command     = " ansible-playbook -i ${lxd_container.nfs.name},  k8s-nfs-playbook.yaml -e \" ansible_python_interpreter=/usr/bin/python3 nfs_source=${var.nfs_source} hosttempfile_location=$PWD\" -vv "
    # on_failure = fail
  }
}

