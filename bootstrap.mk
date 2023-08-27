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
MAKEPHILE_MK              = $(MAKEPHILE_LOCAL_DIR)/makephile.mk
MAKEPHILE_SHA256SUMS_HASH = de535b046082bb717ee3b970227545b0b0faf0c73d4e3071f52be8d7119bd2ac

SHELL 	    := bash
.SHELLFLAGS := -ce

$(MAKEPHILE_MK): $(MAKEPHILE_LOCAL_DIR) $(MAKEPHILE_LOCAL_DIR)/SHA256SUMS
	@$(info Bootstrapping Makephile at $@)
	@$(call _mphl_download_file,$(MAKEPHILE_HOST),/$(subst $(MAKEPHILE_LOCAL_DIR)/,inc/,$@),$@)
include $(MAKEPHILE_MK)

$(MAKEPHILE_LOCAL_DIR)/SHA256SUMS: $(MAKEPHILE_LOCAL_DIR)
	@$(info Downloading SHA256SUMS to $@)
	@$(call _mphl_download_file,$(MAKEPHILE_HOST),/inc/SHA256SUMS,$@,$(MAKEPHILE_SHA256SUMS_HASH))

$(MAKEPHILE_LOCAL_DIR):
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
fi
endef
