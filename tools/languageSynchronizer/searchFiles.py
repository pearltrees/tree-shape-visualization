import os
import re
import pathFile

class searchFile:
        
    def searchFiles(self, wordList, dirPath):
        
        for dirpath, dirnames, filenames in os.walk(dirPath):        
            for file in filenames:
                fileNameExt = os.path.splitext(file)
                fileExt = fileNameExt[-1]
                if fileExt and fileExt == '.as' or  fileExt == '.mxml' :
                    self.searchInFile(dirpath, file, wordList)

    def searchInFile(self, dirpath, file, wordList):
     
        fileToOpen = dirpath + '\\' + file
         
        f = open(fileToOpen , 'r')

        text = f.read()

        list = re.findall('getText\(\'.*?\'' , text)
        for line in list:
            
            line = line.split('\'')
            wordList.append(line[1])

        list2 = re.findall('getText\(".*?"' , text)
        for line in list2:
            
#            if re.search(':', line):
#                line = line.split(':')          
#                for subLine in line:
#                    subLine = subLine.split('\"')
#                    wordList.append(subLine[1]) 
#                    
#            elif re.search('\+', line):
#                line = line.split('\+')        
#                for subLine in line:
#                    subLine = subLine.split('\"')
#                    if (len(subLine) >= 2 ):
#                        wordList.append(subLine[1])    
#                         
#            else:
            line = line.split('"')
            wordList.append(line[1])
            
        f.close()
         
    def makeTokenList(self):

        wordList = []
        
        self.searchFiles(wordList, pathFile.dirPathFundation)
        self.searchFiles(wordList, pathFile.dirPathNavBarAlone)
        self.searchFiles(wordList, pathFile.dirPathRaVis)
        self.searchFiles(wordList, pathFile.dirPathPearltreesAssets)
        self.searchFiles(wordList, pathFile.dirPathSettings)

        return  wordList

