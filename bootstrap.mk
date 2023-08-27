# Makephile - A library for GNU Make.
#
# This file serves to bootstrap Makephile.
#
# Makephile is a library for GNU Make that provides a set of functions and
# variables to help you write better Makefiles.
#
# For more information, see https://makephile.empaphy.org

MAKEPHILE_HOST            = makephile.empaphy.org
MAKEPHILE_LOCAL_DIR       = .makephile
MAKEPHILE_INCLUDE         = $(MAKEPHILE_LOCAL_DIR)/inc
MAKEPHILE_SHA256SUMS_HASH = b2024244d0ca445107f017847621b33a8c09baa6873c12986028766bc09cc3ff

SHELL 	    := bash
.SHELLFLAGS := -ce

$(MAKEPHILE_INCLUDE)/makephile.mk: $(MAKEPHILE_INCLUDE) $(MAKEPHILE_INCLUDE)/SHA256SUMS
	@$(info Bootstrapping Makephile at $@)
	@$(call _mphl_download_file,$(MAKEPHILE_HOST),/$(subst $(MAKEPHILE_LOCAL_DIR)/,,$@),$@)
	@cd $(MAKEPHILE_INCLUDE); sha256sum --check --ignore-missing SHA256SUMS || rm $@
include $(MAKEPHILE_INCLUDE)/makephile.mk

$(MAKEPHILE_INCLUDE)/SHA256SUMS: $(MAKEPHILE_INCLUDE)
	@$(info Downloading SHA256SUMS to $@)
	@$(call _mphl_download_file,$(MAKEPHILE_HOST),/inc/SHA256SUMS,$@,$(MAKEPHILE_SHA256SUMS_HASH))

$(MAKEPHILE_INCLUDE):
	@mkdir -p $@

########################################
# Download file using bash.
# Parameters:
#   Host to download file from.
#   Path to file on host.
#   Target filename.
#   SHA256 hash that the file should have. (optional)
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
tail --bytes="+$${offset}" "$${mphl_temp}/raw" > "$${mphl_temp}/download"; \
rm -f "$${mphl_temp}/raw"; \
if [ -z '$(4)' ] || echo "$(4) $${mphl_temp}/download" | sha256sum --check --status --strict; then \
  mv "$${mphl_temp}/download" '$(3)'; \
else \
  >&2 echo "ERROR: Incorrect SHA256 checksum for '$(3)'"; \
  exit 1; \
fi
endef
