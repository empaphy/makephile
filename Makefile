
include makephile.mk
include include/usage.mk

.SHELLFLAGS := -ce

.PHONY: build
build:
	$(makephile_target_info)
	@docker compose build

.PHONY: tests
tests:
	$(makephile_target_info)
	@docker compose run makephile --directory tests tests
