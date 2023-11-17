# makephile
_Love make, not jar_

---

Makephile is a library for makefiles. It provides a set of functions to make
writing makefiles easier.

## Dependencies

- GNU Make (v3 or higher)
- GNU Bash (v3 or higher)

## How to use

Add the following snippet to your Makefile, or create a separate `makephile.mk`
to import into your Makefile:

```makefile
# Makephile configuration
# For more information, see https://makephile.empaphy.org
MAKEPHILE_VERSION = 1.x

.makephile/bootstrap.mk:
	curl --create-dirs --output $@ https://makephile.empaphy.org/bootstrap.mk
include .makephile/bootstrap.mk

ifdef MAKEPHILE_LIB
include $(MAKEPHILE_LIB)/usage.mk
endif
```


## Features

This is a non-exhaustive overview of the functions currently available in
Makephile:


`$(call makephile_MAKE_with_timeout_hours,target,hours,timeout_target)`
: Makes the target with a timeout, by providing a timeout target.


`$(makephile_target_info)`
: Prints information about the current target.
  
  For example:
  
  ```makefile
  .PHONY: foo
  foo:
      $(makephile_target_info)
      @echo "Hello, world!"
  ```
  Will output:
  ```
  > Target foo
  Hello, world!
  ```
