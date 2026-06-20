packer {
  required_plugins {
    qemu = {
      version = ">= 1.1.5"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

source "qemu" "freebsd" {
  accelerator       = "kvm"
  disk_image        = true
  iso_url           = "freebsd.img"
  iso_checksum      = "none"
  output_directory  = "output-freebsd"
  format            = "qcow2"
  memory            = 2048
  disk_size         = "20480"
  net_device        = "virtio-net"

  ssh_username      = "root"
  ssh_password      = "password"

  disk_interface     = "virtio"

  cd_files = [
    ".machine/freebsd-cloud/cloud-init/user-data",
    ".machine/freebsd-cloud/cloud-init/meta-data"
  ]
  cd_label = "CIDATA"

  shutdown_command  = "shutdown -p now"
  shutdown_timeout  = "1m"

  headless = true
  qemuargs = [
    ["-machine", "type=q35,accel=kvm"],
    ["-boot", "c"],
    ["-display", "none"],
    ["-serial", "file:serial.log"]
  ]
}

build {
  name    = "freebsd"
  sources = ["source.qemu.freebsd"]

  provisioner "shell-local" {
    script = ".machine/machinefile.sh"
    environment_vars = [
      "TARGET=freebsd-cloud",
      "USER_PASSWD=password",
      "SSH_HOST=${build.Host}",
      "SSH_PORT=${build.Port}"]
  }
}

