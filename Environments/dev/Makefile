clean:
	rm -rf .terraform
	rm -rf .terraform.lock.hcl
	rm -rf tfplan.binary
	rm -rf tf.plan
	rm -rf tfplan.json
	rm -rf tfplan.txt

init:
	terraform fmt -recursive ../../
	AWS_PROFILE=DTEST terraform init -backend-config=../../Backend/DEV-Backend.hcl -upgrade
	terraform validate

plan:
	make init
	AWS_PROFILE=DTEST terraform plan -var-file="dev.tfvars" -out tf.plan && terraform show -no-color tf.plan > tfplan.txt

apply:
	echo -e '\033[36m ------ Going to Apply ------ \033[0m'
	AWS_PROFILE=DTEST terraform apply "tf.plan"

deploy:
	echo -e '\033[36m ------ Going to Deploy ------ \033[0m'
	make plan
	make apply

summary_plan:
	@terraform show -no-color -json tf.plan > tfplan.json
	@echo "\nTo Create: ✅" && cat tfplan.json | jq -r '.resource_changes[] | select(.change.actions[0]=="create") | .address'
	@echo "\nTo Modify: ✏️" && cat tfplan.json | jq -r '.resource_changes[] | select(.change.actions[0]=="update") | .address'
	@echo "\nTo Delete: ❌ " && cat tfplan.json | jq -r '.resource_changes[] | select(.change.actions[0]=="delete") | .address'
