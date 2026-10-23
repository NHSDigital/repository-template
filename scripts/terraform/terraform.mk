# Terraform Make Targets for TFScaffold
# NHS Notify standard for production infrastructure
# Requires infrastructure/terraform/bin/terraform.sh

# ==============================================================================
# TFScaffold Terraform Operations

terraform-plan: # Plan Terraform changes - mandatory: component=[component_name], environment=[environment]; optional: project=[default: nhs], region=[default: eu-west-2], group=[default: dev], opts=[additional options] @Development
	# Example: make terraform-plan component=mycomp environment=myenv group=mygroup
	# Args: --project nhs --region eu-west-2 --component mycomp --environment myenv --group mygroup --action plan
	make _terraform-scaffold action=plan \
		component=$(component) \
		environment=$(environment) \
		project=$(or ${project}, nhs) \
		region=$(or ${region}, eu-west-2) \
		group=$(or ${group}, dev) \
		opts=$(or ${opts},)

terraform-plan-destroy: # Plan Terraform destroy - mandatory: component=[component_name], environment=[environment]; optional: project, region, group, opts @Development
	# Example: make terraform-plan-destroy component=mycomp environment=myenv group=mygroup
	# Args: --project nhs --region eu-west-2 --component mycomp --environment myenv --group mygroup --action plan-destroy
	make _terraform-scaffold action=plan-destroy \
		component=$(component) \
		environment=$(environment) \
		project=$(or ${project}, nhs) \
		region=$(or ${region}, eu-west-2) \
		group=$(or ${group}, dev) \
		opts=$(or ${opts},)

terraform-apply: # Apply Terraform changes - mandatory: component=[component_name], environment=[environment]; optional: project, region, group, build_id, opts @Development
	# Example: make terraform-apply component=mycomp environment=myenv group=mygroup
	# Args: --project nhs --region eu-west-2 --component mycomp --environment myenv --group mygroup --action apply
	make _terraform-scaffold action=apply \
		component=$(component) \
		environment=$(environment) \
		project=$(or ${project}, nhs) \
		region=$(or ${region}, eu-west-2) \
		group=$(or ${group}, dev) \
		build_id=$(or ${build_id},) \
		opts=$(or ${opts},)

terraform-destroy: # Destroy Terraform resources - mandatory: component=[component_name], environment=[environment]; optional: project, region, group, opts @Development
	# Example: make terraform-destroy component=mycomp environment=myenv group=mygroup
	# Args: --project nhs --region eu-west-2 --component mycomp --environment myenv --group mygroup --action destroy
	make _terraform-scaffold action=destroy \
		component=$(component) \
		environment=$(environment) \
		project=$(or ${project}, nhs) \
		region=$(or ${region}, eu-west-2) \
		group=$(or ${group}, dev) \
		opts=$(or ${opts},)

terraform-output: # Get Terraform outputs - mandatory: component=[component_name], environment=[environment]; optional: project, region, group @Development
	# Example: make terraform-output component=mycomp environment=myenv group=mygroup
	# Args: --project nhs --region eu-west-2 --component mycomp --environment myenv --group mygroup --action output
	make _terraform-scaffold action=output \
		component=$(component) \
		environment=$(environment) \
		project=$(or ${project}, nhs) \
		region=$(or ${region}, eu-west-2) \
		group=$(or ${group}, dev)

_terraform-scaffold: # Internal wrapper for terraform.sh - mandatory: action=[terraform action]; optional: component, environment, project, region, group, bootstrap, build_id, opts
	cd infrastructure/terraform && \
	if [ "$(bootstrap)" = "true" ]; then \
		./bin/terraform.sh \
			--bootstrap \
			--project $(project) \
			--region $(region) \
			--group $(group) \
			--action $(action) \
			$(if $(opts),-- $(opts),); \
	else \
		./bin/terraform.sh \
			--project $(project) \
			--region $(region) \
			--component $(component) \
			--environment $(environment) \
			--group $(group) \
			$(if $(build_id),--build-id $(build_id),) \
			--action $(action) \
			$(if $(opts),-- $(opts),); \
	fi

# ==============================================================================
# Formatting and Validation

terraform-fmt: # Format Terraform files in components/ and modules/ (excludes etc/) @Quality
	# Example: make terraform-fmt
	@cd infrastructure/terraform && \
		for dir in components modules; do \
			[ -d "$$dir" ] && terraform fmt -recursive "$$dir"; \
		done

terraform-fmt-check: # Check Terraform formatting in components/ and modules/ (excludes etc/) @Quality
	# Example: make terraform-fmt-check
	@cd infrastructure/terraform && \
		for dir in components modules; do \
			[ -d "$$dir" ] && terraform fmt -check -recursive "$$dir"; \
		done

terraform-validate: # Validate Terraform configuration - mandatory: component=[component_name] @Quality
	# Example: make terraform-validate component=mycomp
	# Note: Validation does not require environment/group as it checks syntax only
	cd infrastructure/terraform/components/$(component) && \
	terraform init -backend=false && \
	terraform validate

terraform-validate-all: # Validate all Terraform components @Quality
	# Example: make terraform-validate-all
	for dir in infrastructure/terraform/components/*; do \
		if [ -d "$$dir" ]; then \
			echo "Validating $$(basename $$dir)..."; \
			cd $$dir && \
			terraform init -backend=false && \
			terraform validate && \
			cd - > /dev/null; \
		fi; \
	done

terraform-docs: # Generate Terraform documentation - optional: component=[specific component, or all if omitted] @Quality
	# Example: make terraform-docs component=mycomp
	# Example: make terraform-docs (generates for all components)
	@if [ -n "$(component)" ]; then \
		./scripts/terraform/terraform-docs.sh infrastructure/terraform/components/$(component); \
	else \
		for dir in infrastructure/terraform/components/* infrastructure/terraform/modules/*; do \
			if [ -d "$$dir" ]; then \
				./scripts/terraform/terraform-docs.sh $$dir; \
			fi; \
		done; \
	fi

# ==============================================================================
# Cleanup

clean:: # Remove Terraform build artifacts and cache @Operations
	# Example: make clean
	rm -rf infrastructure/terraform/components/*/build
	rm -rf infrastructure/terraform/components/*/.terraform
	rm -rf infrastructure/terraform/components/*/.terraform.lock.hcl
	rm -rf infrastructure/terraform/bootstrap/.terraform
	rm -rf infrastructure/terraform/bootstrap/.terraform.lock.hcl
	rm -rf infrastructure/terraform/plugin-cache/*

# ==============================================================================
# Installation

terraform-install: # Install Terraform using mise @Installation
	# Example: make terraform-install
	make _install-dependency name="terraform"

# ==============================================================================

${VERBOSE}.SILENT: \
	_terraform-scaffold \
	clean \
	terraform-apply \
	terraform-destroy \
	terraform-docs \
	terraform-fmt \
	terraform-fmt-check \
	terraform-install \
	terraform-output \
	terraform-plan \
	terraform-plan-destroy \
	terraform-validate \
	terraform-validate-all \
#	terraform-sec \
