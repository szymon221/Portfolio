DLOCATION = "./Data/"

#Table malarky
def SaveTable(Table,Folder):
    with open(DLOCATION+Folder+"./table.txt","w") as f:
        f.write(serializetable(Table))

def serializetable(table):
    rows = TurnTableToRows(table)
    #Works out the longest item in the table
    offset = Calculateoffset(rows)
    table = SerializeRows(rows,offset)
    return table

def TurnTableToRows(table):
    rows = []
    rows.append(GetHeaders(table))
    GetRows(rows, table.select('td'))
    print(rows)
    return rows

def GetHeaders(table):
    headers = []
    for tblheaders in table.select('tr')[0]:
        headers.append(tblheaders.text)
    return headers


def SerializeRows(rows,offset):
    output = ""

    for row in rows:
        for item in row:
            output+= item + ((offset- len(item)) *" ")
        output += "\n"
    return output

def GetRows(rows, htmlrows):
    coltext = []
    cnt = 0
    for col in htmlrows:
        coltext.append(col.text)
        cnt +=1
        if(cnt% len(rows[0]) == 0):
            rows.append(coltext)
            coltext = []
            cnt = 0
    return rows

def Calculateoffset(rows):
    max = 0
    for row in rows:
        for item in row:
            if(len(item)> max):
                max = len(item)
    return max+1
