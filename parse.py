import math


class _MissingXlrd(object):
    XL_CELL_EMPTY = 0
    XL_CELL_TEXT = 1
    XL_CELL_NUMBER = 2
    XL_CELL_DATE = 3

    def open_workbook(self, _excel, on_demand=False):
        raise ImportError("xlrd is required to process real Excel workbooks")


try:
    import xlrd
except ImportError:
    xlrd = _MissingXlrd()

try:
    string_types = (basestring,)
except NameError:
    string_types = (str,)

try:
    integer_types = (int, long)
except NameError:
    integer_types = (int,)

MAX_ERROR_VALUE_LENGTH = 80


class InvalidDataException(Exception):
    pass


class ExcelProcessor(object):
    CELL_EMPTY = 0
    CELL_TEXT = 1
    CELL_INT = 2
    CELL_FLOAT = 3
    CELL_DATE = 4
    VALID_CELL_TYPES = (CELL_EMPTY, CELL_TEXT, CELL_INT, CELL_FLOAT, CELL_DATE)

    def __init__(self, rowdatacallback, parsedonecallback, exceptioncallback=None):
        self.rowdatacallback = rowdatacallback
        self.parsedonecallback = parsedonecallback
        self.exceptioncallback = exceptioncallback

    def process(self, excel, sheet_name, has_header, cell_types=None):
        self.validate_callbacks()
        cell_types = self.validate_cell_types(cell_types)
        excel = self.validate_workbook_path(excel)
        sheet_name = self.validate_sheet_name(sheet_name)
        has_header = self.validate_has_header(has_header)

        book = xlrd.open_workbook(excel, on_demand=True)
        try:
            sheet = book.sheet_by_name(sheet_name)
            rowno = 1 if has_header else 0

            for rowid in range(rowno, sheet.nrows):
                try:
                    cellvalues = []
                    for cellid in range(len(cell_types)):
                        try:
                            ct = sheet.cell_type(rowid, cellid)
                            if ct != xlrd.XL_CELL_EMPTY:
                                value = self.convert_type(ct, cell_types[cellid], sheet.cell_value(rowid, cellid))
                                cellvalues.append(value)
                            else:
                                cellvalues.append(None)
                        except IndexError:
                            cellvalues.append(None)
                    self.rowdatacallback(rowid, cellvalues)
                except Exception as exc:
                    if self.exceptioncallback is not None:
                        self.exceptioncallback(rowid, exc)
                    else:
                        raise

            self.parsedonecallback()
        finally:
            release_resources = getattr(book, "release_resources", None)
            if release_resources is not None:
                release_resources()

    def validate_callbacks(self):
        if not callable(self.rowdatacallback):
            raise InvalidDataException("Row data callback must be callable")
        if not callable(self.parsedonecallback):
            raise InvalidDataException("Parse completion callback must be callable")
        if self.exceptioncallback is not None and not callable(self.exceptioncallback):
            raise InvalidDataException("Exception callback must be callable or None")

    def convert_type(self, curtype, newtype, data):
        if newtype == ExcelProcessor.CELL_EMPTY:
            return None

        if curtype == xlrd.XL_CELL_TEXT:
            if newtype == ExcelProcessor.CELL_TEXT:
                return self.clean_text(data)
            elif newtype == ExcelProcessor.CELL_INT:
                return self.convert_text_to_int(data)
            elif newtype == ExcelProcessor.CELL_FLOAT:
                return self.convert_text_to_float(data)
            elif newtype == ExcelProcessor.CELL_DATE:
                raise InvalidDataException("Conversion to Date Type not supported")
            else:
                raise InvalidDataException("Invalid target datatype:" + str(newtype))

        elif curtype == xlrd.XL_CELL_NUMBER:
            if newtype == ExcelProcessor.CELL_TEXT:
                self.convert_number_to_float(data)
                return str(data)
            elif newtype == ExcelProcessor.CELL_INT:
                return self.convert_number_to_int(data)
            elif newtype == ExcelProcessor.CELL_FLOAT:
                return self.convert_number_to_float(data)
            elif newtype == ExcelProcessor.CELL_DATE:
                raise InvalidDataException("Conversion to Date Type not supported")
            else:
                raise InvalidDataException("Invalid target datatype : " + str(newtype))
        elif curtype == xlrd.XL_CELL_DATE:
            raise InvalidDataException("Conversion from Date Type not supported")
        else:
            raise InvalidDataException("Invalid source datatype : " + str(curtype))

    def validate_cell_types(self, cell_types):
        if cell_types is None:
            return []

        try:
            normalized = list(cell_types)
        except TypeError:
            raise InvalidDataException("Target cell types must be iterable")

        for cell_type in normalized:
            if (
                not isinstance(cell_type, integer_types)
                or isinstance(cell_type, bool)
                or cell_type not in self.VALID_CELL_TYPES
            ):
                raise InvalidDataException("Invalid target datatype:" + self.format_error_value(cell_type))
        return normalized

    def validate_workbook_path(self, excel):
        if not isinstance(excel, string_types) or not excel.strip():
            raise InvalidDataException("Workbook path must be a non-empty .xls path")
        if not excel.lower().endswith(".xls"):
            raise InvalidDataException("Workbook path must end with .xls")
        return excel

    def validate_sheet_name(self, sheet_name):
        if not isinstance(sheet_name, string_types) or not sheet_name.strip():
            raise InvalidDataException("Sheet name must be a non-empty string")
        return sheet_name

    def validate_has_header(self, has_header):
        if not isinstance(has_header, bool):
            raise InvalidDataException("Header flag must be a boolean")
        return has_header

    def convert_number_to_int(self, data):
        number = self.convert_number_to_float(data)
        if number.is_integer():
            return int(number)
        raise InvalidDataException(
            "Fractional numeric value cannot be converted to int: " + self.format_error_value(data)
        )

    def convert_number_to_float(self, data):
        number = float(data)
        if math.isnan(number) or math.isinf(number):
            raise InvalidDataException(
                "Non-finite numeric value cannot be converted to float: " + self.format_error_value(data)
            )
        return number

    def clean_text(self, data):
        if not isinstance(data, string_types):
            raise InvalidDataException("Text cell value must be text: " + self.format_error_value(data))
        return data.strip()

    def convert_text_to_int(self, data):
        value = self.clean_text(data)
        if value == "":
            raise InvalidDataException("Empty text value cannot be converted to int")
        try:
            return int(value)
        except ValueError:
            raise InvalidDataException("Text value cannot be converted to int: " + self.format_error_value(value))

    def convert_text_to_float(self, data):
        value = self.clean_text(data)
        if value == "":
            raise InvalidDataException("Empty text value cannot be converted to float")
        try:
            return self.convert_number_to_float(value)
        except ValueError:
            raise InvalidDataException("Text value cannot be converted to float: " + self.format_error_value(value))

    def format_error_value(self, data):
        try:
            value = data if isinstance(data, string_types) else str(data)
        except Exception:
            return "<unprintable>"

        value = " ".join(value.splitlines())
        if len(value) > MAX_ERROR_VALUE_LENGTH:
            return value[:MAX_ERROR_VALUE_LENGTH] + "..."
        return value
