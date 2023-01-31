terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone = "ru-central1-b"
}


resource "yandex_compute_instance" "tf-zbx-srv-01" {
  name                      = "zserver"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    mode = "READ_WRITE"
    initialize_params {
      image_id = "fd8le2jsge1bop4m18ts"
      size     = 10
    }
  }

  network_interface {
    subnet_id = "e2lc787nsvkucok4k04h" # yandex_vpc_subnet.zbxsubnet-1.id
    nat       = true
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
    ssh-keys  = "artemiev:${file("~/.ssh/id_ed25519.pub")}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update && sudo apt full-upgrade -y",
      #"sudo apt install ansible -y",
      "sudo apt install git -y",
      "sudo apt install atop -y",
      "sudo apt install postgresql -y",
      "sudo apt install ca-certificates curl gnupg lsb-release -y",
      "sudo wget https://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-release_6.0-4%2Bdebian11_all.deb",
      "sudo dpkg -i zabbix-release_6.0-4+debian11_all.deb",
      "sudo apt update",
      "sudo apt install zabbix-server-pgsql zabbix-frontend-php php7.4-pgsql zabbix-apache-conf zabbix-sql-scripts zabbix-agent -y",
      "sudo postgres -c 'psql --command \"CREATE USER zabbix WITH PASSWORD \\\"123456789\\\";\"'",
      "sudo postgres -c 'psql --command \"CREATE DATABASE zabbix OWNER zabbix;\"'",
      "zcat /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz | sudo -u zabbix psql zabbix",
      "sed -i 's/# DBPassword=/DBPassword=123456789/g' /etc/zabbix/zabbix_server.conf",
      "sudo systemctl restart zabbix-server apache2",
      "sudo systemctl enable zabbix-server apache2"
    ]
    connection {
      type        = "ssh"
      user        = "artemiev"
      private_key = file("~/.ssh/id_ed25519")
      host        = self.network_interface[0].nat_ip_address
    }
  }

  scheduling_policy {
    preemptible = true
  }
}

resource "yandex_compute_instance" "tf-zbx-agt-01" {
  name                      = "zagent"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    mode = "READ_WRITE"
    initialize_params {
      image_id = "fd8le2jsge1bop4m18ts"
      size     = 10
    }
  }

  network_interface {
    subnet_id = "e2lc787nsvkucok4k04h" # yandex_vpc_subnet.zbxsubnet-1.id
    nat       = true
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
    ssh-keys  = "artemiev:${file("~/.ssh/id_ed25519.pub")}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update && sudo apt full-upgrade -y",
      "sudo apt install git -y",
      "sudo apt install atop -y",
      "sudo apt install ca-certificates curl gnupg lsb-release -y",
      "sudo wget https://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-release_6.0-4%2Bdebian11_all.deb",
      "sudo dpkg -i zabbix-release_6.0-4+debian11_all.deb",
      "sudo apt update",
      "sudo apt install zabbix-agent -y",
      "sudo systemctl restart zabbix-agent",
      "sudo systemctl enable zabbix-agent"
    ]
    connection {
      type        = "ssh"
      user        = "artemiev"
      private_key = file("~/.ssh/id_ed25519")
      host        = self.network_interface[0].nat_ip_address
    }
  }

  scheduling_policy {
    preemptible = true
  }
}

## Создать вручную в web gui - жду поддержку ЯО
# resource "yandex_vpc_network" "zbxnet-1" {
#  name = "yanet01"
#}
## Создать вручную в web gui - жду поддержку ЯО
#resource "yandex_vpc_subnet" "zbxsubnet-1" {
#  name           = "zbxsubnet01"
#  zone           = "ru-central1-b"
#  network_id     = yandex_vpc_network.zbxnet-1.id
#  v4_cidr_blocks = ["192.168.10.0/24"]
#}

output "internal_ip_address_zbxsrv_01" {
  value = yandex_compute_instance.tf-zbx-srv-01.network_interface.0.ip_address
}
output "external_ip_address_zbxsrv_01" {
  value = yandex_compute_instance.tf-zbx-srv-01.network_interface.0.nat_ip_address
}

output "internal_ip_address_zbxagt_01" {
  value = yandex_compute_instance.tf-zbx-agt-01.network_interface.0.ip_address
}
output "external_ip_address_zbxagt_01" {
  value = yandex_compute_instance.tf-zbx-agt-01.network_interface.0.nat_ip_address
}