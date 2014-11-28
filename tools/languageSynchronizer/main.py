import EnglishFile
import FrenchFile
import compareEngFiles
import InterLanguage
import pathFile
import os, sys

pathname = os.path.dirname(sys.argv[0]) 
pathList = pathname.split('\\')
pathName = ''
for item in pathList:
    if item  in 'Foundation':
        break
    else:   
        pathName += item + '\\' 
        
pathFile.addPath(pathName)

print " "
print " --- [ Welcome ] --- "
inp = input("Define source path ? [0/1] [recommended: 1]")
if inp:
    pathFile.EnFileToOpen = raw_input("English message properties : ")
    pathFile.frFileToOpen = raw_input("French message properties : ")
    pathFile.dirPathFundation = raw_input("Main src dir [ex: C:\Flex Builder 3\Foundation\src] ")
    pathFile.dirPathSettings = raw_input("Settings src dir [ex: C:\Flex Builder 3\Settings\src]")

print "_____________________________________________________ "
print " The default language file is english"
print " 1 - to synchronize english with the flex source code "
print " 0 - to continue"
print "_____________________________________________________ "
inp = input("option:")

if inp:
    print "wait the file is synchronizing... [This may take a few minutes] "

    list = compareEngFiles.compareEngFiles()
    print "\n-----------------------------------"
    print "-> the files not used is:\n"
    for item in list:
        if item != " " and item != "\n" :
            print item
    print "-----------------------------------\n"             

#    print " 1 - to change the file message.properties"
#    print " 0 - to continue"
#    inp = input("number:")
    inp = 0

    if inp:
        EnglishFile.deleteInFile(list)
print "________________________________________________ "        
print "Do you want to synchronize flex with english ?"        
print " 1 - yes"
print " 0 - no"    
print "________________________________________________ "         
inp = input("option:")
if inp:
    list = compareEngFiles.compareFilesEng();

    print "\n-----------------------------------"
    print " lines in flex but not in english :"   
    for line in list:
        print line
    print "-----------------------------------\n"        
print "________________________________________________ "    
print " 1 - to synchronize english with french"
print " 0 - to continue"   
print "________________________________________________ "
inp = input("option:")
if inp:
    list = InterLanguage.compareEnFr()

    print "\n------------------------------------"
    print " lines in english but not in french :"    
    for item in list:
        print item
    print "------------------------------------\n"
    
    optionsSave = input("save[0/1] :")
    if optionsSave:    
        openFile = raw_input('save as:')
        print openFile
        file = open(openFile,'w')
        file.writelines(list)
        file.close()

print "________________________________________________ "
print "Do you want to synchronize french with flex ?"        
print " 1 - yes"
print " 0 - no"
print "________________________________________________ "

inp = input("option:")
if inp:
    list = InterLanguage.compareFrEn();
    print "\n----------------------------------"
    print "words in french and not in english :"
    for line in list:
        print line
    print "----------------------------------\n"
    
#    print " 1 - to change the file message.properties"
#    print " 0 - to continue"
#    inp = input("number:")
    inp = 0

    if inp:
        FrenchFile.deleteInFrFile(list)
       
print ""        
print "____________________________"    
print "END" 
print "____________________________"   
        
        