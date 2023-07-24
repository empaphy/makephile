####
## Makephile v0.1.0 - A library for GNU Make.
##
## Makephile is a library for GNU Make that provides a set of functions and
## variables to help you write better Makefiles.
##
## For more information, see https://makephile.empaphy.org
##

MAKEPHILE_LOCAL_DIR      := .makephile
MAKEPHILE_LOCAL_INCLUDES := $(addprefix $(MAKEPHILE_LOCAL_DIR)/,about.mk usage.mk aws.mk)
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

##
# Grep for multiline matches.
#
makephile_grep_multiline := grep $(makephile_grep_regexp_flag) --only-matching --no-filename --null-data --text

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
# `sed` command with the appropriate `-i` option for in-place editing.
#
# Usage of the `-i` operate on FreeBSD and GNU sed differs, so we need to check which one applies.
#
makephile_sed_in_place = sed $(makephile_sed_in_place_option)

##
# Contains the appropriate `-i` option usage for `sed`, depending on what is available.
#
makephile_sed_in_place_option = $(shell sed --version >/dev/null 2>&1 && echo '-i ""' || echo '-i')

##
# Provides a unique temporary directory.
#
makephile_temp_dir = $(shell mktemp -d -t makephile)

##
# Ensure .makephile is present for the other include files.
#
# @internal
#
$(MAKEPHILE_LOCAL_INCLUDES): $(MAKEPHILE_LOCAL_DIR)

##
# Creates a local `.makephile` directory.
#
# @internal
#
$(MAKEPHILE_LOCAL_DIR):
	@git clone https://github.com/empaphy/makephile.git -- $@

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
# Exports the provided environment variables.
#
# @internal
# @param The environment variable to export.
#
define philmk_export_var
$(eval export $(1))
endef