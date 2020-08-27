include node_modules/makefiles/makefiles.mk

BABEL := node_modules/.bin/babel
BABEL_NODE := node_modules/.bin/babel-node
TSC := node_modules/.bin/tsc
COLLECT_COVERAGE_FROM := ["src/**/*.{js,jsx,ts,tsx}"]

BUILD_DEPS := $(DONE)/build $(patsubst src/%.ts,lib/%.d.ts,$(shell find src -name '*.ts')) \
	$(patsubst src/%.tsx,lib/%.d.ts,$(shell find src -name '*.tsx'))

.PHONY: all
all: build

.PHONY: install
install: node_modules
node_modules: package.json
	@$(NPM) install

.PHONY: prepare
prepare:
	@

.PHONY: format
format: install
	@$(MAKE) -s +format
+format:
	-@git ls-files | grep -E "((js)|(ts)x?)$$" | xargs eslint --fix $(NOFAIL)
	@git ls-files | grep -E "((json)|(ya?ml)|(md)|((js)|(ts)x?))$$" | xargs prettier --write
	@mkdir -p node_modules/.make && touch -m node_modules/.make/format
node_modules/.make/format: $(shell git ls-files | grep "\.(j|t)sx?$$")
	@$(MAKE) -s format

.PHONY: spellcheck
spellcheck: node_modules/.make/format
	@$(MAKE) -s +spellcheck
+spellcheck:
	-@cspell --config .cspellrc src/**/*.ts
	@mkdir -p node_modules/.make && touch -m node_modules/.make/spellcheck
node_modules/.make/spellcheck: $(shell git ls-files | grep "\.(j|t)sx?$$")
	-@$(MAKE) -s spellcheck

.PHONY: lint
lint: node_modules/.make/spellcheck
	@$(MAKE) -s +lint
+lint:
	# @lockfile-lint --type npm --path package-lock.json --validate-https
	-@tsc --allowJs --noEmit
	-@git ls-files | grep -E "((js)|(ts)x?)$$" | xargs eslint -f json -o node_modules/.tmp/eslintReport.json $(NOFAIL)
	@eslint --ext .js,.jsx,.ts,.tsx .
node_modules/.tmp/eslintReport.json: $(shell git ls-files | grep "\.(j|t)sx?$$")
	-@$(MAKE) -s lint

.PHONY: test
test: node_modules/.tmp/eslintReport.json
	@$(MAKE) -s +test
+test:
	@jest --json --outputFile=node_modules/.tmp/jestTestResults.json --coverage --coverageDirectory=node_modules/.tmp/coverage --testResultsProcessor=jest-sonar-reporter --collectCoverageFrom='$(COLLECT_COVERAGE_FROM)' $(ARGS)
node_modules/.tmp/coverage/lcov.info: $(shell git ls-files | grep "\.(j|t)sx?$$")
	-@$(MAKE) -s test

.PHONY: coverage
coverage: node_modules/.tmp/eslintReport.json
	@$(MAKE) -s +coverage
+coverage:
	@jest --coverage --collectCoverageFrom='$(COLLECT_COVERAGE_FROM)' $(ARGS)

.PHONY: test-ui
test-ui: node_modules/.tmp/eslintReport.json node_modules
	@$(MAKE) -s +test-ui
+test-ui:
	@majestic $(ARGS)

.PHONY: test-watch
test-watch: node_modules/.tmp/eslintReport.json node_modules
	@$(MAKE) -s +test-watch
+test-watch:
	@jest --watch $(ARGS)

.PHONY: build +build
build:
	@$(MAKE) -s +build
+build: $(BUILD_DEPS)
$(DONE)/build:
	-@rm -r lib node_modules/.tmp/lib $(NOFAIL)
	@$(BABEL) src -d lib --extensions '.ts,.tsx' --source-maps
	@$(TSC) -d --emitDeclarationOnly
	@cp -r node_modules/.tmp/lib/src/. lib
	@$(call done,build)
lib/%.d.ts: src/%.ts*
	@$(BABEL) $< -d lib --extensions '.ts,.tsx' --source-maps
	@$(TSC) -out $@ -d --emitDeclarationOnly $<

.PHONY: start +start
start:
	@$(MAKE) -s +start
+start:
	@babel-node --extensions '.ts,.tsx' src $(ARGS)

.PHONY: clean
clean:
	-@jest --clearCache
ifeq ($(PLATFORM), win32)
	@git clean -fXd -e !/node_modules -e !/node_modules/**/* -e !/yarn.lock -e !/pnpm-lock.yaml -e !/package-lock.json
else
	@git clean -fXd -e \!/node_modules -e \!/node_modules/**/* -e \!/yarn.lock -e \!/pnpm-lock.yaml -e \!/package-lock.json
endif
	-@$(RM) -rf node_modules/.cache
	-@$(RM) -rf node_modules/.make
	-@$(RM) -rf node_modules/.tmp

.PHONY: purge
purge: clean
	@git clean -fXd

.PHONY: report
report: spellcheck lint test
	@

%:
	@
