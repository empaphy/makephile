MAKEPHILE_BASE_URL ?= https://raw.githubusercontent.com/empaphy/makephile/$(MAKEPHILE_VERSION)
MAKEPHILE_HOME     ?= .makephile
MAKEPHILE_LIB       = $(MAKEPHILE_HOME)/$(MAKEPHILE_LIB_PATH)
MAKEPHILE_LIB_PATH  = lib
MAKEPHILE_VERSION  ?= main

$(MAKEPHILE_LIB)/%:
	@echo $$'\n> Downloading $(MAKEPHILE_BASE_URL)/$(MAKEPHILE_LIB_PATH)/$(notdir $@) to $@.'
	@curl --fail --silent --create-dirs --show-error --output '$@' '$(MAKEPHILE_BASE_URL)/$(MAKEPHILE_LIB_PATH)/$(notdir $@)'

include $(MAKEPHILE_LIB)/core.mk
