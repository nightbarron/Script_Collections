#@Author: Night Barron
import os

# Custom here
fileName = "myfile.txt"
ipFW = "103.90.227.208"
rateNearBy = 10

# Using readlines()
file = open(fileName, 'r')
lines = file.readlines()
 
countSameLine = 0
oldLine = 'err'
for line in lines:
    if (line != oldLine):
        if (countSameLine >= rateNearBy):
            ip = oldLine.split()[0]
            # Add to block port with time out 4h
            statement = "ipset add BLACKLIST_SrcDstportDst " + ip + ",tcp:443," + ipFW + " timeout 14400"
            os.system(statement)
            print(ip + " had been BLOCKED!!")
        oldLine = line
        countSameLine = 1
    else:
        countSameLine += 1