####
## Makephile v0.1.0 - A library for GNU Make.
##
## Makephile is a library for GNU Make that provides a set of functions and
## variables to help you write better Makefiles.
##
## For more information, see https://makephile.empaphy.org
##

SHELL 	      := bash
.SHELLFLAGS   := -ce
.DEFAULT_GOAL := help

##
# Outputs information about the current target.
#
makephile_target_info = $(eval $(info $(NEWLINE)$(philmk_bold)> Target $@$(philmk_sgr)))

##
# Make the provided target if it is older than the provided number of hours.
#
# @param The target to make.
# @param The number of hours.
#
define makephile_MAKE_after_n_hours
if [ '$(call makephile_hours_ago,$(2))' -nt '$(1)' ]; then \
  ${MAKE} $(1); \
fi
endef

##
# Creates a temporary file that has its timestamp set to the provided number of hours ago.
#
define makephile_hours_ago
philmk_timeout_file='$(makephile_temp_dir)/timeout'; \
touch -A '-$(1)0000' "$$philmk_timeout_file" > /dev/null 2>&1 || touch -d '$(1) hours ago' "$$philmk_timeout_file" > /dev/null 2>&1; \
echo "$$philmk_timeout_file"
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
# Clones the Makephile Git repository to the ~/.empaphy directory.
#
# @internal
#
~/.empaphy/makephile: | ~/.empaphy
	@git clone https://github.com/empaphy/makephile.git -- ~/.empaphy/makephile

##
# Create ~/.empaphy config dir in the user's home directory.
#
# @internal
#
~/.empaphy:
	@mkdir ~/.empaphy

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
