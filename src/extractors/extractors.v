module extractors

import net.http
import x.json2
import os

import rand
import time
// Since TikTok restricted access to the old endpoint, I'll just use another one but it's looong as hell

// Return: Video Title, Video URL, Thumbnail URL

pub fn tiktok(str_tag string, str_url string, is_shortened bool) ?(string, string, string) {
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
	str_id := str_tokens[5].split('?')[0]

	openudid := rand.string_from_set('0123456789abcdef', 16)
	uuid := rand.string_from_set('0123456789abcdef', 16)
	seconds := time.now().unix_time()
	str_json_url := 'https://api-h2.tiktokv.com/aweme/v1/feed/?aweme_id=${str_id}&version_name=26.1.3&version_code=2613&build_number=26.1.3&manifest_version_code=2613&update_version_code=2613&openudid=${openudid}&uuid=${uuid}&_rticket=${seconds}&ts=${seconds*1000}&device_brand=Google&device_type=Pixel%204&device_platform=android&resolution=1080*1920&dpi=420&os_version=10&os_api=29&carrier_region=US&sys_region=US%C2%AEion=US&app_name=trill&app_language=en&language=en&timezone_name=America/New_York&timezone_offset=-14400&channel=googleplay&ac=wifi&mcc_mnc=310260&is_my_cn=0&aid=1180&ssmix=a&as=a1qwert123&cp=cbfhckdckkde1'
	
	println('$str_tag Got JSON data URL -> $str_json_url')

	println('$str_tag Getting raw video URL, title and thumbnail')

	user_agent := '	Mozilla/5.0 (X11; Linux x86_64; rv:105.0) Gecko/20100101 Firefox/105.0'
	hdr := http.new_header(key: http.CommonHeader.user_agent, value: user_agent)

	res := http.Request{
		url: str_json_url
		method: http.Method.get
		header: hdr
	}.do()?

	str_raw_json := res.body

	video_json := json2.raw_decode(str_raw_json)?
	video_map := video_json.as_map()

	str_video_url := video_map['aweme_list']?.as_map()['0']?.as_map()['video']?.as_map()['play_addr']?.as_map()['url_list']?.as_map()['0']?.str()
	str_title := video_map['aweme_list']?.as_map()['0']?.as_map()['desc']?.str()
	str_thumb_url := video_map['aweme_list']?.as_map()['0']?.as_map()['video']?.as_map()['cover']?.as_map()['url_list']?.as_map()['0']?.str()

	return str_title, str_video_url, str_thumb_url
}

pub fn twitter(str_tag string, str_url string) ?(string, string, string) {
	str_tokens := str_url.split_any('/?')
	mut str_id := str_tokens[5]

	bearer_token := os.getenv_opt('TWITTER_BEARER_TOKEN')?

	request_url := 'https://api.twitter.com/1.1/statuses/show.json?include_entities=true&tweet_mode=extended&id=$str_id'

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

