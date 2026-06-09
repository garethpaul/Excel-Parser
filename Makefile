.PHONY: build check lint test

lint:
	@scripts/check-baseline.sh

test:
	@python3 -m unittest discover -s tests -p "test*.py"

build:
	@python3 -m py_compile parse.py tests/test_parse.py

check: lint test build
