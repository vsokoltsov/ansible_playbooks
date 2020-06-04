include .env

.PHONY: init
init: 
	@echo "$@"
	terraform init ./terraform

.PHONY: apply
apply:
	@echo "$@"
	terraform apply -auto-approve -var-file=${TERRAFORM_VARIABLES_PATH} -state=${TERRAFORM_STATE_PATH} ./terraform
	ansible-playbook \
		-u $(shell terraform output -state=${TERRAFORM_STATE_PATH} ssh_user) \
		-i $(shell terraform output -state=${TERRAFORM_STATE_PATH} ansible_hosts) \
		--private-key=$(shell terraform output -state=${TERRAFORM_STATE_PATH} ssh_private_key_path) \
		-e "registration_token=${REGISTRATION_TOKEN} gitlab_url=${GITLAB_URL} executor=${EXECUTOR}" \
		playbook/playbook.yml

.PHONY: plan
plan:
	@echo "$@"
	terraform plan -var-file=${TERRAFORM_VARIABLES_PATH} -state=${TERRAFORM_STATE_PATH} ./terraform
	

.PHONY: destroy
destroy:
	@echo "$@"
	terraform destroy -auto-approve -var-file=${TERRAFORM_VARIABLES_PATH} -state=${TERRAFORM_STATE_PATH} ./terraform	
