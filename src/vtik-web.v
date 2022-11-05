module main

import vweb
import os

import vtik

struct App{
	vweb.Context
}

fn main(){
	vweb.run_at(new_app(), vweb.RunParams{
		port: 8081
	}) or { panic(err) }
}

fn new_app() &App {
	mut app := &App{}
	return app
}

['/get_video']
pub fn (mut app App) get_video() !vweb.Result {
	// Will use the link field in query
	create_temp_folder() or {
		return app.text('{err}')
	}

	mut v := vtik.new()
	video_link := app.query['link']

	v.set_base_url(video_link) or {
		return app.json({'error': '{err}'})
	}

	path := v.download_video('/tmp/vtik')!

	return app.file(path)
}

['/get_thumb']
pub fn (mut app App) get_thumb() !vweb.Result {
	// Will use the link field in query
	create_temp_folder() or {
		return app.text('{err}')
	}

	mut v := vtik.new()
	video_link := app.query['link']

	v.set_base_url(video_link) or {
		return app.json({'error': '{err}'})
	}

	path := v.save_thumbnail('/tmp/vtik')!

	return app.file(path)
}

fn create_temp_folder() ! {
	os.mkdir('/tmp/vtik') or {
		os.rmdir_all('/tmp/vtik')!
		os.mkdir('/tmp/vtik')!
	}
}