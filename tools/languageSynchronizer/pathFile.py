path = ''
EnFileToOpen = ''
frFileToOpen = ''
dirPathFundation = ''
dirPathNavBarAlone = ''
dirPathRaVis = ''
dirPathPearltreesAssets = ''
dirPathSettings = ''

def addPath(newPath):
    
    global path
    global EnFileToOpen
    global frFileToOpen 
    global dirPathFundation
    global dirPathNavBarAlone
    global dirPathRaVis
    global dirPathPearltreesAssets
    global dirPathSettings
    
    path = newPath
    EnFileToOpen = path + 'Foundation\\src\\locale\\en_US\\message.properties'
    frFileToOpen = path + 'Foundation\\src\\locale\\fr_FR\\message.properties'
    dirPathFundation = path + 'Foundation\\src'
    dirPathNavBarAlone = path + 'NavBarAlone\\src'
    dirPathRaVis = path + 'RaVis\\src'
    dirPathPearltreesAssets = path + 'PearltreesAssets\\src'
    dirPathSettings = path + 'Settings\\src'
    
    