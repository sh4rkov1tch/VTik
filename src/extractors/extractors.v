module extractors

import net.http
import x.json2
import os

// Return: Video Title, Video URL, Thumbnail URL

pub fn tiktok(str_tag string, str_url string, is_shortened bool) ?(string, string, string) {
	mut str_base_url := str_url

	if is_shortened == true { // Shortened URL check
		req := http.Request{
			url: str_base_url
			method: http.Method.get
			allow_redirect: false
		}

		res := req.do()?

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

pub fn twitter(str_tag string, str_url string) ?(string, string, string) {
	str_tokens := str_url.split_any('/?')
	mut str_id := str_tokens[5]

	bearer_token := os.getenv_opt('TWITTER_BEARER_TOKEN')?

	request_url := 'https://api.twitter.com/1.1/statuses/show.json?include_entities=true&id=$str_id'

	println('$str_tag getting JSON metadata for video $str_url')

	hdr := http.new_header(key: http.CommonHeader.authorization, value: 'Bearer $bearer_token')

	req := http.Request{
		method: http.Method.get
		header: hdr
		url: request_url
	}

	res := req.do()?

	json := json2.raw_decode(res.body)?
	json_map := json.as_map()

	println('$str_tag getting title, video and thumbnail URLs')

	str_title := str_id
	str_vid_map_arr := json_map['extended_entities']?.as_map()['media']?.arr()[0]?.as_map()['video_info']?.as_map()['variants']?.arr()

	mut str_video_url := ''
	mut bitrate := 0

	for raw_map in str_vid_map_arr {
		map_variant := raw_map.as_map()
		str_content_type := map_variant['content_type']?.str()

		if str_content_type == 'video/mp4' {
			local_bitrate := map_variant['bitrate']?.int()

			if local_bitrate > bitrate {
				bitrate = local_bitrate
				str_video_url = map_variant['url']?.str()
			}
		}
	}

	str_thumb_url := json_map['entities']?.as_map()['media']?.arr()[0]?.as_map()['media_url']?.str()

	return str_title, str_video_url, str_thumb_url
}

