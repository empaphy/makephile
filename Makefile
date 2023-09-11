include inc/makephile.mk
include inc/usage.mk

.SHELLFLAGS := -ce
SHELL       := bash

.PHONY: $(MAKEPHILE_VERSION).sha256
$(MAKEPHILE_VERSION).sha256:
	$(mphl_target_info)
	@sha256sum inc/*.mk inc/aws/*.mk > $@
	@sha256sum $@ > $@.sha256sum

.PHONY: build
build:
	$(mphl_target_info)
	@docker compose build

.PHONY: tests
tests:
	$(mphl_target_info)
	@docker compose run makephile --directory tests tests
