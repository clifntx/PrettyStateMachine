
# coding: utf-8


import os
import csv
badstr = ['\xa0', 'xa0', '\\']
target = 'Kyocera\xa0TaskAlfa\xa03501i\xa0'

XeroxDriverPath='C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\\x2UNIVX.inf'
KyoceraDriverPath='C:\Push\Kyocera\KyoClassicUniversalPCL6_v1.56\OEMsetup.inf'
KMC3110DriverPath='C:\Push\KonicaMinolta\C3110\bizhubC3110_Win10_PCL_PS_XPS_FAX_v1.2.1.0\bizhubC3110_Win10_PCL_PS_XPS_FAX_v1.2.1.0\Drivers\Win_x64\KOBK4J__.inf'
KM4750DriverPath='C:\Push\KonicaMinolta\bizhub4750Series_Win10_PCL_PS_XPS_FAX_v3.1.0.0\Drivers\Win_x64\KOBK1J__.inf'
C3850fsDriverPath='C:\Push\KonicaMinolta\BizhubC3850fs_MFP_Win_x64\PCL\english\KOBJ_J__.inf'

driverMap = {
    'Xerox Global Print Driver PCL6':'XeroxDriverPath',
    'Kyocera Classic Universaldriver PCL6':'KyoceraDriverPath',
    'KONICA MINOLTA C3110 PCL6':'KMC3110DriverPath',
    'KONICA MINOLTA 4750 Series PCL6':'KM4750DriverPath',
    'KONICA MINOLTA C3850 Series PCL6':'C3850fsDriverPath'
}

def cleanBadStr(string, badstr):
    for bs in badstr:
        try:
            ibs = string.index(bs)
            clean = string.replace(bs, ' ').strip()
#             print '[%s] >> [%s]' % (string, clean)
            return clean
        except:
#             print '.',
            return string
    return clean

def getHeaders(csvpath):
    with open(csvpath, 'r') as f:
        reader = csv.reader(f)
        headers = reader.next()
        print 'dirty headers: ',headers
        for i in range(len(headers)):
            headers[i] = cleanBadStr(headers[i],badstr)
        print '-'
        print 'clean headers: ',headers
        return headers
        
def getLod(csvpath):
    with open(csvpath, 'r') as f:
        reader = csv.DictReader(f)
        for d in reader:
            for key in d:
                if len(key)<1: continue
                cleankey = cleanBadStr(key,badstr)
                newd[cleankey] = cleanBadStr(d[key],badstr)
            lod.append(newd.copy())
        return lod
    
def testLod(lod, num=3):
    for i,row in enumerate(lod):
        if i>=num: break
        print row
        print ''
        
def gatherInstallGroups(lod):
    installGroups = gatherSeries('Install Group',lod)
    return installGroups

def gatherAccounts(lod):
    accounts = gatherSeries('Account',lod)
    return accounts

def gatherSeries(key,lod):
    series = []
    for i,d in enumerate(lod):
#         if i >= 3: break
        if d[key] == 'None':
            pass
        if d[key] not in series and d[key] != 'None':
            series.append(d[key])
    return series

def getDivision(printerDict):
    account = printerDict['Account']
    divisions = [
            ['Becket', ['Becket MA', 'Becket ME', 'Becket NH', 'Becket House at Rumney', 'Becket Orford']],
            ['MPA', ['Mount Prospect Academy', 'MPA Community']],
            ['MVTC', ['MVTC']],
            ['VPI North', ['VPI North']]
        ]
    for d in divisions:
        if account in d[1]:
            return d[0]
    return 'NOT FOUND'

def gatherDivisions(lod):
    divisions = []
    division = ''
    for d in lod:
        division = getDivision(d)
        if division not in divisions and len(division) > 0:
            divisions.append(division)
    return divisions
            

def getInstallScriptName(printerDict):
    name = 'InstallPrinter_%s_%s.bat' %                 (printerDict['Install Group'],printerDict['Printer Name'])
    return name.replace(' ','')

def getInstallScriptString(printerDict):
#     if 'Kyocera Classic Universaldriver PCL6' in driverMap:
#         print '>> driver search working!'
        
    if len(printerDict['Driver'])>0:
        driverPath = 'None'
        printerDict['Driver'] = 'unknown'
    elif printerDict['Driver'] in driverMap:
