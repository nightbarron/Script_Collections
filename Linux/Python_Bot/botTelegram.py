#!/bin/python3

# Require: yum install bind-utils jq (dig command)
# Require: python -m pip install paramiko


from telegram import ReplyKeyboardMarkup, ReplyKeyboardRemove, Update, ParseMode
from telegram.ext import (
    Updater,
    CommandHandler,
    MessageHandler,
    Filters,
    ConversationHandler,
    CallbackContext,
)
import os, logging, json
from datetime import date,datetime

from LIB_botTelegram import aaPanel

#Global Variables
gensslStep = 0
DOMAIN, COMPANY, CITY, EMAIL = range(4)
domainG=""
companyG=""
cityG=""
emailG=""


# Enable logging
logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
                    level=logging.INFO)
logger = logging.getLogger(__name__)

def check(update, context):
    chat_id = update.message.chat_id
    statement = "sh LIB_botTelegram/check.sh " + str(chat_id)
    os.system(statement)

def ssl(update, context):
    domain = str(" ".join(str(update.message.text).strip().split())).split()[1]
    #print("Message: ", " ".join(str(update.message.text).strip().split()))
    chat_id = update.message.chat_id
    statement = "sh LIB_botTelegram/ssl.sh " + str(chat_id) + " " + str(domain)
    os.system(statement)
    #update.message.reply_text("This is the SSL")

# CONVERSATION

def genssl(update: Update, context: CallbackContext) -> int:
    #Starts the conversation and ask for domain
    update.message.reply_text(
        'Welcome to <b>IT CHICKEN BOT</b>, I will GEN new CSR, KEY for your domain!'
        '\nSend /cancel to stop talking to me.\n\n'
        'What is your domain?',parse_mode=ParseMode.HTML
        # reply_markup=ReplyKeyboardMarkup(
        #     one_time_keyboard=True, input_field_placeholder='What is your domain?'
        # ),
    )

    return DOMAIN

def domain(update: Update, context: CallbackContext) -> int:
    #Get domain and ask for company
    global domainG
    domainG = update.message.text
    update.message.reply_text(
        '<b>Your domain:</b> ' + domainG + ''
        '\nSend /cancel to stop talking to me.\n\n'
        'What is your company?',parse_mode=ParseMode.HTML
        # reply_markup=ReplyKeyboardMarkup(
        #     one_time_keyboard=True,input_field_placeholder='What is your company?'
        # ),
    )

    return COMPANY

def company(update: Update, context: CallbackContext) -> int:
    #Get company and ask for city
    global companyG
    companyG = update.message.text
    update.message.reply_text(
        '<b>Your company:</b> ' + companyG + ''
        '\nSend /cancel to stop talking to me.\n\n'
        'What is your city?',parse_mode=ParseMode.HTML
        # reply_markup=ReplyKeyboardMarkup(
        #     one_time_keyboard=True, input_field_placeholder='What is your city?'
        # ),
    )

    return CITY

def city(update: Update, context: CallbackContext) -> int:
    #Get city and ask for email
    global cityG
    cityG = update.message.text
    update.message.reply_text(
        '<b>Your city:</b> ' + cityG + ''
        '\nSend /cancel to stop talking to me.\n\n'
        'What is your email?',parse_mode=ParseMode.HTML
        # reply_markup=ReplyKeyboardMarkup(
        #     one_time_keyboard=True, input_field_placeholder='What is your email?'
        # ),
    )

    return EMAIL

def email(update: Update, context: CallbackContext) -> int:
    #Get email and send csr, key
    global emailG
    emailG = update.message.text
    update.message.reply_text(
        '<b>Your email:</b> ' + emailG + ''
        '\nSend /cancel to stop talking to me.\n\n'
        'Your CSR, KEY will be here now!',parse_mode=ParseMode.HTML
    )
    genkey(update, context)
    return ConversationHandler.END

