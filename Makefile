.PHONY: audit build check lint test

ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

lint:
	@"$(ROOT)/scripts/check-baseline.sh"

test:
	@cd "$(ROOT)" && python3 -m unittest discover -s tests -p "test*.py"

build:
	@python3 -m py_compile "$(ROOT)/parse.py" "$(ROOT)/tests/test_parse.py" "$(ROOT)/tests/test_xls_integration.py"

audit:
	@python3 -m pip_audit -r "$(ROOT)/requirements.txt" -r "$(ROOT)/requirements-dev.txt"

check: lint test build audit
