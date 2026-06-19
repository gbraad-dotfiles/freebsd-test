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
    "cloud-init/user-data",
    "cloud-init/meta-data"
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
  sources = ["source.qemu.freebsd"]

  provisioner "shell" {
    inline = [
      "pkg update",
      "pkg install -y git stow zsh curl bash python3 py311-pip",
      "ln -s /usr/local/bin/bash /bin/bash",
      "ln -s /usr/local/bin/python3 /usr/local/bin/python",
      "echo 'update_motd=\"NO\"' >> /etc/rc.conf",
      "echo 'FreeBSD dotfiles' > /etc/motd"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo 'me:\\' > /root/.login_conf",
      "echo '    :charset=UTF-8:\\' >> /root/.login_conf",
      "echo '    :lang=en_US.UTF-8:' >> /root/.login_conf",
      "chmod 600 /root/.login_conf",
      "echo 'echo \"$@\"' > /usr/local/bin/sudo",
      "chmod +x /usr/local/bin/sudo",
      "mv /usr/bin/stat /usr/bin/stat.bak",
      "ln -s /usr/local/bin/gstat /usr/bin/stat",
      "pip install --break-system-packages powerline-status",
      "curl -fsSL https://dotfiles.gbraad.nl/install.sh | sh",
      "pw usermod root -s /usr/local/bin/zsh"
    ]
  }
}

