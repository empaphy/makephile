########################################
# DotENV functions for Makephile.
########################################

define makephile_dotenv_update_file
@$(makephile_sed_in_place) -e "s/^[[:space:]\#]*$(1)=.*/$(1)=$(call makephile_regex_escape_value,$(2))/g" .env
endef
