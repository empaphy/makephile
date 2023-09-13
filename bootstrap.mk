# Makephile - A library for GNU Make.
#
# This file serves to bootstrap Makephile.
#
# Makephile is a library for GNU Make that provides a set of functions and
# variables to help you write better Makefiles.
#
# For more information, see https://makephile.empaphy.org

##
# The Makephile version.
#
MAKEPHILE_VERSION = main

MAKEPHILE_HOST            = makephile.empaphy.org
MAKEPHILE_HOME            = .makephile/$(MAKEPHILE_VERSION)
MAKEPHILE_INCLUDE         = $(MAKEPHILE_HOME)/inc
MAKEPHILE_MANIFEST        = SHA256SUMS
MAKEPHILE_MANIFEST_SHA256 = $(MAKEPHILE_MANIFEST).sha256sum

SHELL 	    := bash
.SHELLFLAGS := -ce

$(MAKEPHILE_HOME) $(MAKEPHILE_INCLUDE):
	@mkdir -p $@

$(MAKEPHILE_HOME)/$(MAKEPHILE_MANIFEST_SHA256): $(MAKEPHILE_HOME)
	@_mphl_manifest_url='https://$(MAKEPHILE_HOST)/$(MAKEPHILE_VERSION)/$(MAKEPHILE_MANIFEST_SHA256)'; \
	echo "Attempting to securely download $${_mphl_manifest_url} to $@"; \
	if ! (curl --output '$@' "$$_mphl_manifest_url" || wget --directory-prefix '$(dir $@)' "$$_mphl_manifest_url"); then \
	  echo "Failed to download $${_mphl_makephile_manifest_url}. Download it manually." >&2; \
	  exit 1; \
	fi

$(MAKEPHILE_HOME)/$(MAKEPHILE_MANIFEST): $(MAKEPHILE_HOME)/$(MAKEPHILE_MANIFEST_SHA256)
	@$(info Downloading http://$(MAKEPHILE_HOST)/$(MAKEPHILE_VERSION)/$(MAKEPHILE_MANIFEST) to $@)
	@$(call _mphl_download_file,$(MAKEPHILE_HOST),/$(MAKEPHILE_VERSION)/$(MAKEPHILE_MANIFEST),$@)
	@cd '$(MAKEPHILE_HOME)' && sha256sum --check --strict $(MAKEPHILE_MANIFEST_SHA256)

$(MAKEPHILE_INCLUDE)/makephile.mk: $(MAKEPHILE_INCLUDE) $(MAKEPHILE_HOME)/$(MAKEPHILE_MANIFEST)
	@$(info Bootstrapping Makephile at $@)
	@$(call _mphl_download_file,$(MAKEPHILE_HOST),/$(subst $(MAKEPHILE_HOME)/,$(MAKEPHILE_VERSION)/,$@),$@)
	@cd '$(MAKEPHILE_HOME)' && sha256sum --check --ignore-missing --quiet $(MAKEPHILE_MANIFEST)
include $(MAKEPHILE_INCLUDE)/makephile.mk

########################################
# Download file using bash.
# Parameters:
#   Host to download file from.
#   Path to file on host.
#   Target filename.
########################################
define _mphl_download_file
set -e;                                                                        \
                                                                               \
function _mphl_download_file() {                                               \
  local host='$(1)';                                                           \
  local path='$(2)';                                                           \
  local file='$(3)';                                                           \
                                                                               \
  local temp; temp="$$(mktemp -d)";                                            \
  exec 7<>"/dev/tcp/$${host}/80";                                              \
  echo "GET $${path} HTTP/1.0"$$'\r\n'"Host: $${host}"$$'\r\n\r' >&7;          \
  local raw="$${temp}/raw";                                                    \
  cat <&7 > "$$raw";                                                           \
  local offset; offset=$$(                                                     \
    grep --byte-offset --extended-regexp --max-count=1 --no-filename           \
      $$'^\r?$$' "$$raw"                                                       \
  );                                                                           \
  offset=$$(($${offset%:*}+3));                                                \
  tail --bytes="+$${offset}" "$${temp}/raw" > "$$file";                        \
  rm -f "$${temp}/raw";                                                        \
};                                                                             \
                                                                               \
_mphl_download_file "$$@"
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
