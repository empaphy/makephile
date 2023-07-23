########################################
# Makephile - A library for Make.
########################################

.SHELLFLAGS   := -ce
SHELL         := bash

~/.empaphy/makephile: | ~/.empaphy
	@git clone https://github.com/empaphy/makephile.git -- ~/.empaphy/makephile

##
# Create .makephile config dir.
#
# @internal
#
~/.empaphy:
	@mkdir ~/.empaphy

philmk_bold := $(shell [ -n "$$TERM" ] && [ "$$TERM" != "dumb" ] && tput bold || echo -n '')
philmk_sgr  := $(shell [ -n "$$TERM" ] && [ "$$TERM" != "dumb" ] && tput sgr0 || echo -n '')

philmk_target = $(eval $(info $(NEWLINE)$(philmk_bold)> Target $@$(philmk_sgr)))

# Used to create a newline.
philmk_newline :=
define NEWLINE

$(philmk_newline)
endef

define philmk_export_var
$(eval export $(1))
endef

philmk_grep_multiline   := grep $(philmk_grep_regexp_flag) --only-matching --no-filename --null-data --text
philmk_grep_regexp_flag := $(shell \
  echo | grep --perl-regexp --only-matching --quiet '^$$' 2>/dev/null \
  && echo '--perl-regexp' || echo '--extended-regexp' \
)

philmk_sed_in_place        = sed $(philmk_sed_in_place_option)
philmk_sed_in_place_option = $(shell sed --version >/dev/null 2>&1 && echo '-i ""' || echo '-i')

philmk_temp_dir = $(shell mktemp -d -t makephile)

define philmk_hours_ago
philmk_timeout_file='$(philmk_temp_dir)/timeout'; \
touch -A '-$(1)0000' "$$philmk_timeout_file" > /dev/null 2>&1 || touch -d '$(1) hours ago' "$$philmk_timeout_file" > /dev/null 2>&1; \
echo "$$philmk_timeout_file"
endef
