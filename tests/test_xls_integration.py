import datetime
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

    def test_process_rejects_formula_without_cached_number_and_date_cells(self):
        events = []

        with tempfile.TemporaryDirectory() as temporary_directory:
            workbook_path = os.path.join(temporary_directory, "hostile.xls")
            workbook = xlwt.Workbook()
            sheet = workbook.add_sheet("Values")
            sheet.write(0, 0, xlwt.Formula("1+1"))
            date_style = xlwt.easyxf(num_format_str="YYYY-MM-DD")
            sheet.write(1, 0, datetime.datetime(2026, 1, 2), date_style)
            workbook.save(workbook_path)

            processor = parse.ExcelProcessor(
                lambda rowid, values: events.append(("row", rowid, values)),
                lambda: events.append(("done",)),
                lambda rowid, exc: events.append(("error", rowid, type(exc), str(exc))),
            )
            processor.process(
                workbook_path,
                "Values",
                False,
                [parse.ExcelProcessor.CELL_FLOAT],
            )

        self.assertEqual("error", events[0][0])
        self.assertEqual(0, events[0][1])
        self.assertIs(parse.InvalidDataException, events[0][2])
        self.assertIn("Empty text value", events[0][3])
        self.assertEqual("error", events[1][0])
        self.assertEqual(1, events[1][1])
        self.assertIs(parse.InvalidDataException, events[1][2])
        self.assertIn("Conversion from Date Type not supported", events[1][3])
        self.assertEqual(("done",), events[2])


if __name__ == "__main__":
    unittest.main()
