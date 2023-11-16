# Makephile - A library for GNU Make.
#
# This file serves to bootstrap Makephile.
#
# Makephile is a library for GNU Make that provides a set of functions and
# variables to help you write better Makefiles.
#
# For more information, see https://makephile.empaphy.org

MAKEPHILE_BASE_URL ?= https://raw.githubusercontent.com/empaphy/makephile/$(MAKEPHILE_VERSION)
MAKEPHILE_HOME     ?= .makephile
MAKEPHILE_LIB_PATH ?= lib
MAKEPHILE_LIB       = $(MAKEPHILE_HOME)/$(MAKEPHILE_LIB_PATH)
MAKEPHILE_VERSION  ?= main

##
# Gives some basic info about Makephile.
#
# @internal
#
.PHONY: makephile_about
makephile_about:
	@echo 'Makephile - A library for GNU Make.'
	@echo 'For more information, see https://$(MAKEPHILE_HOST)'

$(MAKEPHILE_LIB)/%:
	@phil_download_file '$(MAKEPHILE_BASE_URL)/$(MAKEPHILE_LIB_PATH)/$(notdir $@)' '$@'

##
# Information about the current target.
#
phil_target_info = $(eval $(info $(PHIL_EOL)$(_phil_bold)> Target $@$(_phil_sgr)))

########################################
# Make the target with a timeout, by providing a timeout target.
# Parameters:
#   The target to make.
#   The number of hours after which the target should be considered old.
#   The timeout file to create. Use this as dependency for your target.
########################################
define phil_MAKE_with_timeout_hours
touch -A '-$(2)0000' '$(3)' > /dev/null 2>&1 || touch -d '$(2) hours ago' '$(3)' > /dev/null 2>&1; \
${MAKE} $(1)
endef

########################################
# Escape a string for use in a regular expression.
# Parameters:
#   The string to escape.
########################################
phil_regex_escape_value = $(shell echo "$(1)" | sed 's/[]\/$$*.^[]/\\&/g' || exit 1)

##
# Contains the appropriate `-i` option usage for `sed`, depending on what is available.
#
phil_sed_in_place_option = $(shell sed --version >/dev/null 2>&1 && echo '-i ""' || echo '-i')

##
# `sed` command with the appropriate `-i` option for in-place editing.
#
# Usage of the `-i` operate on FreeBSD and GNU sed differs, so we need to check which one applies.
#
phil_sed_in_place = sed $(makephile_sed_in_place_option)

########################################
# Returns a substring of the provided string.
# Parameters:
#   The string to get the substring from.
#   The start index. (NOTE: Negative values are _NOT_ allowed.)
#   The end index.   (NOTE: Negative values are _NOT_ allowed.)
########################################
phil_substr = $(shell echo "$(1)" | cut -c$(2)-$(3))

########################################
# Create file with unique file name.
#
# Creates a file with a unique filename, in the specified directory. If the
# directory does not exist or is not writable, `$(call phil_tempnam)` may
# generate a file in the system's temporary directory, and return the full path
# to that file, including its name.
#
# Parameters:
#   The directory where the temporary filename will be created.
#   The prefix of the generated temporary filename.
# Returns:
#   The new temporary filename (with path).
########################################
phil_tempnam = $(shell TMPDIR='$(1)' mktemp -t '$(2)XXXXXX')

##
# Creates a temporary file with a unique name.
#
phil_tmpfile = $(shell mktemp -t makephileXXXXXX)

########################################
# Returns a unique temporary file path.
# Parameters:
#   The file name to use.
########################################
phil_get_temp_file = $(call phil_tempnam,$(TMPDIR),$(1))

########################################
# Sets the value of an environment variable.
# Parameters:
#   The setting, like "FOO=BAR".
########################################
define phil_putenv
$(eval export $(1))
endef

########################################
# Download file using bash.
# Parameters:
#   Url to download file from.
#   Target filename.
########################################
define phil_download_file
set -e;                                                                        \
                                                                               \
function phil_download_file() {                                                \
  local url="$$1";                                                             \
  local file="$$2";                                                            \
  																			   \
  echo $$'\n> Downloading' "$${url} to $${file}.";                             \
  curl --create-dirs --fail --silent --show-error --output "$${file}" "$${url}" \
};                                                                             \
                                                                               \
phil_download_file '$(1)' '$(2)'
endef

########################################
# Send an error message to STDERR.
# Parameters:
#   The error message that should be logged.
########################################
define phil_error_log
function phil_error_log() { \
  local message='$(1)'; \
   \
  local lines; IFS=$$'\n' read -rd '' -a lines <<<"$$message"; \
  for line in $${lines[@]}; do \
    fmt -w 78  |  -t messages; \
	echo '> ' "$$line" >&2; \
  done; \
}; \
phil_error_log '$(1)'
endef

########################################
# Returns the download url for the given Makephile file.
# TODO: add versioning
# Parameters:
#   File that you require.
########################################
define _phil_makephile_download_url
$(MAKEPHILE_BASE_URL)$(call _phil_makephile_download_path,$(1))
endef

########################################
# Returns the download path for the given Makephile file.
# Parameters:
#   File that you require.
########################################
define _phil_makephile_download_path
/$(subst $(MAKEPHILE_HOME)/,/,$(1))
endef

########################################
# Wrapper for the `tput` command.
# Parameters:
#   tput arguments
########################################
_phil_tput = $(shell [ -n "$$TERM" ] && [ "$$TERM" != "dumb" ] && tput $(1) || echo -n '')

##
# Output bold text.
#
_phil_bold := $(call _phil_tput,bold)

##
# Reset the text style.
#
_phil_sgr  := $(call _phil_tput,sgr0)

##
# Used to create a newline.
#
_phil_eol :=
define PHIL_EOL

$(_phil_eol)
endef

##
# Contains the best possible regular expression flag for grep, depending on what is available.
#
# So, either `--perl-regexp` or `--extended-regexp`.
#
phil_grep_regexp_flag := $(shell \
  echo | grep --perl-regexp --only-matching --quiet '^$$' 2>/dev/null \
  && echo '--perl-regexp' || echo '--extended-regexp' \
)

##
# Grep for multiline matches.
#
phil_grep_multiline := grep $(phil_grep_regexp_flag) --only-matching --no-filename --null-data --text
