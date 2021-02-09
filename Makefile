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
M += $(shell find $(MODULE) -type f -regex ".+.py$$")
T += test/__init__.py test/test_$(MODULE).py
M += config.py repl.py web.py
S += $(M) $(T) $(P)
# / <section:src>
# \ <section:all>
.PHONY: all
all: $(PY) $(MODULE).py
	$^ $@

.PHONY: web
web: $(PY) web.py $(S)
	$^

.PHONY: $(PEP)
pep: $(PEP)
$(PEP): $(S)
	$(PEP) --ignore=E26,E302,E401,E402 --in-place $? && touch $@

.PHONY: test
test: $(PYT) $(T)
	$< $@

.PHONY: repl
repl: $(PY) $(M)
	$(MAKE) pep test
	$(PY) -i repl.py
	$(MAKE) $@
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
# \ <section:install/js>
.PHONY: js
js:	static/js/jquery.min.js static/js/socket.io.min.js \
	static/js/bootstrap.css static/js/bootstrap.min.js \
	static/js/html5shiv.js static/js/respond.js

JQUERY_VER = 3.5.1
JQUERY_JS  = https://code.jquery.com/jquery-$(JQUERY_VER).js
static/js/jquery.min.js:
	$(WGET) -O $@ $(JQUERY_JS)

SOCKETIO_VER = 3.1.0
static/js/socket.io.min.js: static/js/socket.io.min.js.map
	$(WGET) -O $@ https://cdnjs.cloudflare.com/ajax/libs/socket.io/$(SOCKETIO_VER)/socket.io.min.js
static/js/socket.io.min.js.map:	
	$(WGET) -O $@ https://cdnjs.cloudflare.com/ajax/libs/socket.io/$(SOCKETIO_VER)/socket.io.min.js.map

BOOTSTRAP_VER  = 4.6.0
BOOTSTRAP_DIST = https://cdn.jsdelivr.net/npm/bootstrap@$(BOOTSTRAP_VER)/dist/js
static/js/bootstrap.css:
	$(WGET) -O $@ https://bootswatch.com/4/darkly/bootstrap.css
static/js/bootstrap.min.js: static/js/bootstrap.bundle.min.js.map
	$(WGET) -O $@ $(BOOTSTRAP_DIST)/bootstrap.bundle.min.js
static/js/bootstrap.bundle.min.js.map:
	$(WGET) -O $@ $(BOOTSTRAP_DIST)/bootstrap.bundle.min.js.map

HTML5SHIV_VER = 3.7.3
HTML5SHIV_URL = https://cdnjs.cloudflare.com/ajax/libs/html5shiv/$(HTML5SHIV_VER)/html5shiv-printshiv.js
static/js/html5shiv.js:
	$(WGET) -O $@ $(HTML5SHIV_URL)

RESPOND_VER = 1.4.2
RESPOND_URL = https://cdnjs.cloudflare.com/ajax/libs/respond.js/$(RESPOND_VER)/respond.js
static/js/respond.js:
	$(WGET) -O $@ $(RESPOND_URL)

# / <section:install/js>
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
