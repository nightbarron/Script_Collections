# importing the module
import json
from random import randint
from csv import DictWriter

# GLOBAL
numOfWeek = 5
numOfDay  = numOfWeek*7
lv2Mem = list()
lv1Mem = list()

# Xoay ca 1 cho lv1
lv1CA1Routation = 0

# Lay ID lam key => Value: array length = numOfWeek * 7 lam so ngay trong thang (0-6, 7-13, ...)
mapSchedule = dict()
# Count level 1 of one day (List of Dict)
lv1OfDay = list()
# Count level 2 of ond day
lv2OfDay = list()

def random(a, b):
    return randint(a, b)


def loadMem():
    with open('memData.json') as json_file:
        data = json.load(json_file)
        lv2Mem.extend(data["lv2"])
        lv1Mem.extend(data["lv1"])
    return 0

def initDatabase():
    for i in range(numOfDay):
        lv1OfDay.append({"ca2":0, "ca3": 0})
        lv2OfDay.append({"ca2":0, "ca3": 0})

    for mem in lv2Mem:
        mapSchedule[mem["id"]] = list()
        for i in range(numOfDay):
            mapSchedule[mem["id"]].append(0)

    for mem in lv1Mem:
        mapSchedule[mem["id"]] = list()
        for i in range(numOfDay):
            mapSchedule[mem["id"]].append(0)
    return 0

def calSlotPerWeek():
    # BEGIN: Tinh so ca 2, ca 3/w cho mỗi member
    for i in range(len(lv1Mem)):
        lv1Mem[i]['ca2pw'] = lv1Mem[i]['ca2'] // numOfWeek
        lv1Mem[i]['ca3pw'] = lv1Mem[i]['ca3'] // numOfWeek
    for i in range(len(lv2Mem)):
        lv2Mem[i]['ca2pw'] = lv2Mem[i]['ca2'] // numOfWeek
        lv2Mem[i]['ca3pw'] = lv2Mem[i]['ca3'] // numOfWeek
    # END
    return 0

def checkDatabase():
    ca1=0
    ca2=0
    ca3=0
    for mem in lv1Mem:
        ca1 += mem["ca1"]
        ca2 += mem["ca2"]
        ca3 += mem["ca3"]
    for mem in lv2Mem:
        ca1 += mem["ca1"]
        ca2 += mem["ca2"]
        ca3 += mem["ca3"]
    if (ca1 < numOfWeek*7): return False
    if (ca2 < numOfWeek*7*3): return False
    if (ca3 < numOfWeek*7*3): return False
    return True

# soCA is the number of peopleo in ca in week
def createPoolCA1(soCA):
    pool = list()
    for i in range(len(lv2Mem)):
        pool.append(lv2Mem[i]["id"])
        lv2Mem[i]["ca1"] -= 1
    global lv1CA1Routation
    lv1Remain = soCA - len(pool)
    for i in range(lv1Remain):
        isChoosed = False
        while not isChoosed:
            if (lv1CA1Routation >= len(lv1Mem)):
                lv1CA1Routation = 0
            if (lv1Mem[lv1CA1Routation]["ca1"] > 0):
                isChoosed = True
                pool.append(lv1Mem[lv1CA1Routation]["id"])
                lv1Mem[lv1CA1Routation]["ca1"] -= 1
            lv1CA1Routation += 1
        
    return pool

def checkLV1(id):
    for i in range(len(lv1Mem)):
        if lv1Mem[i]["id"] == str(id):
            return i
    return -1

def checkLV2(id):
    for i in range(len(lv2Mem)):
        if lv2Mem[i]["id"] == str(id):
            return i
    return -1

def orderCA1():
    for week in range(numOfWeek):
        # 5 lv1, 2 lv2
        pool = createPoolCA1(7)
        startWeek = 7*week
        for day in range(7):
            today = startWeek + day
            someOne = random(0, len(pool) - 1)
            mapSchedule[pool[someOne]][today] = 1
            if (today != 0):
                # Lam ca 3 truoc ca 1
                mapSchedule[pool[someOne]][today - 1] = 3
                lv1Index = checkLV1(pool[someOne])
                lv2Index = checkLV2(pool[someOne])
                if (lv1Index >= 0):
                    lv1Mem[lv1Index]["ca3"] -= 1
                else:
                    lv2Mem[lv2Index]["ca3"] -= 1
            # Da truc nen xoa khoi pool
            pool.pop(someOne)

        if (len(pool) > 0):
            print("Pool week", str(int(week + 1)), " have some extra slot ca1:", pool, "\n")
    return 0

