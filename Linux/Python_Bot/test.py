import os, logging, json
from datetime import date,datetime

def bank():
    id = "BK116149"
    filePath = "./LIB_botTelegram/db.json"
    f = open(filePath, )
    userData = json.load(f)

    total = 0
    resultBill="Checking profit for " + userData[id][0].get('name') + " :\n==========\n"
    for bill in userData[id]:
        cost = bill.get('cost')
        print("\n2")
        date_format = "%d/%m/%Y"
        startDate = datetime.strptime(bill.get('date'), date_format)
        now = datetime.today()
        numDates = now - startDate
        numDate = numDates.days
        pay = bill.get('pay')
        currency = "{:,.2f} VND".format(cost*1000)
        profit = "{:,.2f} VND".format(cost*1000*numDate*pay/365)
        resultBill += " + Capital: " + currency + "\n + Start Date: " + startDate.strftime(date_format) + "\n + Days: " + str(numDate) + "\n + IR: " + str(pay*100 )+ "%\n + Profit: " + profit + "\n----------\n"
        total += cost*1000*(numDate*pay/365 + 1)

    resultBill += " * Total: " + "{:,.2f} VND".format(total)
    print(resultBill)

bank()