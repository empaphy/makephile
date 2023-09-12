# Makephile - A library for GNU Make.
#
# This file serves to bootstrap Makephile.
#
# Makephile is a library for GNU Make that provides a set of functions and
# variables to help you write better Makefiles.
#
# For more information, see https://makephile.empaphy.org

##
# The Makephile version and accompanying hash.
#
# IMPORTANT: Whenever you bump your Makephile version, you should update the
#            accompanying hash as well!
#
MAKEPHILE_VERSION         = dev
MAKEPHILE_SHA256SUMS_HASH = a0d24d43124c09d7c0070a408069d3f0e6b0c461fc06f7750727bccaaeae087f

MAKEPHILE_HOST       = makephile.empaphy.org
MAKEPHILE_HOME       = .makephile/$(MAKEPHILE_VERSION)
MAKEPHILE_INCLUDE    = $(MAKEPHILE_HOME)/inc
MAKEPHILE_SHA256SUMS = SHA256SUMS

SHELL 	    := bash
.SHELLFLAGS := -ce

$(MAKEPHILE_HOME) $(MAKEPHILE_INCLUDE):
	@mkdir -p $@

$(MAKEPHILE_HOME)/$(MAKEPHILE_SHA256SUMS): $(MAKEPHILE_HOME)
	@$(info Downloading http://$(MAKEPHILE_HOST)/$(MAKEPHILE_VERSION).sha256 to $@)
	@$(call _mphl_download_file,$(MAKEPHILE_HOST),/$(MAKEPHILE_VERSION).sha256,$@)
	@echo "$(MAKEPHILE_SHA256SUMS_HASH) $@" | sha256sum --check --quiet --strict

$(MAKEPHILE_INCLUDE)/makephile.mk: $(MAKEPHILE_INCLUDE) $(MAKEPHILE_HOME)/$(MAKEPHILE_SHA256SUMS)
	@$(info Bootstrapping Makephile at $@)
	@$(call _mphl_download_file,$(MAKEPHILE_HOST),/$(subst $(MAKEPHILE_HOME)/,,$@),$@)
	@cd '$(MAKEPHILE_HOME)' && sha256sum --check --ignore-missing --quiet $(MAKEPHILE_SHA256SUMS)
include $(MAKEPHILE_INCLUDE)/makephile.mk

########################################
# Download file using bash.
# Parameters:
#   Host to download file from.
#   Path to file on host.
#   Target filename.
########################################
define _mphl_download_file
set -e; \
mphl_temp="$$(mktemp -d)"; \
exec 7<>'/dev/tcp/$(1)/80'; \
echo $$'GET $(2) HTTP/1.0\r\nHost: $(1)\r\n\r' >&7; \
offset=$$( \
  cat <&7 | tee "$${mphl_temp}/raw" | \
  grep --byte-offset --extended-regexp --max-count=1 --no-filename $$'^\r?$$' \
); \
offset=$$(($${offset%:*}+3)); \
tail --bytes="+$${offset}" "$${mphl_temp}/raw" > '$(3)'; \
rm -f "$${mphl_temp}/raw"
endef
