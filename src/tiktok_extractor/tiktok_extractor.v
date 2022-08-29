module tiktok_extractor

import net.http
import x.json2

// Return: Video Title, Video URL, Thumbnail URL
pub fn get_video_info(str_tag string, str_url string, is_shortened bool) ?(string, string, string) {
	mut str_base_url := str_url

	if is_shortened { // Shortened URL check
		res := http.Request{
			url: str_base_url
			method: http.Method.get
			allow_redirect: false
		}.do()?

		str_base_url = res.header.get_custom('Location')?
	}

	str_tokens := str_base_url.split('/')
	str_username := str_tokens[3]
	str_id := str_tokens[5].split('?')[0]

	str_json_url := 'https://www.tiktok.com/node/share/video/$str_username/$str_id'

	println('$str_tag Got JSON data URL -> $str_json_url')

	println('$str_tag Getting raw video URL, title and thumbnail')

	res := http.get(str_json_url)?
	str_raw_json := res.body

	video_json := json2.raw_decode(str_raw_json)?
	video_map := video_json.as_map()

	str_video_url := video_map['itemInfo']?.as_map()['itemStruct']?.as_map()['video']?.as_map()['downloadAddr']?.str()
	str_title := video_map['seoProps']?.as_map()['metaParams']?.as_map()['title']?.str()
	str_thumb_url := video_map['itemInfo']?.as_map()['itemStruct']?.as_map()['video']?.as_map()['reflowCover']?.str()

	return str_title, str_video_url, str_thumb_url
}
