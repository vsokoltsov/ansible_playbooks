resource "random_id" "instance_id" {
    byte_length = 8
}

resource "google_compute_address" "static" {
  count = length(var.docker_options)
  name = "ipv4-address-${element(var.docker_options, count.index)}-${random_id.instance_id.hex}"
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
    count = length(var.docker_options)
    template = "${file(abspath("inventory.tpl"))}"
    depends_on = [
        google_compute_address.static
    ]
    vars = {
        public_ip = "${google_compute_address.static[count.index].address}"
        ansible_user = "${var.ssh_username}"
        ssh_private_key = "${var.ssh_private_key_path}"
    }
}

resource "google_compute_instance" "default" {
    count = length(var.docker_options)
    name         = "gitlab-runner-${element(var.docker_options, count.index)}-${random_id.instance_id.hex}"
    machine_type = "f1-micro"
    zone         = "us-central1-a"

    boot_disk {
        initialize_params {
            image = "centos-7-v20200429"
        }
    }

    metadata = {
        ssh-keys = "${var.ssh_username}:${file(abspath(var.ssh_pub_key_path))}"
    }  

    tags = ["http-server"]

    network_interface {
        network = "default"

        access_config {
            nat_ip = element(google_compute_address.static, count.index).address
        }
    }

    provisioner "local-exec" {
        command = <<EOF
            echo '${data.template_file.hosts[count.index].rendered}' > inventory_${var.docker_options[count.index]}.ini
            ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
                -i inventory_${var.docker_options[count.index]}.ini \
                -e "registration_token=${var.registration_token} gitlab_url=${var.gitlab_url} executor=${var.executor} option=${var.docker_options[count.index]}" \
                playbook.yml
        EOF
    }
}
