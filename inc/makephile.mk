# Makephile - A library for GNU Make.
#
# This file serves to bootstrap Makephile.
#
# Makephile is a library for GNU Make that provides a set of functions and
# variables to help you write better Makefiles.
#
# For more information, see https://makephile.empaphy.org

MAKEPHILE             = 1
MAKEPHILE_VERSION    ?= dev
MAKEPHILE_HOME       ?= .makephile/$(MAKEPHILE_VERSION)
MAKEPHILE_HOST       ?= makephile.empaphy.org
MAKEPHILE_INC_DIR     = inc
MAKEPHILE_INCLUDE    ?= $(MAKEPHILE_HOME)/$(MAKEPHILE_INC_DIR)
MAKEPHILE_INCLUDES    = $(addprefix $(MAKEPHILE_HOME)/,$(MAKEPHILE_INCLUDE_FILES))
MAKEPHILE_SHA256SUMS ?= SHA256SUMS

define MAKEPHILE_INCLUDE_FILES
inc/aws.mk \
inc/dotenv.mk \
inc/usage.mk
endef

##
# Gives some basic info about Makephile.
#
# @internal
#
.PHONY: makephile_about
makephile_about:
	@echo 'Makephile - A library for GNU Make.'
	@echo 'For more information, see https://$(MAKEPHILE_HOST)'

##
# Removes any locally installed Makephile files.
#
.PHONY: makephile_clean
makephile_clean:
	@rm -rf $(MAKEPHILE_INCLUDES) .makephile.mk

##
# Download Empaphy include file
#
# @internal
#
$(MAKEPHILE_INCLUDES): $(MAKEPHILE_INCLUDE)
	@$(call mphl_download_file,$(MAKEPHILE_HOST),$(call _mphl_makephile_download_path,$@),$@)
	@cd '$(MAKEPHILE_HOME)' && sha256sum --check --ignore-missing --quiet $(MAKEPHILE_INCLUDE_FILES)

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

########################################
# Escape a string for use in a regular expression.
# Parameters:
#   The string to escape.
########################################
mphl_regex_escape_value = $(shell echo "$(1)" | sed 's/[]\/$$*.^[]/\\&/g' || exit 1)

##
# Contains the appropriate `-i` option usage for `sed`, depending on what is available.
#
mphl_sed_in_place_option = $(shell sed --version >/dev/null 2>&1 && echo '-i ""' || echo '-i')

##
# `sed` command with the appropriate `-i` option for in-place editing.
#
# Usage of the `-i` operate on FreeBSD and GNU sed differs, so we need to check which one applies.
#
mphl_sed_in_place = sed $(makephile_sed_in_place_option)

########################################
# Returns a substring of the provided string.
# Parameters:
#   The string to get the substring from.
#   The start index. (NOTE: Negative values are _NOT_ allowed.)
#   The end index.   (NOTE: Negative values are _NOT_ allowed.)
########################################
mphl_substr = $(shell echo "$(1)" | cut -c$(2)-$(3))

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
mphl_get_temp_file = $(call mphl_tempnam,$(TMPDIR),$(1))

########################################
# Sets the value of an environment variable.
# Parameters:
#   The setting, like "FOO=BAR".
########################################
define mphl_putenv
$(eval export $(1))
endef

########################################
# Download file using bash.
# Parameters:
#   Host to download file from.
#   Path to file on host.
#   Target filename.
########################################
define mphl_download_file
set -e;                                                                        \
                                                                               \
function mphl_download_file() {                                               \
  local host="$$1";                                                            \
  local path="$$2";                                                            \
  local file="$$3";                                                            \
  																			   \
  echo $$'\n> Downloading' "http://$${host}$${path} to $${file}.";             \
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
mphl_download_file '$(1)' '$(2)' '$(3)'
endef

define mphl_explode
endef

########################################
# Send an error message to STDERR.
# Parameters:
#   The error message that should be logged.
########################################
define mphl_error_log
function mphl_error_log() {                                                    \
  local message='$(1)'; \
   \
  local lines; IFS=$$'\n' read -rd '' -a lines <<<"$$message"; \
  for line in $${lines[@]}; do \
    fmt -w 78  |  -t messages; \
	echo '> ' "$$line" >&2; \
  done; \
}; \
mphl_error_log '$(1)'
endef

########################################
# Returns the download url for the given Makephile file.
# TODO: add versioning
# Parameters:
#   File that you require.
########################################
define _mphl_makephile_download_url
http://$(MAKEPHILE_HOST)$(call _mphl_makephile_download_path,$(1))
endef

########################################
# Returns the download path for the given Makephile file.
# Parameters:
#   File that you require.
########################################
define _mphl_makephile_download_path
/$(subst $(MAKEPHILE_HOME)/,$(MAKEPHILE_VERSION)/,$(1))
endef

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

##
# Grep for multiline matches.
#
mphl_grep_multiline := grep $(mphl_grep_regexp_flag) --only-matching --no-filename --null-data --text
