#!/usr/bin/env python

"""
Processes eventlogs from Application Logs.
"""

import collections
import doobutil
from doobutil import PrintSimpleKeyVals



def mapper():
    for e in doobutil.ReadInputEvent(quickFilter="corporation::InsertApplication"):
         print("%s\t%s\t%s\t%s\t%s" % (e.dt[:10], e.corpID, e.charID, e.fromCharID, e.status))


mapper()
