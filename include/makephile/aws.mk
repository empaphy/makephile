########################################
# AWS functions for Makephile.
########################################

AWS_ACCOUNT           ?= $(shell $(philmk_aws) sts get-caller-identity | jq --raw-output --exit-status '.Account')
AWS_ACCESS_KEY_ID     ?= $(shell $(philmk_aws) configure get aws_access_key_id)
AWS_SECRET_ACCESS_KEY ?= $(shell $(philmk_aws) configure get aws_secret_access_key)
AWS_REGION            ?= $(shell $(philmk_aws) configure get region)

philmk_aws = aws $(philmk_aws_profile_option)

ifndef AWS_PROFILE
	philmk_aws_profile_option =
else ifeq ($(AWS_PROFILE), default)
	philmk_aws_profile_option =
else
	philmk_aws_profile_option = --profile '$(AWS_PROFILE)'

	export AWS_ACCOUNT
	export AWS_REGION
endif

##
# Exports the AWS credentials & related environment variables.
#
# Using this rule allows us to only export these variables when they are needed.
#
# @internal
#
.PHONY: export_aws_credentials
export_aws_credentials:
	$(call export_var,AWS_ACCOUNT)
	$(call export_var,AWS_ACCESS_KEY_ID)
	$(call export_var,AWS_SECRET_ACCESS_KEY)
	$(call export_var,AWS_REGION)
