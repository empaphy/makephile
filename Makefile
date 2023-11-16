include lib/core.mk
include lib/usage.mk

.DEFAULT_GOAL := bundle
.SHELLFLAGS   := -ce
SHELL         := bash

##
# Files that should be included in the distribution bundle.
#
BUNDLE_FILES = bootstrap.mk

##
# Dir where distribution bundles are created in.
#
DIST_DIR = _site

##
# Dir where the distribution bundle is created in.
#
DIST_VERSION_DIR = $(DIST_DIR)/$(MAKEPHILE_VERSION)

##
# Build the Docker image.
#
.PHONY: build
build:
	$(phil_target_info)
	@docker compose build

##
# Run tests.
#
.PHONY: tests
tests:
	$(phil_target_info)
	@docker compose run makephile --directory tests tests

##
# Builds a distribution bundle.
#
.PHONY: bundle
bundle: $(DIST_DIR)
	$(phil_target_info)
	@cp -v -a bootstrap.mk makephile.mk m include $(DIST_DIR)/
	$(info Done.)

.PHONY: clean
clean:
	$(phil_target_info)
	@if [ -e $(DIST_DIR) ]; then \
  	  echo -n "Removing distribution bundle '$(DIST_DIR)'..."; \
	  rm -r $(DIST_DIR); \
	  echo " Done."; \
	fi

help: makephile_usage

$(DIST_DIR):
	$(phil_target_info)
	@mkdir -p $@
