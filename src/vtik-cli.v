module main

import os
import flag
import vtik

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('VTik')
	fp.version('v0.0.1')
	fp.description('TikTok Downloader written in V (https://www.vlang.io)')
	fp.skip_executable()
	fp.limit_free_args_to_exactly(1)?
	fp.footer('The expected argument is the link of the video you want to download!')

	str_path := fp.string('output', `o`, os.getwd(), 'The path where you want the video to be downloaded')
	bool_thumb := fp.bool('thumbnail', `t`, false, 'If this flag is applied, only the thumbnail will be downloaded')

	add_args := fp.finalize() or {
		eprintln(err)
		println(fp.usage())
		return
	}

	str_url := add_args[0]

	mut vt := vtik.new()
	vt.set_base_url(str_url) or {
		eprintln('[VTik] Error: $err')
		return
	}

	if bool_thumb {
		vt.save_thumbnail(str_path) or {
			eprintln(err)
			println("[VTik] Error: Couldn't save thumbnail")
			return
		}
	} else {
		vt.download_video(str_path) or {
			eprintln(err)
			println("[VTik] Error: Couldn't download video")
			return
		}
	}
}
