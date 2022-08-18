import v.util
import dariotarantini.vgram

import vtik
fn main(){
	str_token := util.read_file(".token")? //You'll have to provide your own telegram token for obvious reasons
	bot := vgram.new_bot(str_token)
	mut updates := []vgram.Update{}
	mut last_offset := 0

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

				if update.message.text.contains("tiktok"){
					bot.send_chat_action(
						chat_id: update.message.from.id.str()
						action: "typing"
					)

					vt := vtik.new(update.message.text) or {
						bot.send_message(
							chat_id: update.message.from.id.str()
							text: "Error: $err"
						)
						return
					}

					str_link := vt.get_video_url()
					bot.send_message(
						chat_id: update.message.from.id.str()
						text: "Your download link for $vt.get_video_title() is ready!\n$str_link"
					)
				}
			}
		}
	}
}