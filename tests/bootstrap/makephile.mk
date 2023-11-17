# Makephile configuration
# For more information, see https://makephile.empaphy.org
MAKEPHILE_VERSION = main

.makephile/bootstrap.mk:
	@curl --fail --silent --create-dirs --show-error --output $@ https://makephile.empaphy.org/bootstrap.mk
include .makephile/bootstrap.mk

ifdef MAKEPHILE_LIB
include $(MAKEPHILE_LIB)/usage.mk
endif
