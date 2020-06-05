#!/bin/bash

set -e

source .env

case "$1" in
  plan)
    terraform plan -var-file=${TERRAFORM_VARIABLES_PATH} -state=${TERRAFORM_STATE_PATH} ./terraform
    ;;
  apply)
    echo "Applyin resources and provision them..."
	  terraform apply -auto-approve -var-file=${TERRAFORM_VARIABLES_PATH} -state=${TERRAFORM_STATE_PATH} ./terraform
	  ansible-playbook \
      -i $(terraform output -state=${TERRAFORM_STATE_PATH} ansible_hosts) \
      --private-key=$(terraform output -state=${TERRAFORM_STATE_PATH} ssh_private_key_path) \
      -e "registration_token=${REGISTRATION_TOKEN} gitlab_url=${GITLAB_URL} executor=${EXECUTOR}" \
      playbook/playbook.yml
    ;;
  destroy)
    echo "Destroying resources..."
    terraform destroy -auto-approve -var-file=${TERRAFORM_VARIABLES_PATH} -state=${TERRAFORM_STATE_PATH} ./terraform
    ;;
  init)
    echo "Initializing terraform folder..."
    terraform init ./terraform
    ;;
  *)
    echo "Usage: $0 {plan|init|apply|destroy}" >&2
    exit 1
    ;;
esac