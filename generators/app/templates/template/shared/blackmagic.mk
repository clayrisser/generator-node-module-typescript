# just a bit of black magic
#
# the magic of this makefile consists of functions and macros
# used to create complex cached dependency chains that track
# changes on individual files and works across unix environments
#
# for example, this can be used to format the code and run tests
# against only the files that updated
#
# this significantly increases the speed of builds and development in a
# language and ecosystem agnostic way without sacrificing enforcement of
# critical scripts and jobs
#
# an explanation of how this works is beyond the scope of this header
#
# - Clay Risser

PLATFORM := $(shell node -e "process.stdout.write(process.platform)")

ifeq ($(PLATFORM), win32)
  BANG := !
	MAKE := make
	NULL := nul
	SHELL := cmd.exe
else
	BANG := \!
	NULL := /dev/null
	SHELL := $(shell bash --version >$(NULL) 2>&1 && echo bash|| echo sh)
ifeq ($(PLATFORM), linux)
	TMP_RAM ?= /dev/shm
endif
endif

CWD ?= $(shell pwd)
CD ?= cd
GIT ?= $(shell git --version >$(NULL) 2>&1 && echo git|| echo true)
NPM ?= $(shell pnpm --version >$(NULL) 2>&1 && echo pnpm|| (yarn --version >$(NULL) 2>&1 && echo yarn|| echo npm))
NOFAIL := 2>$(NULL)|| true

DEPSLIST ?= node_modules/.bin/depslist

.EXPORT_ALL_VARIABLES:

PROJECT_ROOT ?= $(shell $(GIT) rev-parse --show-superproject-working-tree)
ifeq ($(PROJECT_ROOT),)
	PROJECT_ROOT := $(shell $(GIT) rev-parse --show-toplevel)
endif
ifeq ($(PROJECT_ROOT),)
	PROJECT_ROOT := $(CWD)
endif

MAKE_CACHE ?= node_modules/.make
_ACTIONS := $(MAKE_CACHE)/actions
DONE := $(MAKE_CACHE)/done
DEPS := $(MAKE_CACHE)/deps
ACTION := $(DONE)

ifneq ($(TMP_RAM),)
ifeq ($(wildcard $(PROJECT_ROOT)/$(MAKE_CACHE)),)
_RUN := $(shell mkdir -p $(MAKE_CACHE) && rm -rf $(MAKE_CACHE) && \
	mkdir -p $(TMP_RAM)$(PROJECT_ROOT)/$(MAKE_CACHE) && \
	ln -s $(TMP_RAM)$(PROJECT_ROOT)/$(MAKE_CACHE) $(PROJECT_ROOT)/$(MAKE_CACHE))
endif
endif
_RUN := $(shell mkdir -p $(_ACTIONS) $(DEPS) $(DONE))

define done
	@$(call reset_deps,$1)
	mkdir -p $(DONE) && touch -m $(DONE)/$1
endef

define add_dep
	mkdir -p $(MAKE_CACHE)/deps && echo $2 >> $(MAKE_CACHE)/deps/$1
endef

define reset_deps
	rm $(MAKE_CACHE)/deps/$1 $(NOFAIL)
endef

define get_deps
	cat $(MAKE_CACHE)/deps/$1 $(NOFAIL)
endef

define cache
	mkdir -p $$(echo $1 | sed 's/\/[^\/]*$$//g') && touch -m $1
endef

ifneq ($(TMP_RAM),)
define clean
	rm -rf $(TMP_RAM)$(PROJECT_ROOT)/$(MAKE_CACHE) $(NOFAIL)
endef
else
define clean
endef
endif

define ACTION_TEMPLATE
ifneq ($$({{ACTION_UPPER}}_READY),true)
{{ACTION_UPPER}}_READY := true
.PHONY: {{ACTION}} +{{ACTION}} _{{ACTION}} ~{{ACTION}}
{{ACTION}}: _{{ACTION}} ~{{ACTION}}
~{{ACTION}}: {{ACTION_DEPENDENCY}} $$({{ACTION_UPPER}}_TARGET)
+{{ACTION}}: _{{ACTION}} $$({{ACTION_UPPER}}_TARGET)
_{{ACTION}}:
	-@rm -rf $(DONE)/_{{ACTION}} $(NOFAIL)
$(DONE)/_{{ACTION}}/%: %
	-@rm $(DONE)/{{ACTION}} $(NOFAIL)
	@$$(call add_dep,{{ACTION}},$$<)
	@$$(call cache,$$@)
endif
endef

$(_ACTIONS)/%:
	@ACTION_BLOCK=$(shell echo $@ | grep -oE '[^\/]+$$') && \
		ACTION=$$(echo $$ACTION_BLOCK | grep -oE '^[^~]+') && \
		ACTION_DEPENDENCY=$$(echo $$ACTION_BLOCK | grep -oE '~[^~]+$$' $(NOFAIL)) && \
		ACTION_UPPER=$$(echo $$ACTION | tr '[:lower:]' '[:upper:]') && \
		echo "$${ACTION_TEMPLATE}" | sed "s/{{ACTION}}/$${ACTION}/g" | \
		sed "s/{{ACTION_DEPENDENCY}}/$${ACTION_DEPENDENCY}/g" | \
		sed "s/{{ACTION_UPPER}}/$${ACTION_UPPER}/g" > $@