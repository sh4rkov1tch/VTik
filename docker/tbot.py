import os

import telegram as t
import telegram.ext as te

import requests as r

async def reply_with_video(update: t.Update, context) -> None :
    link = await update.message.text
    vid = r.get(f'http://localhost:8081/get_video?link={link}').content

    await update.message.reply_video(vid)

def main():
    try:
        telegram_token = os.getenv('TELEGRAM_TOKEN')
    except:
        raise ValueError('Token Empty')
    
    app = te.ApplicationBuilder().token(telegram_token).build()

    app.add_handler(te.Handler(reply_with_video))
    
    
if __name__ == '__main__':
    main()