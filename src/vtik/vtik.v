module vtik

import net.http
import regex
import os
import extractors

struct VTik {
	m_str_tag string = '[VTik]'
mut:
	m_str_title     string
	m_str_video_url string
	m_str_thumb_url string
}

pub fn new() VTik {
	mut vtik := VTik{}
	return vtik
}

pub fn (mut vtik VTik) set_base_url(str_url string) ? {
	str_check := check_url(str_url)?
	match str_check {
		'tiktok_s' {
			vtik.m_str_title, vtik.m_str_video_url, vtik.m_str_thumb_url = extractors.tiktok(vtik.m_str_tag,
				str_url, true)?
		}
		'tiktok_l' {
			vtik.m_str_title, vtik.m_str_video_url, vtik.m_str_thumb_url = extractors.tiktok(vtik.m_str_tag,
				str_url, false)?
		}
		'twitter' {
			vtik.m_str_title, vtik.m_str_video_url, vtik.m_str_thumb_url = extractors.twitter(vtik.m_str_tag,
				str_url)?
		}
		else {
			return error('Invalid URL')
		}
	}
}

pub fn (vtik VTik) get_video_as_bytes() ?[]u8 {
	res := http.get(vtik.m_str_video_url)?
	return res.body.bytes()
}

pub fn (vtik VTik) get_thumbnail_as_bytes() ?[]u8 {
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

	mut video_file := os.open_file(complete_path, 'wb')?

	mut megabytes_written := f32(video_file.write(video)?)
	megabytes_written /= (1024 * 1024)

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

pub fn check_url(str_url string) ?string {
	mut map_regex := {
		'tiktok_s': regex.regex_opt('https\:\/\/vm\.tiktok\.com\/{1}[a-zA-Z0-9]{9}[\/]{0,1}')?
		'tiktok_l': regex.regex_opt('https:\/\/www\.tiktok\.com\/@[a-zA-Z0-9._]{0,32}\/video\/[0-9]{19}[?]{0,1}.{0,40}')?
		'twitter':  regex.regex_opt('https:\/\/twitter.com\/[a-zA-Z0-9_]{0,16}\/status\/[0-9]{19}[?]{0,1}.{0,64}')?
	}

	mut str_ret := 'invalid'
	for k, mut regex in map_regex {
		if regex.matches_string(str_url) {
			str_ret = k
			break
		}
	}

	return str_ret
}

pub fn (vtik VTik) get_video_url() string {
	return vtik.m_str_video_url
}

pub fn (vtik VTik) get_video_title() string {
	return vtik.m_str_title
}