def genkey(update: Update, context: CallbackContext) -> int:
    #Gen and send key
    # context.bot.send_message(text=
    #     '<b>Your domain:</b>   ' + domainG + ''
    #     '\n<b>Your comany:</b>   ' + companyG + ''
    #     '\n<b>Your city:</b>     ' + cityG + ''
    #     '\n<b>your email:</b>    ' + emailG + '', chat_id=update.message.chat_id, parse_mode=ParseMode.HTML
    # )
    try: 
        chat_id = update.message.chat_id
        statement = "sh LIB_botTelegram/genSSL.sh " + str(chat_id) + " \"" + str(domainG) + "\" \"" + str(companyG) + "\" \"" + str(cityG) + "\" \"" + str(emailG) + "\""
        os.system(statement)
    except: 
        context.bot.send_message(text="⚠️ Can't Create CSR, KEY for " + domainG + " ⚠️", chat_id=update.message.chat_id, parse_mode=ParseMode.HTML)
        return ConversationHandler.END


def cancel(update: Update, context: CallbackContext) -> int:
    #Cancels and ends the conversation.
    user = update.message.from_user
    logger.info("User %s canceled the conversation.", user.first_name)
    global domainG
    global companyG
    global cityG
    global emailG
    # RESET VARIABLES
    domainG=""
    companyG=""
    cityG=""
    emailG=""

    update.message.reply_text(
        'Creating SSL KEY PAIR task has cancelled!', reply_markup=ReplyKeyboardRemove()
    )

    return ConversationHandler.END

# END CONVERSATION

def error(update, context):
    """Log Errors caused by Updates."""
    logger.warning('Update "%s" caused error "%s"', update, context.error)

def echo(update, context):
    #update.message.reply_text(update.message.text)
    return 0

def bank(update, context):
    id = str(update.message.text).split(" ")[1]
    filePath = "./LIB_botTelegram/db.json"
    if ( not os.path.isfile(filePath)):
        update.message.reply_text("Bank ID invalid!!")
    f = open(filePath, )
    userData = json.load(f)
    f.close()
    if (userData.get(id, -1) == -1):
        update.message.reply_text("Bank ID invalid!!")

    total = 0
    resultBill="🏛 Checking profit for " + userData[id][0].get('name') + " 🏛\n==========\n"
    for bill in userData[id]:
        cost = bill.get('cost')
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
    update.message.reply_text(resultBill)

def dm(update, context):
    domain = str(" ".join(str(update.message.text).strip().split())).split()[1]
    #domain = domain.strip()
    chat_id = update.message.chat_id
    statement = "sh LIB_botTelegram/checkDomain.sh " + str(chat_id) + " " + str(domain) + " " + "O"
    os.system(statement)
    #update.message.reply_text("This is the SSL")
    return 0

def curl(update, context):
    url = str(" ".join(str(update.message.text).strip().split())).split()[1]
    chat_id = update.message.chat_id
    statement = "sh LIB_botTelegram/curl.sh " + str(chat_id) + " " + str(url)
    os.system(statement)
    #update.message.reply_text("This is the SSL")
    return 0

def dmrecord(update, context):
    domain = str(" ".join(str(update.message.text).strip().split())).split()[1]
    chat_id = update.message.chat_id
    statement = "sh LIB_botTelegram/checkDomain.sh " + str(chat_id) + " " + str(domain) + " " + "F"
    os.system(statement)
    #update.message.reply_text("This is the SSL")
    return 0

def passWord(update, context):
    try:
        length = str(update.message.text).split(" ")[1]
        if (int(length) <= 0 or int(length) >= 500):
            update.message.reply_text("Getshit DONE!!!")
            return 0
    except:
        length = 0
    chat_id = update.message.chat_id
    statement = "sh LIB_botTelegram/randomPass.sh " + str(chat_id) + " " + str(length)
    os.system(statement)
    return 0


