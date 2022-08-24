module twitter_extractor

import net.http
import x.json2
import os

// Return: Video Title, Video URL, Thumbnail URL
// You'll need to supply your own bearer token for twitter for obvious reasons too
pub fn get_video_info(str_tag string, str_url string) ?(string, string, string){
	str_tokens := str_url.split_any('/?')
	mut str_id := str_tokens[5]

	bearer_token := os.getenv_opt("TWITTER_BEARER_TOKEN")?

	request_url := "https://api.twitter.com/1.1/statuses/show.json?id=${str_id}"

	println('${str_tag} getting JSON metadata for video $str_url')

	hdr := http.new_header(key: http.CommonHeader.authorization, value: "Bearer ${bearer_token}")

	req := http.Request{
		method: http.Method.get
		header: hdr
		url: request_url
	}

	res := req.do()?

	json := json2.raw_decode(res.body)?
	json_map := json.as_map()

	println('${str_tag} getting title, video and thumbnail URLs')

	if json_map['is_quote_status'].bool() == true {
		return error("Cannot download quoted videos yet.")
	}

	str_title := str_id
	str_vid_map_arr := json_map['extended_entities']?.as_map()['media']?.arr()[0]?.as_map()['video_info']?.as_map()['variants']?.arr()

	mut str_video_url := ""
	mut bitrate := 0

	for raw_map in str_vid_map_arr {
		map_variant := raw_map.as_map()
		str_content_type := map_variant['content_type']?.str()

		if str_content_type == 'video/mp4' {
			local_bitrate := map_variant['bitrate']?.int()

			if  local_bitrate > bitrate{
				bitrate = local_bitrate
				str_video_url = map_variant['url']?.str()
			}
		}
	}
	
	str_thumb_url := json_map['entities']?.as_map()['media']?.arr()[0]?.as_map()['media_url']?.str()
	
	return str_title, str_video_url, str_thumb_url
}