# \ <section:var>
MODULE       = metaL
#              $(notdir $(CURDIR))
OS           = $(shell uname -s)
MACHINE      = $(shell uname -m)
NOW          = $(shell date +%d%m%y)
REL          = $(shell git rev-parse --short=4 HEAD)
# / <section:var>
# \ <section:dir>
CWD          = $(CURDIR)
DOC          = $(CWD)/doc
BIN          = $(CWD)/bin
SRC          = $(CWD)/src
TMP          = $(CWD)/tmp
# / <section:dir>
# \ <section:tool>
WGET         = wget -c
CURL         = curl
PY           = $(BIN)/python3
PIP          = $(BIN)/pip3
PEP          = $(BIN)/autopep8
PYT          = $(BIN)/pytest
# / <section:tool>
# \ <section:src>
M += $(MODULE).py test_$(MODULE).py
S += $(M) $(T) $(P)
# / <section:src>
# \ <section:all>
.PHONY: all web
all web: $(PY) $(MODULE).py
	$^ $@

.PHONY: pep
pep: $(PEP)
$(PEP): $(S)
	$(PEP) --ignore=E26,E302,E401,E402 --in-place $? && touch $@

.PHONY: test
test: $(PYT) test_$(MODULE).py
	$^ $@
# / <section:all>
# \ <section:install>
.PHONY: install
install: $(OS)_install js
	$(MAKE) $(PIP)
	$(MAKE) update
.PHONY: update
update: $(OS)_update
	$(PIP)  install -U pip autopep8
	$(PIP)  install -U -r requirements.txt
.PHONY: Linux_install Linux_update
Linux_install Linux_update:
	sudo apt update
	sudo apt install -u `cat apt.txt`
# \ <section:install/py>
$(PY) $(PIP):
	python3 -m venv .
	$(MAKE) update
$(PYT):
	$(PIP) install pytest
# / <section:install/py>
# / <section:install>
# \ <section:merge>
MERGE  = Makefile README.md .vscode $(S)
MERGE += apt.txt requirements.txt
MERGE += static templates
.PHONY: main
main:
	git push -v
	git checkout $@
	git pull -v
	git checkout shadow -- $(MERGE)
.PHONY: shadow
shadow:
	git push -v
	git checkout $@
	git pull -v
.PHONY: release
release:
	git tag $(NOW)-$(REL)
	git push -v && git push -v --tags
.PHONY: zip
zip:
	git archive \
		--format zip \
		--output $(TMP)/$(MODULE)_$(NOW)_$(REL).src.zip \
	HEAD
# / <section:merge>
