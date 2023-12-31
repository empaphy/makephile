# Makephile - A library for GNU Make.
#
# This file serves to bootstrap Makephile.
#
# Makephile is a library for GNU Make that provides a set of functions and
# variables to help you write better Makefiles.
#
# For more information, see https://makephile.empaphy.org

MAKEPHILE_HOME    ?= .makephile
MAKEPHILE_VERSION ?= main
MAKEPHILE_BASE_URL = https://raw.githubusercontent.com/empaphy/makephile/$(MAKEPHILE_VERSION)

$(MAKEPHILE_HOME)/lib.mk:
	@curl --fail --silent --create-dirs --show-error --output '$@' '$(MAKEPHILE_BASE_URL)/lib.mk'
include $(MAKEPHILE_HOME)/lib.mk
