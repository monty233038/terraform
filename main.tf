terraform {
  cloud {
    organization = ""Terraform-Devprod
    workspace {
      name = "workspace1"
    }
  }
}

provider "google" {
  project = "${var.project_id}"
  credentials = "${file("$(var.credentials)")}"
  region = "${var.region}"
}


resource "google_compute_firewall" "firewall-1" {
  name = "firewall-1"
  network = "default"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports = ["22","80","443"]
  }
}

resource "google_compute_instance" "instance1" {
  machine_type = "e2-micro"
  name = "Instance1"
  boot_disk {
    initialize_params {
      image = "ubuntu-1804-bionic-v20220505"
    }
  }
  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.static-ip.address
    }
  }
  metadata {
    startup_script = >>-EOF
    EOF
  }
}

resource "google_compute_address" "static-ip" {
  name = "statci-ip"
}
resource "google_compute_disk" "disk1" {
  name = "disk1"
  type = "pd-ssd"
  zone = "us-central1-a"
  image = "debian-9-stretch-v20200805"
  size =  "30 GB"
  labels = {
    environment = "dev"
  }
}

resource "google_compute_attached_disk" "attach" {
  disk = google_compute_disk.disk1.name
  instance = google_compute_instance.instance1.name
}

output "Public_Ip" {
  value = "${google_compute_instance.instance1.network_interface.network_ip}"
}
