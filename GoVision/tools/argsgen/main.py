import sys
import os
import shutil
from datetime import datetime
import getpass




ConfgiDict = {}
with open(f"{os.path.dirname(__file__)}\\..\\runConfig\\config.cfg") as f:
	for line in f:
		key,value = line.split(";")

		value = value.strip()
		ConfgiDict[key] = value.replace("\"","")


PROFILES = ConfgiDict["PROFILES"]
ACCKEY = ConfgiDict["ACCKEY"]
AUTH = ConfgiDict["AUTH"]

def CreateDic(array):
	tempdic = {}
	for arg in array:
		if ";" not in arg:
			print(f"Malformed argument: {arg}")
			exit(1)
		key,val = arg.split(";")
		key = key.strip()
		val = val.strip()
		val = val.replace('"',"")
		key = key.replace('"',"")

		tempdic[key] = val
	return tempdic

if len(sys.argv) <= 1:
	print("No Arguments supplied")
	exit(1)

Arguments = {}
FileCopy = {}

buffer = []
#Reads in config


if(not os.path.exists(f"{PROFILES}/{sys.argv[1]}/mapping.txt")):
	print(f"Profile {sys.argv[1]} not found")
	exit(1)

with open(f"{PROFILES}/{sys.argv[1]}/mapping.txt","r") as f:
	buffer = f.read().split("\n")

#Removes empty lines and comments
buffer = [line for line in buffer if not line.strip() == ""]
buffer = [line for line in buffer if not line[0] == "#"]

#Checks if the file is not empty
if(len(buffer) == 0):
	print("File is empty")
	exit(0)

#Checks if server files have been defined
try:
	if(buffer.index("Files:") +1 >= len(buffer)):
		print("No files supplied")
		exit(1)
except ValueError as e:
	print("No files specified")
	exit(1)

#Splits settings and file list
files = buffer[buffer.index("Files:") +1:]
buffer = buffer[:buffer.index("Files:")]

#Creates dic for arguments and files
Arguments = CreateDic(buffer)
FileCopy = CreateDic(files)

if not "GameType" in Arguments:
	print("GameType not supplied")
	exit(1)

if not "Map" in Arguments or not ("Collection" in Arguments or "Map" in Arguments):
	print("Map not supplied")
	exit(1)

if not "Tick" in Arguments:
	print("Tickrate not set")
	exit(1)

#removes and copys new files to server directory
for key in FileCopy:
	try:
		os.remove(FileCopy[key])
	except OSError as e:
		pass
	try:
		shutil.copyfile(f"{PROFILES}/{sys.argv[1]}/{key}",FileCopy[key])
	except OSError as e:
		pass

#Creates launch paramaters and prints to console

gametypes = {
	"Casual":"+game_type 0 +game_mode 0",
	"Competitive":"+game_type 0 +game_mode 1",
	"Wingman":"+game_type 1 +game_mode 2",
	"Custom":"+game_type 3 +game_mode 0"
}

output = Arguments["Arguments"]

#Gametype
output = f"{output} {gametypes[Arguments['GameType']]}"
#Tickrate
output = f"{output} -tickrate {Arguments['Tick']}"
#Map
if ("Collection" in Arguments):
	output = f"{output} +workshop_start_map {Arguments['Map']} +host_workshop_collection {Arguments['Collection']}"
else:
	output = f"{output} +map {Arguments['Map']}"

if "UseEnvKeys" in Arguments:
	if Arguments["UseEnvKeys"] == "True":
		output = f"{output} -authkey {AUTH} +sv_setsteamaccount {ACCKEY}"


print(output, end="")

