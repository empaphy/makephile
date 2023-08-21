
include include/makephile.mk
include include/usage.mk

.SHELLFLAGS := -ce

include_SHA256SUMS = include/SHA256SUMS

SHA256SUMS:
	@sha224sum *.mk > $@

$(include_SHA256SUMS):
	$(mphl_target_info)
	@cd include && sha224sum *.mk > SHA256SUMS

.PHONY: build
build:
	$(mphl_target_info)
	@docker compose build

.PHONY: tests
tests:
	$(mphl_target_info)
	@docker compose run makephile --directory tests tests
