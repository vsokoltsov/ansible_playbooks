output "vm_ip" {
  description = "IP address for generated compute instance"
  value = google_compute_address.static.address
}

output "ssh_private_key_path" {
  value = abspath(var.ssh_private_key_path)
}

output "ssh_public_key_path" {
  value = abspath(var.ssh_pub_key_path)
}

output "ssh_user" {
  value = var.ssh_username
}

output "registration_token" {
  value = var.registration_token
}

output "gitlab_url" {
  value = var.gitlab_url
}

output "executor" {
  value = var.executor
}