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
MAKEPHILE_SHA256SUMS_HASH = 047cb70def4b59930b73019145ea218eb57eb45f8e0a67415b8e99da98ec7667

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

# Copyright © 2023 The Empaphy Project
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
