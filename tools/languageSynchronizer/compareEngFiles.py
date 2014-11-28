import searchFiles
import EnglishFile

def compareEngFilesAux(enFile, tokenList, listNotUsed):
    while 1:
            token = enFile.getNextToken()
            if token:
                if not token in tokenList:
                    listNotUsed.append(token)
            else:
                return listNotUsed

def compareMakeListEngAux(enFile, tokenList, listDifferences):
    
    listAux = []
     
    while 1:
        token = enFile.getNextToken()
        if (token):
            listAux.append(token)
        else:
            break
         
    for line in tokenList:
        if not line in listAux:    
            listDifferences.append(line)
             
    return listDifferences        

def compareEngFiles():

    sFile = searchFiles.searchFile()
    tokenList = sFile.makeTokenList()

    enFile = EnglishFile.englishFile()
    enFile.openFile()

    listNotUsed = []
    listNotUsed = compareEngFilesAux(enFile, tokenList, listNotUsed)

    enFile.closeFile();
    
    return listNotUsed

def compareFilesEng():
 
    sFile = searchFiles.searchFile()
    tokenList = sFile.makeTokenList()

    enFile = EnglishFile.englishFile()
    enFile.openFile()

    listDifferences = []
    compareMakeListEngAux(enFile, tokenList, listDifferences)

    enFile.closeFile();
    
    return listDifferences
            
#token = enFile.getNextToken()
#if token:
#    print tokenList.index(token)
    