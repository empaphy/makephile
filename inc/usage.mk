########################################
# Usage help features for Makephile.
########################################

##
# Output usage documentation.
#
# @internal
#
.PHONY: makephile_usage
makephile_usage:
	@echo "Usage: make [target] [VARIABLE=value]"
	@echo ""
	@echo "Targets:"
	@$(mphl_usage_parse_targets)

##
# Parse the Makefile for targets and their descriptions.
#
define mphl_usage_parse_targets
$(mphl_grep_multiline) '$(mphl_usage_match_target)[a-zA-Z_-]+:.*(\n|$$)' $(MAKEFILE_LIST) \
| grep --extended-regexp --text "^[a-zA-Z_-]+:.*" \
| sort \
| while read -r line; do \
    comment="$$($(mphl_grep_multiline) '$(mphl_usage_match_target)'"$${line}" $(MAKEFILE_LIST) | tr -d '\000')"; \
    if [[ "$$comment" =~ "# @internal" ]]; then continue; fi; \
    target="$$(echo "$$comment" | sed -rn 's/^([a-zA-Z_-]+):.*/\1/p')"; \
    desc="$$(echo "$$comment" | sed -rn 's/# (.*)/\1/p')"; \
    echo "$$desc" | while IFS= read -r descline; do \
      printf "\033[36m%-30s\033[0m %s\n" "$$target" "$$descline"; target=""; \
    done; \
  done;
endef

#language=regexp
define mphl_usage_match_target
(^|\n)##\n(#.*\n)+(\.[A-Z_]+:.*\n)*
endef
