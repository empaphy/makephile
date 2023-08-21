# Makephile - A library for GNU Make.
#
# This file serves to bootstrap Makephile.
#
# Makephile is a library for GNU Make that provides a set of functions and
# variables to help you write better Makefiles.
#
# For more information, see https://makephile.empaphy.org

MAKEPHILE_HOST            = makephile.empaphy.org
MAKEPHILE_INCLUDE         = 1
MAKEPHILE_LOCAL_DIR       = .makephile
MAKEPHILE_MK              = $(MAKEPHILE_LOCAL_DIR)/makephile.mk
MAKEPHILE_SHA256SUMS_HASH = 6427831247ec8f4721242cf62a18bf15bcefe660829771392df48b247ba003a2

SHELL 	    := bash
.SHELLFLAGS := -ce

$(MAKEPHILE_MK): $(MAKEPHILE_LOCAL_DIR) $(MAKEPHILE_LOCAL_DIR)/SHA224SUMS
	@$(info Bootstrapping Makephile at $@)
	@$(call _mphl_download_file,$(MAKEPHILE_HOST),/$(subst $(MAKEPHILE_LOCAL_DIR)/,include/,$@),$@)
include $(MAKEPHILE_MK)

# TODO Versioning?
$(MAKEPHILE_LOCAL_DIR)/SHA224SUMS: $(MAKEPHILE_LOCAL_DIR)
	@$(info Downloading SHA224SUMS to $@)
	@$(call _mphl_download_file,$(MAKEPHILE_HOST),/include/SHA224SUMS,$@,$(MAKEPHILE_SHA256SUMS_HASH))

$(MAKEPHILE_LOCAL_DIR):
	@mkdir -p $@

# TODO add support for checking sha224sum
define _mphl_download_file
set -ex; \
_mphl_temp_dir="$$(mktemp -d)"; \
exec 7<>'/dev/tcp/$(1)/80'; \
echo $$'GET $(2) HTTP/1.0\r\nHost: $(1)\r\n\r' >&7; \
offset=$$( \
  cat <&7 | tee "$${_mphl_temp_dir}/raw" | \
  grep --byte-offset --extended-regexp --max-count=1 --no-filename $$'^\r?$$' \
); \
offset=$$(($${offset%:*}+3)); \
tail --bytes="+$${offset}" "$${_mphl_temp_dir}/raw" > "$${_mphl_temp_dir}/download"; \
rm -f "$${_mphl_temp_dir}/raw"; \
if [ -z '$(4)' ] || echo "$(4) $${_mphl_temp_dir}/download" | sha256sum --status --strict; then
mv "$${_mphl_temp_dir}/download" '$(3)'
endef
