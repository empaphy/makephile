include inc/makephile.mk
include inc/usage.mk

.DEFAULT_GOAL := bundle
.SHELLFLAGS := -ce
SHELL       := bash

##
# Files that should be included in the distribution bundle.
#
BUNDLE_FILES = $(MAKEPHILE_INCLUDE_FILES) inc/makephile.mk bootstrap.mk

##
# Dir where distribution bundles are created in.
#
DIST_DIR = _site

##
# Target files in the distribution bundle.
#
DIST_FILES = $(addprefix $(DIST_VERSION_DIR)/,$(BUNDLE_FILES))

##
# Dir where the distribution bundle is created in.
#
DIST_VERSION_DIR = $(DIST_DIR)/$(MAKEPHILE_VERSION)

##
# Name of the file that contains SHA-256 checksums of the distributed files.
#
SHA256SUMS_FILE = $(DIST_VERSION_DIR)/SHA256SUMS

##
# Name of the file that contains the SHA-256 checksum for the file that contains
# the SHA-256 checksums of the distributed files.
#
SHA256SUMS_SHA256SUM_SUFFIX = .sha256sum

##
# Creates the file that contains SHA-256 checksums of the distributed files.
#
$(SHA256SUMS_FILE) $(SHA256SUMS_FILE)$(SHA256SUMS_SHA256SUM_SUFFIX): $(DIST_VERSION_DIR)
	$(mphl_target_info)
	cd $(dir $@) && sha256sum $(BUNDLE_FILES) > $(notdir $@)
	cd $(dir $@) && sha256sum $(notdir $@) > $(notdir $@)$(SHA256SUMS_SHA256SUM_SUFFIX)

##
# Build the Docker image.
#
.PHONY: build
build:
	$(mphl_target_info)
	@docker compose build

##
# Run tests.
#
.PHONY: tests
tests:
	$(mphl_target_info)
	@docker compose run makephile --directory tests tests

##
# Builds a distribution bundle.
#
.PHONY: bundle
bundle: $(DIST_FILES) $(SHA256SUMS_FILE)
	$(mphl_target_info)
	@cp -v -a makephile.mk m include $(DIST_DIR)/
	$(info Done.)

.PHONY: clean
clean:
	$(mphl_target_info)
	@if [ -e $(DIST_VERSION_DIR) ]; then \
  	  echo -n "Removing distribution bundle '$(DIST_VERSION_DIR)'..."; \
	  rm -r $(DIST_VERSION_DIR); \
	  echo " Done."; \
	fi

help: makephile_usage

$(DIST_FILES): $(DIST_VERSION_DIR)
	@mkdir -p $(dir $@)
	@cp -v -a $(subst $(DIST_VERSION_DIR),.,$@) $@

$(DIST_VERSION_DIR): $(DIST_DIR)
	$(mphl_target_info)
	@mkdir -p $@

$(DIST_DIR):
	$(mphl_target_info)
	@mkdir -p $@