# PoolCA2 extra
extraPoolLv2 = list()
def orderCA2LV2pw(startWeek):
    # Per week
    # Create pool members
    pool = list()
    for i in range(len(lv2Mem)):
        for j in range(lv2Mem[i]['ca2pw']):
            pool.append(lv2Mem[i]["id"])
    # END pool
    for i in range(7):
        today = startWeek + i
        # Find someone off today
        someOne = random(0, len(pool) - 1)
        while mapSchedule[pool[someOne]][today] != 0:
            someOne = random(0, len(pool) - 1)
        # Gan ca 2
        lv2Index = checkLV2(pool[someOne])
        mapSchedule[pool[someOne]][today] = 2
        lv2Mem[lv2Index]["ca2"] -= 1
        # Bo someone ra khoi pool
        pool.pop(someOne)
    
    # Don phan du de chia lai cho lv1
    global extraPoolLv2
    extraPoolLv2.clear()
    extraPoolLv2.extend(pool)
    return 0

# LV1 + LV2 extra above
def orderCA2LV1pw(startWeek):
    # Per week
    # Create pool members
    pool = list()
    for i in range(len(lv1Mem)):
        for j in range(lv1Mem[i]['ca2pw']):
            pool.append(lv1Mem[i]["id"])
    pool.extend(extraPoolLv2)
    # END pool

    for i in range(7):
        today = startWeek + i
        # Chon 2 mem
        for j in range(2):
            # Find someone off today
            someOne = random(0, len(pool) - 1)
            while mapSchedule[pool[someOne]][today] != 0:
                someOne = random(0, len(pool) - 1)
            # Gan ca 2
            mapSchedule[pool[someOne]][today] = 2
            lv1Index = checkLV1(pool[someOne])
            lv2Index = checkLV2(pool[someOne])
            if (lv1Index >= 0):
                lv1Mem[lv1Index]["ca2"] -= 1
            else:
                lv2Mem[lv2Index]["ca2"] -= 1
            # Bo someone ra khoi pool
            pool.pop(someOne)
    
    # Xu ly slot du nhu sau:
    # + Don qua ca 3 (chua dung)
    # + Rai lại cho đều (đang dùng)
    for idMem in pool:
        # Can toi uu random
        randomDay = random(startWeek, startWeek + 6)
        while mapSchedule[idMem][randomDay] != 0:
            randomDay = random(startWeek, startWeek + 6)
        # Gan ca 2
        mapSchedule[idMem][randomDay] = 2
        lv1Index = checkLV1(idMem)
        lv2Index = checkLV2(idMem)
        if (lv1Index >= 0):
            lv1Mem[lv1Index]["ca2"] -= 1
        else:
            lv2Mem[lv2Index]["ca2"] -= 1
        # Bo someone ra khoi pool
        # pool.pop(someOne) -> Auto bo do scan pool

    return 0

# PoolCA3 extra
extraPoolLv3 = list()
def orderCA3LV2pw(startWeek):
    # Create pool again
    pool = list()
    for i in range(len(lv2Mem)):
        # Count ca 3 of mem in week
        countCA3ofMEM = 0
        for count in range(7):
            if (mapSchedule[lv2Mem[i]['id']][startWeek + count] == 3):
                countCA3ofMEM += 1
        # Cho phan con lai vao Pool
        if (lv2Mem[i]['ca3pw'] > countCA3ofMEM):
            for j in range(lv2Mem[i]['ca3pw'] - countCA3ofMEM):
                pool.append(lv2Mem[i]["id"])
    # END pool
    # ERROR SPACE
    # result()
    for i in range(7):
        today = startWeek + i
        # Nếu ngày hôm nay có ca 3 lv2 thì bỏ qua today
        IsLV2CA3 = False
        for mem in lv2Mem:
            if (mapSchedule[mem['id']][today] == 3):
                IsLV2CA3 = True
                break
        if IsLV2CA3: continue
        
        # Find someone off today
        someOne = random(0, len(pool) - 1)
        while mapSchedule[pool[someOne]][today] != 0:
            someOne = random(0, len(pool) - 1)
        # Gan ca 3
        lv2Index = checkLV2(pool[someOne])
        mapSchedule[pool[someOne]][today] = 3
        lv2Mem[lv2Index]["ca3"] -= 1
        # Bo someone ra khoi pool
        pool.pop(someOne)
    # Don phan du de chia lai cho lv1
    global extraPoolLv3
    extraPoolLv3.clear()
    extraPoolLv3.extend(pool)
    return 0

