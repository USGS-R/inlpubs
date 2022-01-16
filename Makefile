# Prepare Package for Release
#
# System requirements:
#   R-package dependencies
#   pandoc - https://pandoc.org/
#   phantomjs - https://phantomjs.org/ see webshot::install_phantomjs()
#   optipng - http://optipng.sourceforge.net/
#   Amazon Corretto - https://aws.amazon.com/corretto/
#
# Online resources:
#   link checker - https://validator.w3.org/checklink
#   unicode character detector - https://www.textmagic.com/free-tools/unicode-detector
#   convert image to text - https://smallseotools.com/image-to-text-converter/

SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

PKGNAME := $(shell sed -n "s/Package: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGVERS := $(shell sed -n "s/Version: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGSRC  := $(shell basename `pwd`)

all: docs install bib check clean
.PHONY: all

docs:
	R -q -e 'pkgload::load_all()'
	R -q -e 'roxygen2::roxygenize()'
	R -q -e 'pkgbuild::clean_dll()'
.PHONY: docs

build:
	cd ..
	R CMD build $(PKGSRC)
.PHONY: build

install: build
	cd ..
	R CMD INSTALL --build $(PKGNAME)_$(PKGVERS).tar.gz
.PHONY: install

check:
	cd ..
	R CMD check --no-build-vignettes $(PKGNAME)_$(PKGVERS).tar.gz
.PHONY: check

check-cran:
	cd ..
	R CMD check --no-build-vignettes --as-cran $(PKGNAME)_$(PKGVERS).tar.gz
.PHONY: check-cran

datasets:
	Rscript data-raw/make-datasets.R
.PHONY: datasets

bib:
	cd inst
	R -q -e 'writeLines(utils::toBibtex(inlpubs::pubs[, '\''citation'\'']), '\''REFERENCES.bib'\'')'
.PHONY: bib

vignettes: docs
	R -q -e 'inlmisc::BuildVignettes(clean = TRUE, quiet = FALSE)'
.PHONY: vignettes

readme:
	R -q -e 'rmarkdown::render('\''README.Rmd'\'')'
.PHONY: readme

website:
	R -q -e 'pkgdown::build_site()'
.PHONY: website

website-github:
	R -q -e 'usethis::use_pkgdown_github_pages()'
.PHONY: website

clean:
	cd ..
	rm -f -r $(PKGNAME).Rcheck/
	rm -f sysdata.rda
	rm -f -r figures
.PHONY: clean
