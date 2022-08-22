# VTik
Command-line TikTok and Twitter downloader written in V [(Official Website)](https://vlang.io)
It's heavily inspired by [youtube-dl](https://github.com/ytdl-org/youtube-dl) but aims to be faster and simpler than youtube-dl

## Usage
It's a very simple tool to use:
`$ ./vtik-cli -o <path> <tiktok/twitter link>`
The file path is optional, if you don't specify any, the app will just download in your working directory
If you want to download a Twitter video you'll need to provide your own bearer token, in an environment variable called `TWITTER_BEARER_TOKEN`

## Building the CLI App
Since it's a V app, building it is straightforward:
`$ v vtik-cli.v`

## Building the Telegram Bot
The bot was built using Dario Tarantini's [vgram](https://github.com/dariotarantini/vgram)

It requires an extra step:
`$ v install dariotarantini.vgram`
`$ v vtik-telegram.v`

## To-do:
- Implementing a server that handles http request containing the video link, so I can build iOS shortcuts or their Android equivalent around

- Maybe a GUI app around it ? Even though I think that it's kinda useless for a simple app like that.