# Makephile - A library for GNU Make.
#
# Makephile is a library for GNU Make that provides a set of functions and
# variables to help you write better Makefiles.
#
# For more information, see https://makephile.empaphy.org

AWS_ACCOUNT           ?= $(shell $(phil_aws_cli) sts get-caller-identity --query Account || exit 1)
AWS_ACCESS_KEY_ID     ?= $(shell $(phil_aws_cli) configure get aws_access_key_id         || exit 1)
AWS_SECRET_ACCESS_KEY ?= $(shell $(phil_aws_cli) configure get aws_secret_access_key     || exit 1)
AWS_SESSION_TOKEN     ?= $(shell $(phil_aws_cli) configure get aws_session_token         || exit 1)
AWS_REGION            ?= $(shell $(phil_aws_cli) configure get region                    || exit 1)

ifndef AWS_PROFILE
	phil_aws_profile_option =
else ifeq ($(AWS_PROFILE), default)
	phil_aws_profile_option =
else
	phil_aws_profile_option = --profile '$(AWS_PROFILE)'

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
.PHONY: phil_aws_export_credentials
phil_aws_export_credentials:
	$(call phil_putenv,AWS_ACCOUNT)
	$(call phil_putenv,AWS_ACCESS_KEY_ID)
	$(call phil_putenv,AWS_SECRET_ACCESS_KEY)
	$(call phil_putenv,AWS_REGION)

phil_aws_cli = aws --output text $(phil_aws_profile_option)
