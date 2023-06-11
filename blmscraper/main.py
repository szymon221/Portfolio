import requests
from bs4 import BeautifulSoup as soup
import os
import shutil
import table
import sqlite3

DLOCATION = "./Data/"

def Cleanup():
    try:
        shutil.rmtree(DLOCATION)
    except:
        pass
    os.mkdir(DLOCATION)

def setoptions():
    with open("options.txt") as f:
        temp = f.read().replace("\n","").replace('"','')
        return temp.split(",")

Cleanup()

textoptions = setoptions()

def main():
        for t,r in GetNext():
            Folder = t+r
            try:
                os.mkdir(DLOCATION+Folder)
            except FileExistsError:
                continue
            htmlTable = downloadTable(t,r)
            print(htmlTable)
            table.SaveTable(htmlTable,Folder)
            #DownloadFiles(htmlTable,Folder)

def DownloadFiles(htmlTable,Folder):
    print(f"Downloading {Folder}")
    for link in htmlTable.find_all('a', href=True):
        with open(DLOCATION+Folder+"./"+link.text,"wb") as f:
            r= requests.get(f"https://www.blm.gov{link['href']}")
            f.write(r.content)

def downloadTable(township,range):
    myobj = {'T': township,'R':range}
    r = requests.post("https://www.blm.gov/or/landrecords/result.php",data = myobj)
    s = soup(r.text,'html5lib')
    table = s.find("div", {"id": "main-small"})
    return table


def GetNext():
    t,r = "",""
    for x in textoptions:
        if("*" in x ):
            t,r = x.split("*")
            continue
        yield (t,x)

if __name__ == "__main__":
    main()
