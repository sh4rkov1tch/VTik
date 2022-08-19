import v.util
import dariotarantini.vgram
import vtik
fn main(){
	str_token := util.read_file(".token") or { //You'll have to provide your own telegram token for obvious reasons
		eprintln("[VTik-Telegram] Error: Token file not found.")
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

				if vtik.is_url_valid(update.message.text){
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
			}
		}
	}
}