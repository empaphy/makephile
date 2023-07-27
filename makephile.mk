####
## Makephile v0.1.0 - A library for GNU Make.
##
## Makephile is a library for GNU Make that provides a set of functions and
## variables to help you write better Makefiles.
##
## For more information, see https://makephile.empaphy.org
##

MAKEPHILE_LOADED         := 1
MAKEPHILE_LOCAL_DIR      := .makephile
MAKEPHILE_LOCAL_INCLUDES := $(addprefix $(MAKEPHILE_LOCAL_DIR)/,usage.mk aws.mk)
MAKEPHILE_VERSION        := 0.1.0

SHELL 	    := bash
.SHELLFLAGS := -ce

##
# Gives some basic info about Makephile.
#
# @internal
#
.PHONY: makephile_about
makephile_about:
	@echo 'Makephile v$(MAKEPHILE_VERSION) - A library for GNU Make.'
	@echo 'For more information, see https://makephile.empaphy.org'

##
# Ensure .makephile is present for the other include files.
#
# @internal
#
$(MAKEPHILE_LOCAL_INCLUDES): $(MAKEPHILE_LOCAL_DIR)
	@$(call philmk_download_include_file,$@)

##
# Creates a local `.makephile` directory.
#
# @internal
#
$(MAKEPHILE_LOCAL_DIR):
	@mkdir -p $@

##
# Removes any locally installed Makephile files.
#
makephile_clean:
	@rm -rf $(MAKEPHILE_LOCAL_DIR) .makephile.mk

##
# Clones the Makephile Git repository to the ~/.empaphy directory.
#
# @internal
#
~/.empaphy/makephile: | ~/.empaphy
	@git clone https://github.com/empaphy/makephile.git -- $@

##
# Create ~/.empaphy config dir in the user's home directory.
#
# @internal
#
~/.empaphy:
	@mkdir $@

##
# Outputs information about the current target.
#
makephile_target_info = $(eval $(info $(NEWLINE)$(philmk_bold)> Target $@$(philmk_sgr)))

##
# Make the target with a timeout, by providing a timeout target.
#
# @param The target to make.
# @param The number of hours after which the target should be considered old.
# @param The timeout file to create. Use this as dependency for your target.
#
define makephile_MAKE_with_timeout_hours
touch -A '-$(2)0000' '$(3)' > /dev/null 2>&1 || touch -d '$(2) hours ago' '$(3)' > /dev/null 2>&1; \
${MAKE} $(1)
endef

makephile_regex_escape_value = $(shell echo "$(1)" | sed 's/[]\/$$*.^[]/\\&/g' || exit 1)

##
# Contains the appropriate `-i` option usage for `sed`, depending on what is available.
#
makephile_sed_in_place_option = $(shell sed --version >/dev/null 2>&1 && echo '-i ""' || echo '-i')

##
# `sed` command with the appropriate `-i` option for in-place editing.
#
# Usage of the `-i` operate on FreeBSD and GNU sed differs, so we need to check which one applies.
#
makephile_sed_in_place = sed $(makephile_sed_in_place_option)

##
# Returns a substring of the provided string.
#
# @param The string to get the substring from.
# @param The start index. (NOTE: Negative values are _NOT_ allowed.)
# @param The end index.   (NOTE: Negative values are _NOT_ allowed.)
#
makephile_substr = $(shell echo "$(1)" | cut -c$(2)-$(3))

##
# Provides a unique temporary directory.
#
makephile_temp_dir = $(shell mktemp -d -t makephile)

##
# Returns a unique temporary file path.
#
# @param The file name to use.
#
makephile_get_temp_file = $(makephile_temp_dir)/$(1)

##
# Exports the provided environment variables.
#
# @param The environment variable to export.
#
define makephile_export_var
$(eval export $(1))
endef

##
# Downloads an include file.
#
# @internal
#
# @param  include_file  The include file to download.
#
define philmk_download_include_file
@$(call philmk_download_file,makephile.empaphy.org,/$(subst $(MAKEPHILE_LOCAL_DIR)/,include/,$(1)),$(1))
endef

##
# Downloads a file, without needing curl, wget or any other dependency.
#
# NOTE: Only supports unencrypted HTTP.
#
# @internal
#
# @param  The host to download from.
# @param  The path to download.
# @param  The file to save to.
#
define philmk_download_file
set -e; \
philmk_host='$(1)'; \
philmk_path='$(2)'; \
philmk_file='$(3)'; \
philmk_temp='$(call makephile_get_temp_file,philmk_download_file)'; \
exec 7<>"/dev/tcp/$${philmk_host}/80"; \
printf "GET $${philmk_path} HTTP/1.0\r\nHost: $${philmk_host}\r\n\r\n" >&7; \
cat > "$$philmk_temp" <&7; \
offset="$$(grep --byte-offset --extended-regexp --max-count=1 --no-filename '^'$$'\r''?$$' "$$philmk_temp")"; \
offset="$${offset%:*}"; \
offset=$$((offset+3)); \
tail "+$${offset}c" "$$philmk_temp" > "$$philmk_file"
endef

##
# Output bold text.
#
# @internal
#
philmk_bold := $(shell [ -n "$$TERM" ] && [ "$$TERM" != "dumb" ] && tput bold || echo -n '')

##
# Reset the text style.
#
# @internal
#
philmk_sgr  := $(shell [ -n "$$TERM" ] && [ "$$TERM" != "dumb" ] && tput sgr0 || echo -n '')

##
# Used to create a newline.
#
# @internal
#
philmk_newline :=
define NEWLINE

$(philmk_newline)
endef

##
# Contains the best possible regular expression flag for grep, depending on what is available.
#
# So, either `--perl-regexp` or `--extended-regexp`.
#
makephile_grep_regexp_flag := $(shell \
  echo | grep --perl-regexp --only-matching --quiet '^$$' 2>/dev/null \
  && echo '--perl-regexp' || echo '--extended-regexp' \
)

##
# Grep for multiline matches.
#
makephile_grep_multiline := grep $(makephile_grep_regexp_flag) --only-matching --no-filename --null-data --text
