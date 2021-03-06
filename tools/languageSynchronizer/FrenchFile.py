import pathFile

class frenchFile:

    file

    def openFile(self):
        self.file = open(pathFile.frFileToOpen, 'r')
        return

    def closeFile(self):
        self.file.close()
        return

    def getNextLine(self):
        line = self.file.readline() 
        if not line.startswith('#'):
           return line
        else:
           return self.getNextLine()
           
    def getNextToken(self):
        try:
            line = self.getNextLine()
        except:
            print "error"
            return "null";
        token = line.split('=')
        return token.pop(0)

    def findToken(self, token):
        self.file.seek(0,0)
        while 1:    
            myToken = self.getNextToken()
            if myToken:
                if cmp(myToken, token) == 0:
                    return 1
            else:
                return 0    
    
def deleteInFrFile(list):

    file = open(pathFile.frFileToOpen)

    output = []

    newList = []
    
    print "not synchronizing faqs..."
    #not erase faqs
    for item in list:
        token = item.split('.')
        token = token.pop(0)
        if not 'faq' in token:
            newList.append(item)        
       
    for line in file:
        token = line.split('=').pop(0).split(' ').pop(0)
        if not token in newList:
            output.append(line)
            
    file.close()
    file = open(pathFile.frFileToOpen, 'w')
    file.writelines(output)
    file.close()   