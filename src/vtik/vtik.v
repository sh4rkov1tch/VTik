module vtik

import net.http
import regex
import x.json2
import os

struct VTik {
	m_str_tag string = '[VTik]'
mut:
	m_str_title     string
	m_str_base_url  string
	m_str_json_url  string
	m_str_video_url string
	m_str_thumb_url string
}

pub fn new() VTik {
	mut vtik := VTik{}
	return vtik
}

pub fn (mut vtik VTik) set_base_url(str_url string) ?{
	vtik.m_str_base_url = str_url
	
	if !is_url_valid(vtik.m_str_base_url){
		return error("URL is not valid")
	}

	if vtik.is_url_shortened() {
		vtik.shortened_to_long_url()?
	}

	vtik.get_json_url()
	vtik.get_video_infos()?
}

fn (vtik VTik) is_url_shortened() bool {
	return vtik.m_str_base_url.contains('vm.tiktok.com')
}

fn (mut vtik VTik) shortened_to_long_url() ? {
	println('$vtik.m_str_tag URL is shortened, unshortening it')

	req := http.Request{
		url: vtik.m_str_base_url
		method: http.Method.get
		allow_redirect: false
	}

	res := req.do()?

	vtik.m_str_base_url = res.header.get_custom('Location')?
}

fn (mut vtik VTik) get_json_url() {
	str_tokens := vtik.m_str_base_url.split('/')
	str_username := str_tokens[3]
	str_id := str_tokens[5].split('?')[0]

	vtik.m_str_json_url = 'https://www.tiktok.com/node/share/video/$str_username/$str_id'

	println('$vtik.m_str_tag Got JSON data URL -> $vtik.m_str_json_url')
}

pub fn (mut vtik VTik) get_video_infos() ? {
	println('$vtik.m_str_tag Getting raw video URL, title and thumbnail')

	res := http.get(vtik.m_str_json_url)?
	str_raw_json := res.body

	video_json := json2.raw_decode(str_raw_json)?
	video_map := video_json.as_map()

	vtik.m_str_video_url = video_map['itemInfo']?.as_map()['itemStruct']?.as_map()['video']?.as_map()['downloadAddr']?.str()
	vtik.m_str_title = video_map['seoProps']?.as_map()['metaParams']?.as_map()['title']?.str()
	vtik.m_str_thumb_url = video_map['itemInfo']?.as_map()['itemStruct']?.as_map()['video']?.as_map()['reflowCover']?.str()
}

pub fn (vtik VTik) get_video_as_bytes() ?[]u8 {
	res := http.get(vtik.m_str_video_url)?
	return res.body.bytes()
}

pub fn (vtik VTik) get_thumbnail_as_bytes() ?[]u8{
	res := http.get(vtik.m_str_thumb_url)?
	return res.body.bytes()
}


pub fn (vtik VTik) download_video(path string) ? {
	mut path_corrected := path

	if path_corrected.ends_with('/') == false {
		path_corrected += '/'
	}
	complete_path := path_corrected + '[vtik] ' + vtik.m_str_title + '.mp4'

	println('$vtik.m_str_tag Downloading video @ $complete_path')

	video := vtik.get_video_as_bytes()?

	mut video_file := os.open_file(complete_path, "wb")?

	mut megabytes_written := f32(video_file.write(video)?)
	megabytes_written /= (1024*1024)

	video_file.close()

	println('$vtik.m_str_tag Video downloaded! ${megabytes_written:.2f} MB written')
}

pub fn (vtik VTik) save_thumbnail(path string) ? {
	mut path_corrected := path

	if path_corrected.ends_with('/') == false {
		path_corrected += '/'
	}
	complete_path := path_corrected + vtik.m_str_title + '.jpg'
	
	println('$vtik.m_str_tag Saving thumbnail @ $complete_path')
	
	thumbnail := vtik.get_thumbnail_as_bytes()?
	os.write_file_array(complete_path, thumbnail)?
	
	println('$vtik.m_str_tag Thumbnail saved!')
}

pub fn is_url_valid(str_url string) bool{
	mut reg_shortened, _, _:= regex.regex_base("https\:\/\/vm\.tiktok\.com\/{1}[a-zA-Z0-9]{9}[\/]{0,1}")
	mut reg_long, _, _ := regex.regex_base("https:\/\/www\.tiktok\.com\/[@]{1}[a-zA-Z0-9_]{0,32}\/video\/[0-9]{19}[?]{1}.{0,35}")

	return(reg_shortened.matches_string(str_url) || reg_long.matches_string(str_url))
}

pub fn (vtik VTik) get_video_url() string {
	return vtik.m_str_video_url
}

pub fn (vtik VTik) get_video_title() string{
	return vtik.m_str_title
}