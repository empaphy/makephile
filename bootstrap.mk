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
MAKEPHILE_VERSION         = HEAD
MAKEPHILE_SHA256SUMS_HASH = 874a8ee5f7086d76b92fec18764ca306810eab2db602219ad6263faf0495fa80

MAKEPHILE_HOST       = makephile.empaphy.org
MAKEPHILE_HOME       = .makephile
MAKEPHILE_INCLUDE    = $(MAKEPHILE_HOME)/inc
MAKEPHILE_SHA256SUMS = SHA256SUMS

SHELL 	    := bash
.SHELLFLAGS := -ce

$(MAKEPHILE_INCLUDE)/makephile.mk: $(MAKEPHILE_INCLUDE) $(MAKEPHILE_HOME)/$(MAKEPHILE_SHA256SUMS)
	@$(info Bootstrapping Makephile at $@)
	@$(call _mphl_download_file,$(MAKEPHILE_HOST),/$(subst $(MAKEPHILE_HOME)/,,$@),$@)
	@$(_mphl_check_sha256sums)
include $(MAKEPHILE_INCLUDE)/makephile.mk

$(MAKEPHILE_HOME)/$(MAKEPHILE_SHA256SUMS): $(MAKEPHILE_HOME)
	@$(info Downloading http://$(MAKEPHILE_HOST)/$(MAKEPHILE_VERSION).sha256 to $@)
	@$(call _mphl_download_file,$(MAKEPHILE_HOST),/$(MAKEPHILE_VERSION).sha256,$@)
	@$(_mphl_check_sha256sums)

$(MAKEPHILE_HOME) $(MAKEPHILE_INCLUDE):
	@mkdir -p $@

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

########################################
# Check the SHA256SUMS file in the local `.makephile` dir.
# Parameters:
#   Host to download file from.
#   Path to file on host.
#   Target filename.
########################################
define _mphl_check_sha256sums
set -e; \
cd $(MAKEPHILE_HOME); \
if ! echo "$(MAKEPHILE_SHA256SUMS_HASH) $(MAKEPHILE_SHA256SUMS)" | sha256sum --check --status --strict; then \
  echo "Failed to verify hash for '$(MAKEPHILE_SHA256SUMS)'." >&2; \
  exit 1; \
fi; \
if ! sha256sum --check --ignore-missing $(MAKEPHILE_SHA256SUMS); then \
  exit 1; \
fi
endef
