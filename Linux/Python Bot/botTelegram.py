from telegram.ext import Updater, CommandHandler, MessageHandler
import os, logging

# Enable logging
logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
                    level=logging.INFO)
logger = logging.getLogger(__name__)

def check(update, context):
    chat_id = update.message.chat_id
    statement = "sh LIB_botTelegram/check.sh " + str(chat_id)
    os.system(statement)

def ssl(update, context):
    domain = str(update.message.text).split(" ")[1]
    chat_id = update.message.chat_id
    statement = "sh LIB_botTelegram/ssl.sh " + str(chat_id) + " " + str(domain)
    os.system(statement)
    #update.message.reply_text("This is the SSL")

def genssl(update, context):
    

def error(update, context):
    """Log Errors caused by Updates."""
    logger.warning('Update "%s" caused error "%s"', update, context.error)

def echo(update, context):
    #update.message.reply_text(update.message.text)
    update.message.reply_text("Sorry, I don't understand your messages!")

def main():
    updater = Updater('<token>', use_context=True)
    dp = updater.dispatcher
    dp.add_handler(CommandHandler('check',check))
    dp.add_handler(CommandHandler('ssl', ssl))
    dp.add_handler(CommandHandler('genssl', genssl))

     # on noncommand i.e message - echo the message on Telegram
    dp.add_handler(MessageHandler(Filters.text, echo))

    # log all errors
    dp.add_error_handler(error)
    updater.start_polling()
    updater.idle()

main()