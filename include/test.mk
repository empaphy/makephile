define makephile_test_assert_equals
if [ '$(1)' != '$(2)' ]; then \
  echo "Failed to assert equality: '$(1)' == $(2)"; \
  exit 1; \
fi
endef

define makephile_test_assert_not_empty
if [ -n '$(1)' ]; then :; else \
  echo "$(philmk_term_fg_red)Failed to assert that value is not empty: '$(1)'$(philmk_term_exit_attribute_mode)"; \
  exit 1; \
fi
endef
