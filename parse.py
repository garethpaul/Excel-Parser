import sys
import xlrd


class InvalidDataException (Exception):
    pass

class ExcelProcessor ():
    CELL_EMPTY  = 0 # xlrd.XL_CELL_EMPTY  # 0
    CELL_TEXT   = 1 # xlrd.XL_CELL_TEXT   # 1
    CELL_INT    = 2 # xlrd.XL_CELL_NUMBER # 2
    CELL_FLOAT  = 3 # xlrd.XL_CELL_NUMBER # 2
    CELL_DATE   = 4 # xlrd.XL_CELL_DATE   # 3

    def __init__ (self, rowdatacallback, parsedonecallback, exceptioncallback = None):
        self.rowdatacallback = rowdatacallback
        self.parsedonecallback = parsedonecallback
        self.exceptioncallback = exceptioncallback

    def process (self, excel, sheet_name, has_header, cell_types = []):
        book = xlrd.open_workbook (excel)
        sheet = book.sheet_by_name (sheet_name)

        if has_header:
            rowno = 1
        else:
            rowno = 0

        for rowid in range (rowno, sheet.nrows):
            try:
                cellvalues = []
                for cellid in range (len (cell_types)):
                    try:
                        ct = sheet.cell_type (rowid, cellid)
                        if ct != xlrd.XL_CELL_EMPTY:
                            value = self.convert_type (ct, cell_types [cellid], sheet.cell_value (rowid, cellid))
                            cellvalues.append (value)
                        else:
                            cellvalues.append (None)
                    except IndexError:
                        cellvalues.append (None)
                self.rowdatacallback (rowid, cellvalues)
            except Exception, e:
                if self.exceptioncallback != None:
                    self.exceptioncallback (rowid, e)
                else:
                    raise e

        self.parsedonecallback ()

    def convert_type (self, curtype, newtype, data):
        if curtype == xlrd.XL_CELL_TEXT:
            if newtype == ExcelProcessor.CELL_TEXT:
                return data.strip ()
            elif newtype == ExcelProcessor.CELL_INT:
                return int (data.strip ())
            elif newtype == ExcelProcessor.CELL_FLOAT:
                return float (data.strip ())
            elif newtype == ExcelProcessor.CELL_DATE:
                raise InvalidDataException ("Conversion to Date Type not supported")
            else:
                raise InvalidDataException ("Invalid target datatype:"+str(newtype))

        elif curtype == xlrd.XL_CELL_NUMBER:
            if newtype == ExcelProcessor.CELL_TEXT:
                return str (data)
            elif newtype == ExcelProcessor.CELL_INT:
                return int (data)
            elif newtype == ExcelProcessor.CELL_FLOAT:
                return float (data)
            elif newtype == ExcelProcessor.CELL_DATE:
                raise InvalidDataException ("Conversion to Date Type not supported")
            else:
                raise InvalidDataException ("Invalid target datatype : " +
                                            str (newtype))
        elif curtype == xlrd.XL_CELL_DATE:
            raise InvalidDataException ("Conversion from Date Type not supported")
        else:
            raise InvalidDataException ("Invalid source datatype : " + str (curtype))