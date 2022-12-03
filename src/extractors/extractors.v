module extractors

import net.http
import x.json2
import os

import rand
import math
// Since TikTok restricted access to the old endpoint, I'll just use another one but it's looong as hell

// Return: Video Title, Video URL, Thumbnail URL

pub fn tiktok(str_tag string, str_url string, is_shortened bool) !(string, string, string) {
	mut str_base_url := str_url

	if is_shortened { // Shortened URL check
		res := http.Request{
			url: str_base_url
			method: http.Method.get
			allow_redirect: false
		}.do()!

		str_base_url = res.header.get_custom('Location')!
	}

	str_tokens := str_base_url.split('/')
	aweme_id := str_tokens[5].split('?')[0]
	println(aweme_id)
	device_id := rand.i64_in_range(math.powi(10, 3), 9 * math.powi(10, 10))!
	
	tiktok_api_link := 'https://api.tiktokv.com/aweme/v1/feed/?aweme_id=${aweme_id}&iid=6165993682518218889&device_id=${device_id}&aid=1180'
	println('${str_tag} Got JSON data URL -> ${tiktok_api_link}')

	println('${str_tag} Getting raw video URL, title and thumbnail')

	user_agent := 'com.ss.android.ugc.trill/494+Mozilla/5.0+(Linux;+Android+12;+2112123G+Build/SKQ1.211006.001;+wv)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Version/4.0+Chrome/107.0.5304.105+Mobile+Safari/537.36'

	hdr := http.new_header(key: http.CommonHeader.user_agent, value: user_agent)

	res := http.Request{
		url: tiktok_api_link
		method: http.Method.get
		header: hdr
	}.do()!

	str_raw_json := res.body

	video_json := json2.raw_decode(str_raw_json)!
	video_map := video_json.as_map()

	str_video_url := video_map['aweme_list']!.arr()[0]!.as_map()['video']!.as_map()['play_addr']!.as_map()['url_list']!.arr()[0]!.str()
	str_title := video_map['aweme_list']!.arr()[0]!.as_map()['desc']!.str()
	str_thumb_url := video_map['aweme_list']!.arr()[0]!.as_map()['video']!.as_map()['cover']!.as_map()['url_list']!.arr()[0]!.str()

	return str_title, str_video_url, str_thumb_url
}

pub fn twitter(str_tag string, str_url string) !(string, string, string) {
	str_tokens := str_url.split_any('/!')
	mut str_id := str_tokens[5]

	bearer_token := os.getenv_opt('TWITTER_BEARER_TOKEN') or { return "", "", ""}

	request_url := 'https://api.twitter.com/1.1/statuses/show.json?=include_entities=true&tweet_mode=extended&id=$str_id'

	println('$str_tag getting JSON metadata for video ${str_url}')

	hdr := http.new_header(key: http.CommonHeader.authorization, value: 'Bearer ${bearer_token}')

	res := http.Request{
		method: http.Method.get
		header: hdr
		url: request_url
	}.do()!

	json := json2.raw_decode(res.body)!

	json_map := json.as_map()

	println('$str_tag getting title, video and thumbnail URLs')

	str_title := str_id
	str_vid_map_arr := json_map['extended_entities']!.as_map()['media']!.arr()[0]!.as_map()['video_info']!.as_map()['variants']!.arr()

	mut str_video_url := ''
	mut bitrate := 0

	for raw_map in str_vid_map_arr {
		map_variant := raw_map.as_map()
		str_content_type := map_variant['content_type']!.str()

		if str_content_type == 'video/mp4' {
			local_bitrate := map_variant['bitrate']!.int()

			if local_bitrate > bitrate {
				bitrate = local_bitrate
				str_video_url = map_variant['url']!.str()
			}
		}
	}

	str_thumb_url := json_map['entities']!.as_map()['media']!.arr()[0]!.as_map()['media_url']!.str()

	return str_title, str_video_url, str_thumb_url
}
