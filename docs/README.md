# makephile
_Love make, not jar_

---

Makephile is a library for makefiles. It provides a set of functions to make
writing makefiles easier.


## How to use

Add the following snippet to your Makefile:

```makefile
# This snippet bootstraps Makephile by downloading it.
.makephile.mk:
	@t=`mktemp`;h=makephile.empaphy.org;exec 7<>/dev/tcp/$$h/80;printf "GET %b"\
	"/m HTTP/1.0\r\nHost: $$h\r\n\r\n">&7;b=$$(cat<&7|tee "$$t"|grep -bEh \
	$$'^\r?$$');tail -c+$$(($${b%%:*}+3)) "$$t">$@;rm "$$t"
include .makephile.mk

# Add additional Makephile includes here, they will be downloaded automatically.
ifdef MAKEPHILE_INCLUDE
include .makephile/aws.mk
include .makephile/usage.mk
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