def ping(update, context):
    ip_check = str(" ".join(str(update.message.text).strip().split())).split()[1]
    try:
        options = str(" ".join(str(update.message.text).strip().split())).split()[2]
    except:
        options = "L"
    if (len(str(options)) <= 0): options = "L"
    #print("Options: ", options)
    options = options.strip()
    chat_id = update.message.chat_id
    statement = "sh LIB_botTelegram/checkIP.sh " + str(chat_id) + " " + str(ip_check) + " " + str(options).upper()
    os.system(statement)
    return 0


def tag(update, context):
    mode = str(" ".join(str(update.message.text).strip().split())).split()[1]
    listUser = {'Nam Lưu': 1076498380, 'Tuấn Đặng': 1753149166, 'Huy Ngô': 1458296682, 'Hải Anh': 1740013393, 'Đạt Trần': 2138787778, 'Hoà Lê': 1800256365, 'Thanh Hoàng': 5567151417, 'Doãn Anh': 1211523861}
    result = ''
    if len(mode) <= 0: mode = 'err'
    if mode == 'all':
        for user in listUser:
            #print(listUser[user])
            result += "["+ user +"](tg://user?id="+str(listUser[user])+"), "
        #user = "[Tuan Dang](tg://user?id="+str(id)+")"

        update.message.reply_text(result, parse_mode='markdown')
    else:
        update.message.reply_text('Wrong command!', parse_mode='markdown')
    return 0

def id(update, context):
    first_name = update.message.from_user.first_name
    id = update.message.from_user.id
    last_name = update.message.from_user.last_name
    username = update.message.from_user.username
    result = (
        f"Hello @{username}! Welcome to IT Chicken Bot\n"
        f"Your ID: {id}\n"
        f"Your name: {first_name} {last_name}"
    )
    update.message.reply_text(result)
    return 0

def roomid(update, context):
    id = update.message.chat.id
    name = update.message.chat.title
    result = (
        f"Hello @! Welcome to IT Chicken Bot\n"
        f"Room ID: {id}\n"
        f"Room name: {name}"
    )
    update.message.reply_text(result)
    return 0

def main():
    updater = Updater('1741302312:AAHUJEV2WsKzCu8wBF6Uq9zwBPL7F724wYo', use_context=True)
    dp = updater.dispatcher
    dp.add_handler(CommandHandler('check',check))
    dp.add_handler(CommandHandler('ssl', ssl))

    # Domain check
    dp.add_handler(CommandHandler('dm', dm))
    dp.add_handler(CommandHandler('dmrecord', dmrecord))

    # Curl
    dp.add_handler(CommandHandler('curl', curl))

    #bank
    dp.add_handler(CommandHandler('bank', bank))

    #pass
    dp.add_handler(CommandHandler('pass', passWord))

    #tag
    dp.add_handler(CommandHandler('tag', tag))

    #id
    dp.add_handler(CommandHandler('id', id))

    #roomid
    dp.add_handler(CommandHandler('roomid', roomid))

    #check International
    dp.add_handler(CommandHandler('ping', ping))

    # Add conversation handler for create SSL
    genssl_conv_handler = ConversationHandler(
        entry_points=[CommandHandler('genssl', genssl)],
        states={
            DOMAIN: [MessageHandler(Filters.text & ~Filters.command, domain)],
            COMPANY: [MessageHandler(Filters.text & ~Filters.command, company)],
            CITY: [MessageHandler(Filters.text & ~Filters.command, city)],
            EMAIL: [MessageHandler(Filters.text & ~Filters.command, email)],
        },
        fallbacks=[CommandHandler('cancel', cancel)],
    )
    dp.add_handler(genssl_conv_handler)

     # on noncommand i.e message - echo the message on Telegram
    dp.add_handler(MessageHandler(Filters.text, echo))

    # log all errors
    dp.add_error_handler(error)
    updater.start_polling()
    updater.idle()

main()