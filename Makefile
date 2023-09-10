include include/makephile.mk
include include/usage.mk

.SHELLFLAGS := -ce
SHELL       := bash

.PHONY: HEAD.sha256
HEAD.sha256:
	@sha256sum *.mk inc/*.mk inc/aws/*.mk > $@
	@sha256sum $@ > $@.sha256sum

.PHONY: build
build:
	$(mphl_target_info)
	@docker compose build

.PHONY: tests
tests:
	$(mphl_target_info)
	@docker compose run makephile --directory tests tests
