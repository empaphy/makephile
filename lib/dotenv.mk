########################################
# Update a .env file.
# Parameters:
#   The .env file that should be updated.
#   The name of the variable that should be updated.
#   The new value of the variable.
########################################
define phil_dotenv_update
$(phil_sed_in_place) -e "s/^[[:space:]\#]*$(2)=.*/$(2)=$(call phil_regex_escape_value,$(3))/g" $(1)
endef
