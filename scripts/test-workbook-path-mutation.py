#!/usr/bin/env python3

import subprocess
import sys
from pathlib import Path


root = Path(__file__).resolve().parent.parent
source_path = root / "parse.py"
original = source_path.read_text(encoding="utf-8")
target = "        except (OSError, ValueError):\n"
replacement = "        except OSError:\n"

if original.count(target) != 1:
    raise SystemExit("missing workbook path mutation target")

try:
    source_path.write_text(original.replace(target, replacement, 1), encoding="utf-8")
    result = subprocess.run(
        [
            sys.executable,
            "-m",
            "unittest",
            "tests.test_parse.ExcelProcessorTests.test_process_rejects_embedded_nul_workbook_path_before_opening_workbook",
        ],
        cwd=root,
        check=False,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )
    if result.returncode == 0:
        raise SystemExit("workbook path mutation survived\n" + result.stdout)
finally:
    source_path.write_text(original, encoding="utf-8")

print("embedded-NUL workbook path hostile mutation rejected")
