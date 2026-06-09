import unittest

import parse


class FakeSheet(object):
    def __init__(self, rows):
        self.rows = rows
        self.nrows = len(rows)

    def cell_type(self, rowid, cellid):
        return self.rows[rowid][cellid][0]

    def cell_value(self, rowid, cellid):
        return self.rows[rowid][cellid][1]


class FakeBook(object):
    def __init__(self, sheets):
        self.sheets = sheets
        self.released = False

    def sheet_by_name(self, sheet_name):
        return self.sheets[sheet_name]

    def release_resources(self):
        self.released = True


class FakeXlrd(object):
    XL_CELL_EMPTY = 0
    XL_CELL_TEXT = 1
    XL_CELL_NUMBER = 2
    XL_CELL_DATE = 3

    def __init__(self, sheets):
        self.sheets = sheets
        self.opened = []

    def open_workbook(self, excel, on_demand=False):
        book = FakeBook(self.sheets)
        self.opened.append((excel, on_demand, book))
        return book


class ExcelProcessorTests(unittest.TestCase):
    def setUp(self):
        self.original_xlrd = parse.xlrd

    def tearDown(self):
        parse.xlrd = self.original_xlrd

    def processor(self, rows, row_callback=None, done_callback=None, exception_callback=None):
        fake_xlrd = FakeXlrd({"People": FakeSheet(rows)})
        parse.xlrd = fake_xlrd
        row_callback = row_callback or (lambda _rowid, _values: None)
        done_callback = done_callback or (lambda: None)
        return parse.ExcelProcessor(row_callback, done_callback, exception_callback), fake_xlrd

    def test_convert_type_handles_text_and_number_targets(self):
        processor, _fake_xlrd = self.processor([])

        self.assertIsNone(processor.convert_type(FakeXlrd.XL_CELL_TEXT, parse.ExcelProcessor.CELL_EMPTY, " Gareth "))
        self.assertIsNone(processor.convert_type(FakeXlrd.XL_CELL_NUMBER, parse.ExcelProcessor.CELL_EMPTY, 3.0))
        self.assertEqual("Gareth", processor.convert_type(FakeXlrd.XL_CELL_TEXT, parse.ExcelProcessor.CELL_TEXT, " Gareth "))
        self.assertEqual(7, processor.convert_type(FakeXlrd.XL_CELL_TEXT, parse.ExcelProcessor.CELL_INT, " 7 "))
        self.assertEqual(7.5, processor.convert_type(FakeXlrd.XL_CELL_TEXT, parse.ExcelProcessor.CELL_FLOAT, " 7.5 "))
        self.assertEqual("3.0", processor.convert_type(FakeXlrd.XL_CELL_NUMBER, parse.ExcelProcessor.CELL_TEXT, 3.0))
        self.assertEqual(3, processor.convert_type(FakeXlrd.XL_CELL_NUMBER, parse.ExcelProcessor.CELL_INT, 3.0))
        self.assertEqual(3.9, processor.convert_type(FakeXlrd.XL_CELL_NUMBER, parse.ExcelProcessor.CELL_FLOAT, 3.9))

    def test_number_to_int_rejects_fractional_values(self):
        processor, _fake_xlrd = self.processor([])

        with self.assertRaises(parse.InvalidDataException):
            processor.convert_type(FakeXlrd.XL_CELL_NUMBER, parse.ExcelProcessor.CELL_INT, 3.9)

    def test_text_to_number_rejects_blank_values_with_parser_exception(self):
        processor, _fake_xlrd = self.processor([])

        with self.assertRaises(parse.InvalidDataException):
            processor.convert_type(FakeXlrd.XL_CELL_TEXT, parse.ExcelProcessor.CELL_INT, "  ")

        with self.assertRaises(parse.InvalidDataException):
            processor.convert_type(FakeXlrd.XL_CELL_TEXT, parse.ExcelProcessor.CELL_FLOAT, "")

    def test_text_to_number_rejects_invalid_values_with_parser_exception(self):
        processor, _fake_xlrd = self.processor([])

        with self.assertRaises(parse.InvalidDataException):
            processor.convert_type(FakeXlrd.XL_CELL_TEXT, parse.ExcelProcessor.CELL_INT, "not-a-number")

        with self.assertRaises(parse.InvalidDataException):
            processor.convert_type(FakeXlrd.XL_CELL_TEXT, parse.ExcelProcessor.CELL_FLOAT, "not-a-number")

    def test_conversion_errors_summarize_long_text_values(self):
        processor, _fake_xlrd = self.processor([])
        value = "x" * (parse.MAX_ERROR_VALUE_LENGTH + 20)

        with self.assertRaises(parse.InvalidDataException) as context:
            processor.convert_type(FakeXlrd.XL_CELL_TEXT, parse.ExcelProcessor.CELL_INT, value)

        message = str(context.exception)
        self.assertIn(("x" * parse.MAX_ERROR_VALUE_LENGTH) + "...", message)
        self.assertNotIn(value, message)

    def test_conversion_errors_normalize_multiline_text_values(self):
        processor, _fake_xlrd = self.processor([])

        with self.assertRaises(parse.InvalidDataException) as context:
            processor.convert_type(FakeXlrd.XL_CELL_TEXT, parse.ExcelProcessor.CELL_FLOAT, "bad\r\nnext")

        message = str(context.exception)
        self.assertIn("bad next", message)
        self.assertNotIn("\r", message)
        self.assertNotIn("\n", message)

    def test_text_conversions_reject_non_string_values_with_parser_exception(self):
        processor, _fake_xlrd = self.processor([])

        for target_type in [
            parse.ExcelProcessor.CELL_TEXT,
            parse.ExcelProcessor.CELL_INT,
            parse.ExcelProcessor.CELL_FLOAT,
        ]:
            with self.assertRaises(parse.InvalidDataException):
                processor.convert_type(FakeXlrd.XL_CELL_TEXT, target_type, None)

    def test_non_finite_number_conversion_is_rejected(self):
        processor, _fake_xlrd = self.processor([])

        for value in [float("nan"), float("inf"), float("-inf")]:
            with self.assertRaises(parse.InvalidDataException):
                processor.convert_type(FakeXlrd.XL_CELL_NUMBER, parse.ExcelProcessor.CELL_TEXT, value)

            with self.assertRaises(parse.InvalidDataException):
                processor.convert_type(FakeXlrd.XL_CELL_NUMBER, parse.ExcelProcessor.CELL_FLOAT, value)

            with self.assertRaises(parse.InvalidDataException):
                processor.convert_type(FakeXlrd.XL_CELL_NUMBER, parse.ExcelProcessor.CELL_INT, value)

        for value in ["nan", "inf", "-inf"]:
            with self.assertRaises(parse.InvalidDataException):
                processor.convert_type(FakeXlrd.XL_CELL_TEXT, parse.ExcelProcessor.CELL_FLOAT, value)

    def test_date_conversion_is_not_claimed(self):
        processor, _fake_xlrd = self.processor([])

        with self.assertRaises(parse.InvalidDataException):
            processor.convert_type(FakeXlrd.XL_CELL_TEXT, parse.ExcelProcessor.CELL_DATE, "2026-06-08")

        with self.assertRaises(parse.InvalidDataException):
            processor.convert_type(FakeXlrd.XL_CELL_DATE, parse.ExcelProcessor.CELL_TEXT, 44352)

    def test_process_skips_header_and_handles_missing_cells(self):
        rows = [
            [(FakeXlrd.XL_CELL_TEXT, "Name"), (FakeXlrd.XL_CELL_TEXT, "Count")],
            [(FakeXlrd.XL_CELL_TEXT, " Alice "), (FakeXlrd.XL_CELL_NUMBER, 2.0)],
            [(FakeXlrd.XL_CELL_TEXT, "Bob")],
            [(FakeXlrd.XL_CELL_EMPTY, ""), (FakeXlrd.XL_CELL_NUMBER, 3.0)],
        ]
        received = []
        done = []
        processor, fake_xlrd = self.processor(
            rows,
            lambda rowid, values: received.append((rowid, values)),
            lambda: done.append(True),
        )

        processor.process("fixture.xls", "People", True, [
            parse.ExcelProcessor.CELL_TEXT,
            parse.ExcelProcessor.CELL_INT,
        ])

        self.assertEqual("fixture.xls", fake_xlrd.opened[0][0])
        self.assertTrue(fake_xlrd.opened[0][1])
        self.assertTrue(fake_xlrd.opened[0][2].released)
        self.assertEqual([
            (1, ["Alice", 2]),
            (2, ["Bob", None]),
            (3, [None, 3]),
        ], received)
        self.assertEqual([True], done)

    def test_process_allows_cell_empty_targets_to_skip_present_values(self):
        rows = [
            [(FakeXlrd.XL_CELL_TEXT, "skip"), (FakeXlrd.XL_CELL_TEXT, " Keep ")],
            [(FakeXlrd.XL_CELL_NUMBER, 3.0), (FakeXlrd.XL_CELL_TEXT, "Also keep")],
        ]
        received = []
        processor, _fake_xlrd = self.processor(
            rows,
            lambda rowid, values: received.append((rowid, values)),
        )

        processor.process("fixture.xls", "People", False, [
            parse.ExcelProcessor.CELL_EMPTY,
            parse.ExcelProcessor.CELL_TEXT,
        ])

        self.assertEqual([
            (0, [None, "Keep"]),
            (1, [None, "Also keep"]),
        ], received)

    def test_exception_callback_receives_row_errors_and_processing_continues(self):
        rows = [
            [(FakeXlrd.XL_CELL_TEXT, "Count")],
            [(FakeXlrd.XL_CELL_TEXT, "not-a-number")],
            [(FakeXlrd.XL_CELL_TEXT, "4")],
        ]
        received = []
        errors = []
        done = []
        processor, _fake_xlrd = self.processor(
            rows,
            lambda rowid, values: received.append((rowid, values)),
            lambda: done.append(True),
            lambda rowid, exc: errors.append((rowid, exc)),
        )

        processor.process("fixture.xls", "People", True, [parse.ExcelProcessor.CELL_INT])

        self.assertEqual([(2, [4])], received)
        self.assertEqual(1, len(errors))
        self.assertEqual(1, errors[0][0])
        self.assertIsInstance(errors[0][1], parse.InvalidDataException)
        self.assertEqual([True], done)


if __name__ == "__main__":
    unittest.main()
