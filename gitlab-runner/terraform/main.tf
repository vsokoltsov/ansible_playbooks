resource "random_id" "instance_id" {
    byte_length = 8
}

resource "google_compute_address" "static" {
  name = "ipv4-address-${random_id.instance_id.hex}"
}

resource "google_compute_firewall" "http-server" {
  name    = "blog-allow-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  // Allow traffic from everywhere to instances with an http-server tag
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

data "template_file" "hosts" {
    template = "${file(abspath("playbook/host_template.tpl"))}"
    depends_on = [
        google_compute_address.static
    ]
    vars = {
        vm_ip = "${google_compute_address.static.address}"
        ansible_user = "${var.ssh_username}"
    }
}

resource "google_compute_instance" "default" {
    name         = "gitlab-runner-${random_id.instance_id.hex}"
    machine_type = "f1-micro"
    zone         = "us-central1-a"

    boot_disk {
        initialize_params {
            image = "centos-7-v20200429"
        }
    }

// Make sure flask is installed on all new instances for later steps
    # metadata_startup_script = "sudo yum install -y nginx && sudo systemctl start nginx && sudo systemctl enable nginx"

    metadata = {
        ssh-keys = "${var.ssh_username}:${file(abspath(var.ssh_pub_key_path))}"
    }  

    tags = ["http-server"]

    network_interface {
        network = "default"

        access_config {
            nat_ip = google_compute_address.static.address
        }
    }

    provisioner "local-exec" {
        command = <<EOF
            echo '${data.template_file.hosts.rendered}' > '${abspath(var.ansible_hosts)}'
        EOF
    }
}