#         print '>> found driver!'
        driverPath = driverMap[printerDict['Driver']]
    else:
        driverPath = 'None'
        
    setup = ''
    setup += ':: %s \n' % printerDict['Printer Name']
    setup += ':: Define variables\n'
    setup += '\tset location=%s\n' % printerDict['Printer Name']
    setup += '\tset IP=%s\n' % printerDict['IP']
    setup += '\tset port=IP_%IP%\n'
    setup += '\tset driver=%s\n' % printerDict['Driver']
    setup += '\tset path=%s\n' % driverPath
    portInstall = ''
    portInstall += ':: Install Port\n'
    portInstall += 'cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r %port% -h %IP% -o raw -n 9100\n'
    portInstall += '::take a breath\n'
    portInstall += 'timeout /t 2 /nobreak\n'
    printerInstall = ''
    printerInstall += ':: Install Printer\n'
    printerInstall += 'rundll32 printui.dll,PrintUIEntry /if /b "%location% - %driver%" /f %path% /r "%port%" /m "%driver%" /Z\n'
    printerInstall += 'timeout /t 2 /nobreak\n'
    
    script = '%s%s%s' % (setup,portInstall,printerInstall)
    return script

def renameExistingScript(scriptName, path):
	print '>> Renamed existing file to "OLD_%s"' % scriptName
	if 'OLD_%s'%scriptName in os.listdir(path):
		os.remove('OLD_%s'%scriptName)
	os.rename(scriptName, 'OLD_%s'%scriptName)
	return True

def deleteExistingScript(scriptName, path):
	print '>> Deleting existing file: %s' % scriptName
	if 'OLD_%s'%scriptName in os.listdir(path):
		os.remove('OLD_%s'%scriptName)
	if scriptName in os.listdir(path):
		os.remove('OLD_%s'%scriptName)
	return True
	
def writePrinterInstallScript(printerDict, path):
    scriptName = getInstallScriptName(printerDict)
    scriptString = getInstallScriptString(printerDict)
    scriptPath = '%s/%s' % (path,scriptName)
#     print 'scriptPath: %s' % scriptPath
    if scriptName in os.listdir(path):
		#renameExistingScript(scriptName, path)
        deleteExistingScript(scriptName, path)
    with open(scriptPath, 'wb') as f:
        f.write(scriptString)
#     print '>> Created file %s' % scriptPath
    return True

def deleteExistingScripts(path):
	pass
	return True
	
def writeDirStructure(lod):
    accounts = gatherAccounts(lod)
    divisions = gatherDivisions(lod)
    states = gatherSeries('State',lod)        
    for d in lod:
        division = getDivision(d)
        account = d['Account']
        state = d['State']
        try:
            os.mkdir(division)
        except:
            pass
        try:
            os.mkdir('.\%s\%s' %(division,state))
            print '>> Create dir [%s\%s\]' % (division,state)
        except Exception as e:
#             print e
            pass
    return True


	
	
def writeInstallScripts(lod):
#     print 'pwd: %s' % os.getcwd()
    for d in lod:
        division = getDivision(d)
        account = d['Account']
        state = d['State']
        path = './%s/%s' % (division, state)
        try:
            writePrinterInstallScript(d, path)
            print '>> Created [%s/%s]' % (path, getInstallScriptName(d))
        except Exception as e:
            print '>> --------------------FAILED: [%s/%s]' % (path, getInstallScriptName(d))
            print str(e)
            pass
    return True

print ">> Everything working!"
printerDict = {'City': 'Pike', 'Account': 'VPI North', 'Admin password': '', 'IP': '10.10.12.87', 'Notes': '', 'Install Group': 'None', 'Tag Number': 'na', 'State': 'NH', 'BW or Color': '', 'Autotask Account': 'Vermont Permanency Initiative North', 'Model': 'HP Color LaserJet M252dw', 'Public': '0', 'Vendor': 'AllAccess', 'MAC Address': '', 'Driver': '', 'Serial Number': '', 'Printer Name': 'Red School Building', 'Admin username': ''}

lod = []
scriptWritePath = 'Z:\Scripts\PrinterInstalls\IndividaulInstalls\\'
csvpath = '.\BecketPrinters.csv'
badstr = ['\xa0']
newd = {}
installGroups = []
        
lod = getLod(csvpath)

writeDirStructure(lod)

writeInstallScripts(lod)

