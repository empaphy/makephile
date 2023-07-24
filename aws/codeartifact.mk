########################################
# AWS CodeArtifact functions for Makephile.
########################################

PHILMK_AWS_CODEARTIFACT_LOGIN_LOCK_FILE = ~/.makephile/aws_codeartifact_login.lock

##
# Sets up NPM to be able to authorize with our private CodeArtifact repository.
#
# Your login information is valid for up to 12 hours, after which you must login again.
#
.PHONY: makephile_aws_codeartifact_login
makephile_aws_codeartifact_login: .makephile
	$(call makephile_MAKE_with_timeout_hours,~/.makephile/aws_codeartifact_login.lock,12,.makephile/12hs_ago)

# Creates a lock file to prevent logging into AWS CodeArtifact while w
##e still have a valid login.
#
~/.makephile/aws_codeartifact_login.lock: .makephile/12hs_ago
	$(philmk_aws_codeartifact_assume_consumer_role); \
	$(philmk_aws) codeartifact login \
	  --tool         'npm' \
	  --repository   '$(AWS_CODEARTIFACT_REPOSITORY)' \
	  --domain       '$(AWS_CODEARTIFACT_DOMAIN)' \
	  --domain-owner '$(AWS_CODEARTIFACT_DOMAIN_OWNER)' \
	  --namespace    '$(AWS_CODEARTIFACT_NAMESPACE)' \
	&& touch $@
