from plistlib import *

if __name__ == '__main__':
	allStrings = ()
	tags = readPlist('Tags.plist')

	allStrings = tags.keys()

	for key in tags.keys():
		allStrings = allStrings + tags[key].keys()

	optional = readPlist('Optional.plist')

	for key in optional.keys():
		allStrings.append(optional[key]['displayName'])
		values = optional[key]['values']
		if type(values) is not str:
			for key in values.keys():
				allStrings.append(key)

	print set(allStrings)

