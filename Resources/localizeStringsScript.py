from pprint import *
import os
import json
from subprocess import call

def loadStrings():
	allStrings = dict()
	json_data=open('Tags.json')
	tags = json.load(json_data)
	json_data.close()
	
	for category in tags.keys():
		allStrings[category] = 'Title For Category'

	for key in tags.keys():
		for pointType in tags[key].keys():
			description = 'POI type with osm tags:'
			i = 0
			for pointTags in tags[key][pointType]['tags']:
				if	i > 0:
					description = description+','
				i+=1
				description= description +' '+pointTags +' = '+ tags[key][pointType]['tags'][pointTags]
				
			allStrings[pointType] = description

	json_data=open('Optional.json')
	optional = json.load(json_data)
	json_data.close()

	for key in optional.keys():
		allStrings[optional[key]['displayName']] = 'Optional tag with osm key: '+optional[key]['osmKey']
		values = optional[key]['values']
		if type(values) is not unicode:
			for key in values.keys():
				allStrings[key] = 'Optional value with osm value: '+values[key]
	return allStrings
	
def writeToFile(allStings):
	f = open('strings.h', 'w')
	appStringsFile = open('../OSM POI Editor/OPEStrings.h','r')
	i =0
	for string in allStrings:
		try:
			f.write('#define string'+str(i)+' NSLocalizedString(@\"')
			f.write(string.encode('utf-8'))
			f.write('\",@\"'+allStrings[string] +'\")\n')
		except:

			print type(string)
		i+=1
	for line in appStringsFile:
		if '#define' in line:
			 f.write(line)


def FindiDPresetStrings(allStrings,language):
	iDDict = dict()
	for filePath in jsonFilesIn('./presets'):
		name = stringsInJson(filePath)
		if name in allStrings.keys():
			filePath = filePath[:-5][10:]
			iDDict[filePath] = name
	#print pprint(iDDict)
	languageFile = open('./locales/'+language+'.json','r').read()
	data = json.loads(languageFile)
	languageDict = dict()
	if 'presets' not in data.keys():
		return languageDict
	
	
	dictinoary = data.get('presets').get('presets')
	for key in dictinoary.keys():
		if key in iDDict.keys():
			name = dictinoary[key]['name']
			languageDict[iDDict[key]] = name
			#print str(iDDict[key]).encode('utf-8') +' = ' + name.encode('utf-8')
	print 'Total Presets Found ('+language+'): '+str(len(languageDict))
	return languageDict
	
	
def FindiDFieldsStrings(allStrings,language):
	iDDict = dict()
	fields = list()
	for filePath in jsonFilesIn('./fields'):
		name = stringsInJson(filePath)
		fields.append(allFieldsString(filePath))
	
	languageDict = dict()
	
	languageFile = open('./locales/'+language+'.json','r').read()
	data = json.loads(languageFile)
	
	if 'presets' not in data.keys():
		return languageDict
	
	dictinoary = data['presets']['fields']
	
	for data in fields:
		if data['label'] not in 'Type':
			if 'key' in data.keys():
				if data['key'] in dictinoary.keys():
					if dictinoary[data['key']].get('label'):
						languageDict[data['label']] = dictinoary[data['key']]['label']
					#print data['label'] +' = '+ dictinoary[data['key']]['label']
					if 'options' in dictinoary[data['key']].keys():
						options =  dictinoary[data['key']]['options']
						for key in options.keys():
							languageDict[data['strings']['options'][key]] = options[key]
							#print data['strings']['options'][key] +' = '+ options[key]
					
				
	finalDictionary = dict()
	for key in allStrings:
		if key in languageDict.keys():
			finalDictionary[key] = languageDict[key]
	
	print 'Total Fields Found ('+language+'): '+str(len(finalDictionary))
	return finalDictionary
		
	
def stringsInJson(filePath):
	json_data=open(filePath).read()

	data = json.loads(json_data)
	if 'name' in data.keys():
		return data['name']
	else:
		return data['label']
		
def allFieldsString(filePath):
	json_data=open(filePath).read()

	data = json.loads(json_data)
	return data
	print data['label']
	if 'strings' in data.keys() and 'options' in data['strings'].keys():
		for key in  data['strings']['options']:
			if type(data['strings']['options'][key]) is dict:
				print data['strings']['options'][key]['title']
			else:
				print data['strings']['options'][key]
	
	
def jsonFilesIn(folder):
	files = list()
	for dirname, dirnames, filenames in os.walk(folder):
	    # print path to all subdirectories first.
	    # print path to all filenames.
		for filename in filenames:
			path =  os.path.join(dirname, filename)
			if filename.endswith('.json'):
				files.append(path)
	return files
	
def writeLocalizedStrings(stringDictionary,language):
	f = open('./translatedStrings/'+language+'.strings', 'w')
	for enStr in stringDictionary:
		string = '\"'+enStr.encode('utf-8') +'\" = \"'+stringDictionary[enStr].encode('utf-8')+"\";\n"
		f.write(string)
	f.close()
	
	
if __name__ == '__main__':
	
	
	allStrings = loadStrings()
	
	writeToFile(allStrings)
	
	os.system("genstrings ./strings.h -o ./")

