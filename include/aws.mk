########################################
# AWS functions for Makephile.
########################################

AWS_ACCOUNT           ?= $(shell $(makephile_aws) sts get-caller-identity | jq --raw-output --exit-status '.Account')
AWS_ACCESS_KEY_ID     ?= $(shell $(makephile_aws) configure get aws_access_key_id)
AWS_SECRET_ACCESS_KEY ?= $(shell $(makephile_aws) configure get aws_secret_access_key)
AWS_REGION            ?= $(shell $(makephile_aws) configure get region)

ifndef AWS_PROFILE
	makephile_aws_profile_option =
else ifeq ($(AWS_PROFILE), default)
	makephile_aws_profile_option =
else
	makephile_aws_profile_option = --profile '$(AWS_PROFILE)'

	export AWS_ACCOUNT
	export AWS_REGION
endif

makephile_aws = aws $(makephile_aws_profile_option)

##
# Exports the AWS credentials & related environment variables.
#
# Using this rule allows us to only export these variables when they are needed.
#
# @internal
#
.PHONY: makephile_export_aws_credentials
makephile_export_aws_credentials:
	$(call export_var,AWS_ACCOUNT)
	$(call export_var,AWS_ACCESS_KEY_ID)
	$(call export_var,AWS_SECRET_ACCESS_KEY)
	$(call export_var,AWS_REGION)
