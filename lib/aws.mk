# Makephile - A library for GNU Make.
#
# Makephile is a library for GNU Make that provides a set of functions and
# variables to help you write better Makefiles.
#
# For more information, see https://makephile.empaphy.org

AWS_ACCOUNT           ?= $(shell $(aws) --output text sts get-caller-identity --query Account || exit 1)
AWS_ACCESS_KEY_ID     ?= $(shell $(aws) configure get aws_access_key_id                       || exit 1)
AWS_SECRET_ACCESS_KEY ?= $(shell $(aws) configure get aws_secret_access_key                   || exit 1)
AWS_SESSION_TOKEN     ?= $(shell $(aws) configure get aws_session_token                       || exit 1)
AWS_REGION            ?= $(shell $(aws) configure get region                                  || exit 1)

aws = aws --output text
