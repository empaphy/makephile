include ../makephile.mk
include ../include/term.mk
include ../include/test.mk
include ../include/usage.mk

.DEFAULT_GOAL := tests
.SHELLFLAGS   := -ce

.PHONY: clean
clean:
	rm -rf .makephile.mk .makephile

.PHONY: tests
tests: test_makephile_temp_dir

philmk_test_temp_dir := $(makephile_temp_dir)

##
# Test `$(makephile_temp_dir)`
#
.PHONY: test_makephile_temp_dir
test_makephile_temp_dir:
	@$(call makephile_test_assert_not_empty,$(philmk_test_temp_dir))
	@touch $(philmk_test_temp_dir)/grass

.PHONY: help
help: makephile_usage
