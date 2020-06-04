variable "ssh_username" {
    type = string
    description = "Name of user for gce instance"
}

variable "ssh_pub_key_path" {
    type = string
    description = "Path to ssh public key"
}

variable "ssh_private_key_path" {
    type = string
    description = "Path to ssh private key"
}

variable "ansible_hosts" {
    type = string
}

provider "google" {
    credentials = file(abspath("credentials/serviceaccount.json"))
    project     = "blog-276519"
    region      = "us-central1"
}