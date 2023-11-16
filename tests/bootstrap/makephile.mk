# Makephile configuration
#
# For more information, see https://makephile.empaphy.org
MAKEPHILE_VERSION = main

.makephile/bootstrap.mk:
	mkdir -p .makephile && cp ../../bootstrap.mk $@
include .makephile/bootstrap.mk

ifdef MAKEPHILE_LIB
include $(MAKEPHILE_LIB)/usage.mk
endif
