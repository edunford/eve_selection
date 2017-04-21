'''
Mapper for the "Warp To character" Logs
'''

import collections
import doobutil
from doobutil import PrintSimpleKeyVals

def mapper():
    for e in doobutil.ReadInputEvent(quickFilter="park::Warp_Char"):
        # print(e)
        print("{eventDate}\t{characterID}\t{characterID}\t{toCharacterID}\t{systemID}\t{distance}".format(eventDate=e.dt[:10],characterID=e.charID,toCharacterID = e.destCharID,systemID=e.solarSystemID,distance = e.minDist))

mapper()
