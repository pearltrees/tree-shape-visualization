import FrenchFile
import EnglishFile

def compareEnFrAux(enFile, frFile):

    notUsed = []
    
    while 1:
        line = enFile.getNextLine()
        token = line.split('=').pop(0).split(' ').pop(0)
        if token:
            if frFile.findToken(token) == 0:
                notUsed.append(line)
        else:
            return notUsed

def compareFrEnAux(enFile, frFile):    

    notUsed = []
    
    while 1:
        token = frFile.getNextToken()
        if token:
            if enFile.findToken(token) == 0:
                notUsed.append(token)
        else:
            return notUsed

def compareEnFr(): 
    frFile = FrenchFile.frenchFile()
    frFile.openFile()

    enFile  = EnglishFile.englishFile()
    enFile.openFile()

    ret = compareEnFrAux(enFile,frFile )

    frFile.closeFile()
    enFile.closeFile()
    
    return ret

def compareFrEn():
    
    frFile = FrenchFile.frenchFile()
    frFile.openFile()

    enFile  = EnglishFile.englishFile()
    enFile.openFile()

    ret = compareFrEnAux(enFile,frFile)
    
    frFile.closeFile()
    enFile.closeFile()
    
    return ret

#listNotUsed = compareEnFr()
#print " "
#print " "
#print "----------- There is in english file and not in french file -----------"
#for item in listNotUsed:
#    print item        