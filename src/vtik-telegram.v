import dariotarantini.vgram
import vtik
import os
import flag

fn main(){
	str_token := os.getenv_opt("TELEGRAM_TOKEN") or {
		eprintln("[VTik] Error: $err")
		println("Couldn't find Telegram Bot Token in env")
		return
	}

	bot := vgram.new_bot(str_token)
	mut updates := []vgram.Update{}
	mut last_offset := 0
	mut vt := vtik.new()

	for{
		updates = bot.get_updates(offset: last_offset, limit: 100)
		for update in updates {
			if last_offset < update.update_id{
				last_offset = update.update_id
				if update.message.text == "/start"{
					bot.send_chat_action(
						chat_id: update.message.from.id.str()
						action: "typing"
					)

					bot.send_message(
						chat_id: update.message.from.id.str()
						text: 'Hello! Send a TikTok link and I will give you its download link!'
					)
				}

				if vtik.check_url(update.message.text)? != 'invalid'{
						bot.send_chat_action(
							chat_id: update.message.from.id.str()
							action: "typing"
						)

						vt.set_base_url(update.message.text)?

						bot.send_message(
							chat_id: update.message.from.id.str()
							text: "Your video is ready!\nTitle: [${vt.get_video_title()}]\n${vt.get_video_url()}"
						)
				}
				else{
						bot.send_chat_action(
							chat_id: update.message.from.id.str()
							action: "typing"
						)

						bot.send_message(
							chat_id: update.message.from.id.str()
							text: "The link that you've sent is invalid."
						)
				}
			}
		}
	}
}