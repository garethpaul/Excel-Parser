import os
import tempfile
import unittest

import xlrd
import xlwt

import parse


class RealXlsIntegrationTests(unittest.TestCase):
    def test_process_reads_synthetic_xls_with_real_xlrd(self):
        self.assertIs(parse.xlrd, xlrd)
        events = []

        with tempfile.TemporaryDirectory() as temporary_directory:
            workbook_path = os.path.join(temporary_directory, "people.xls")
            workbook = xlwt.Workbook()
            sheet = workbook.add_sheet("People")

            for column, value in enumerate(("Name", "Count", "Ratio", "Note")):
                sheet.write(0, column, value)
            for column, value in enumerate((" Alice ", 7, 3.5)):
                sheet.write(1, column, value)
            for column, value in enumerate((" Bob ", "8", "4.25", " ready ")):
                sheet.write(2, column, value)
            workbook.save(workbook_path)

            processor = parse.ExcelProcessor(
                lambda rowid, values: events.append(("row", rowid, values)),
                lambda: events.append(("done",)),
                lambda rowid, exc: self.fail("unexpected row error at %s: %s" % (rowid, exc)),
            )
            processor.process(
                workbook_path,
                "People",
                True,
                [
                    parse.ExcelProcessor.CELL_TEXT,
                    parse.ExcelProcessor.CELL_INT,
                    parse.ExcelProcessor.CELL_FLOAT,
                    parse.ExcelProcessor.CELL_TEXT,
                ],
            )

        self.assertEqual(
            [
                ("row", 1, ["Alice", 7, 3.5, None]),
                ("row", 2, ["Bob", 8, 4.25, "ready"]),
                ("done",),
            ],
            events,
        )


if __name__ == "__main__":
    unittest.main()
