# Makephile - A library for GNU Make.
#
# This file serves to bootstrap Makephile.
#
# Makephile is a library for GNU Make that provides a set of functions and
# variables to help you write better Makefiles.
#
# For more information, see https://makephile.empaphy.org

MAKEPHILE_VERSION        = 0.1.0
MAKEPHILE_INCLUDE        = 1
MAKEPHILE_LOCAL_INCLUDES = $(addprefix $(MAKEPHILE_LOCAL_DIR)/,aws.mk dotenv.mk usage.mk)

##
# Gives some basic info about Makephile.
#
# @internal
#
.PHONY: makephile_about
makephile_about: mphl_about

.PHONY: mphl_about
mphl_about:
	@echo 'Makephile v$(MAKEPHILE_VERSION) - A library for GNU Make.'
	@echo 'For more information, see https://makephile.empaphy.org'

##
# Ensure .makephile is present for the other include files.
#
# @internal
#
$(MAKEPHILE_LOCAL_INCLUDES): $(MAKEPHILE_LOCAL_DIR)
	@$(info Downloading included file: $@)
	@$(call _mphl_download_include_file,$@)

##
# Removes any locally installed Makephile files.
#
mphl_clean:
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
# Information about the current target.
#
mphl_target_info = $(eval $(info $(MPHL_EOL)$(_mphl_bold)> Target $@$(_mphl_sgr)))
makephile_target_info = $(mphl_target_info)

########################################
# Make the target with a timeout, by providing a timeout target.
# Parameters:
#   The target to make.
#   The number of hours after which the target should be considered old.
#   The timeout file to create. Use this as dependency for your target.
########################################
define mphl_MAKE_with_timeout_hours
touch -A '-$(2)0000' '$(3)' > /dev/null 2>&1 || touch -d '$(2) hours ago' '$(3)' > /dev/null 2>&1; \
${MAKE} $(1)
endef
makephile_MAKE_with_timeout_hours = $(mphl_MAKE_with_timeout_hours)

########################################
# Escape a string for use in a regular expression.
# Parameters:
#   The string to escape.
########################################
mphl_regex_escape_value = $(shell echo "$(1)" | sed 's/[]\/$$*.^[]/\\&/g' || exit 1)
makephile_regex_escape_value = $(mphl_regex_escape_value)

##
# Contains the appropriate `-i` option usage for `sed`, depending on what is available.
#
mphl_sed_in_place_option = $(shell sed --version >/dev/null 2>&1 && echo '-i ""' || echo '-i')
makephile_sed_in_place_option = $(mphl_sed_in_place_option)

##
# `sed` command with the appropriate `-i` option for in-place editing.
#
# Usage of the `-i` operate on FreeBSD and GNU sed differs, so we need to check which one applies.
#
mphl_sed_in_place = sed $(makephile_sed_in_place_option)
makephile_sed_in_place = $(mphl_sed_in_place)

########################################
# Returns a substring of the provided string.
# Parameters:
#   The string to get the substring from.
#   The start index. (NOTE: Negative values are _NOT_ allowed.)
#   The end index.   (NOTE: Negative values are _NOT_ allowed.)
########################################
mphl_substr = $(shell echo "$(1)" | cut -c$(2)-$(3))
makephile_substr = $(mphl_substr)

########################################
# Create file with unique file name.
#
# Creates a file with a unique filename, in the specified directory. If the
# directory does not exist or is not writable, `$(call mphl_tempnam)` may
# generate a file in the system's temporary directory, and return the full path
# to that file, including its name.
#
# Parameters:
#   The directory where the temporary filename will be created.
#   The prefix of the generated temporary filename.
# Returns:
#   The new temporary filename (with path).
########################################
mphl_tempnam = $(shell TMPDIR='$(1)' mktemp -t '$(2)XXXXXX')

##
# Creates a temporary file with a unique name.
#
mphl_tmpfile = $(shell mktemp -t makephileXXXXXX)

########################################
# Returns a unique temporary file path.
# Parameters:
#   The file name to use.
########################################
makephile_get_temp_file = $(call mphl_tempnam,$(TMPDIR),$(1))

########################################
# Sets the value of an environment variable.
# Parameters:
#   The setting, like "FOO=BAR".
########################################
define mphl_putenv
$(eval export $(1))
endef

########################################
# Exports the provided environment variables.
# Parameters:
#   The environment variable to export.
########################################
makephile_export_var = $(mphl_putenv)

########################################
# Wrapper for the `tput` command.
# Parameters:
#   tput arguments
########################################
_mphl_tput = $(shell [ -n "$$TERM" ] && [ "$$TERM" != "dumb" ] && tput $(1) || echo -n '')

##
# Output bold text.
#
_mphl_bold := $(call _mphl_tput,bold)

##
# Reset the text style.
#
_mphl_sgr  := $(call _mphl_tput,sgr0)

##
# Used to create a newline.
#
_mphl_eol :=
define MPHL_EOL

$(_mphl_eol)
endef

##
# Contains the best possible regular expression flag for grep, depending on what is available.
#
# So, either `--perl-regexp` or `--extended-regexp`.
#
mphl_grep_regexp_flag := $(shell \
  echo | grep --perl-regexp --only-matching --quiet '^$$' 2>/dev/null \
  && echo '--perl-regexp' || echo '--extended-regexp' \
)
makephile_grep_regexp_flag := $(mphl_grep_regexp_flag)

##
# Grep for multiline matches.
#
mphl_grep_multiline := grep $(mphl_grep_regexp_flag) --only-matching --no-filename --null-data --text
makephile_grep_multiline := $(mphl_grep_multiline)
