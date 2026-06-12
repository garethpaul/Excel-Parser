.PHONY: audit build check lint test

lint:
	@scripts/check-baseline.sh

test:
	@python3 -m unittest discover -s tests -p "test*.py"

build:
	@python3 -m py_compile parse.py tests/test_parse.py tests/test_xls_integration.py

audit:
	@python3 -m pip_audit -r requirements.txt -r requirements-dev.txt

check: lint test build audit