def orderCA3LV1pw(startWeek):
    # Create final POOL
    pool = list()
    for i in range(len(lv1Mem)):
        # Count ca 3 lv1 of mem in week
        countCA3ofMEM = 0
        for count in range(7):
            if (mapSchedule[lv1Mem[i]['id']][startWeek + count] == 3):
                countCA3ofMEM += 1
        # Cho phan con lai vao Pool
        if (lv1Mem[i]['ca3pw'] > countCA3ofMEM):
            for j in range(lv1Mem[i]['ca3pw'] - countCA3ofMEM):
                pool.append(lv1Mem[i]["id"])
    pool.extend(extraPoolLv3)
    # END Pool
    # print("CA3LV1", startWeek//7 + 1)
    # result()
    for i in range(7):
        today = startWeek + i

        # Count Ca 3 lv1 ngay hom nay
        numLV1CA3 = 0
        for mem in lv1Mem:
            if (mapSchedule[mem['id']][today] == 3):
                    numLV1CA3 += 1
        # Chon (2 - numLV1CA3) mem
        if (numLV1CA3 < 2):
            for j in range(2 - numLV1CA3):
                # Find someone off today
                someOne = random(0, len(pool) - 1)
                while mapSchedule[pool[someOne]][today] != 0:
                    someOne = random(0, len(pool) - 1)
                # Gan ca 2
                mapSchedule[pool[someOne]][today] = 3
                lv1Index = checkLV1(pool[someOne])
                lv2Index = checkLV2(pool[someOne])
                if (lv1Index >= 0):
                    lv1Mem[lv1Index]["ca3"] -= 1
                else:
                    lv2Mem[lv2Index]["ca3"] -= 1
                # Bo someone ra khoi pool
                pool.pop(someOne)

    # Xu ly slot tồn
    for idMem in pool:
        # Can toi uu random
        randomDay = random(startWeek, startWeek + 6)
        while mapSchedule[idMem][randomDay] != 0:
            randomDay = random(startWeek, startWeek + 6)
        # Gan ca 3
        mapSchedule[idMem][randomDay] = 3
        lv1Index = checkLV1(idMem)
        lv2Index = checkLV2(idMem)
        if (lv1Index >= 0):
            lv1Mem[lv1Index]["ca3"] -= 1
        else:
            lv2Mem[lv2Index]["ca3"] -= 1
        # Bo someone ra khoi pool
        # pool.pop(someOne) -> Auto bo do scan pool

    return 0

# Using panda to export excel
def result():
    # Result
    print("Result: ")
    for key in mapSchedule:
        print(key, ":", mapSchedule.get(key))

    # Export to file txt
    # f = open("schedule.txt", "w")
    # for key in mapSchedule:
    #     lv1Index = checkLV1(key)
    #     lv2Index = checkLV2(key)
    #     resultLine = ""
    #     if (lv1Index >= 0):
    #         name = lv1Mem[lv1Index]['name']
    #     else:
    #         lv2Mem[lv2Index]["ca3"] -= 1
    # f.close()

    # Export to csv
    with open('schedule.csv','w') as outfile:
        headers = list()
        headers.append("Name")
        for i in range(7*numOfWeek):
            headers.append(str(i))
        writer = DictWriter(outfile, headers)
        writer.writeheader()
        for key in mapSchedule:
            lv1Index = checkLV1(key)
            lv2Index = checkLV2(key)
            row = dict()
            print(key, lv1Index, lv2Index)
            if (lv1Index >= 0):
                name = lv1Mem[lv1Index]['name']
            else:
                name = lv2Mem[lv2Index]['name']
            row["Name"] = name
            dayCount = 0
            for ca in mapSchedule[key]:
                if (ca == 0):
                    row[str(dayCount)] = "Off"
                else: 
                    row[str(dayCount)] = str("CA " + str(ca))
                dayCount += 1
            writer.writerow(row)
    return 0


def main():
    loadMem()
    initDatabase()
    if not checkDatabase():
        print("Not enough slot")
        exit()
    calSlotPerWeek()
    # CA 1 Per month
    orderCA1()

    # Ca 2 Per week
    for week in range(numOfWeek):
        orderCA2LV2pw(7*week)
        orderCA2LV1pw(7*week)

    # Ca 3 Per week
    for week in range(numOfWeek):
        orderCA3LV2pw(7*week)
        orderCA3LV1pw(7*week)

    result()

main()


