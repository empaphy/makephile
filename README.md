# makephile
_Love make, not war_

---

Makephile is a library for makefiles. It provides a set of functions to make
writing makefiles easier.


## How to use

Add the following snippet to your Makefile:

```makefile
.makephile.mk:
	@m=makephile;h=$$m.empaphy.org;exec 7<>/dev/tcp/$$h/80 && printf "GET %b" \
	"/m HTTP/1.0\r\nHost: $$h\r\n\r\n">&7 && grep -Eioz "## $$m(.|\n)*"<&7 > $@
include .makephile.mk
```
