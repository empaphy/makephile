########################################
# DotENV functions for Makephile.
########################################

update_env_file     = @$(sed_in_place) -e "s/^[[:space:]\#]*$(1)=.*/$(1)=$(call escape_regex_value,$(2))/g" .env
escape_regex_value  = $(shell echo "$(1)" | sed 's/[]\/$$*.^[]/\\&/g' || exit 1)
