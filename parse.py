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


class InvalidDataException(Exception):
    pass


class ExcelProcessor(object):
    CELL_EMPTY = 0
    CELL_TEXT = 1
    CELL_INT = 2
    CELL_FLOAT = 3
    CELL_DATE = 4

    def __init__(self, rowdatacallback, parsedonecallback, exceptioncallback=None):
        self.rowdatacallback = rowdatacallback
        self.parsedonecallback = parsedonecallback
        self.exceptioncallback = exceptioncallback

    def process(self, excel, sheet_name, has_header, cell_types=None):
        if cell_types is None:
            cell_types = []

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

    def convert_type(self, curtype, newtype, data):
        if curtype == xlrd.XL_CELL_TEXT:
            if newtype == ExcelProcessor.CELL_TEXT:
                return data.strip()
            elif newtype == ExcelProcessor.CELL_INT:
                return int(data.strip())
            elif newtype == ExcelProcessor.CELL_FLOAT:
                return float(data.strip())
            elif newtype == ExcelProcessor.CELL_DATE:
                raise InvalidDataException("Conversion to Date Type not supported")
            else:
                raise InvalidDataException("Invalid target datatype:" + str(newtype))

        elif curtype == xlrd.XL_CELL_NUMBER:
            if newtype == ExcelProcessor.CELL_TEXT:
                return str(data)
            elif newtype == ExcelProcessor.CELL_INT:
                return int(data)
            elif newtype == ExcelProcessor.CELL_FLOAT:
                return float(data)
            elif newtype == ExcelProcessor.CELL_DATE:
                raise InvalidDataException("Conversion to Date Type not supported")
            else:
                raise InvalidDataException("Invalid target datatype : " + str(newtype))
        elif curtype == xlrd.XL_CELL_DATE:
            raise InvalidDataException("Conversion from Date Type not supported")
        else:
            raise InvalidDataException("Invalid source datatype : " + str(curtype))
