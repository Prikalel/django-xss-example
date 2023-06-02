import sys
import globals

# local trace function which returns itself
def tracefunc(frame, event, arg = None):
    if event == 'line':
        filename: str = frame.f_code.co_filename
        line_number: int = frame.f_lineno
        res_string: str = f"{filename}+{line_number}"
        globals.coverage.add(res_string)

    return tracefunc

# EXAMPLE:
#sys.settrace ( tracefunc ) # Turn on
#test2 (a , b )
#sys . settrace ( None )
#print ( len(coverage ) )

