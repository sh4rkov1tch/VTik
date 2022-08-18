# VTik
Command-line TikTok downloader written in V [(Official Website)](https://vlang.io)

## Usage
It's a very simple tool to use:
`$ ./vtik-cli -o <path> <tiktok link>`
The file path is optional, if you don't specify any, the app will just download in your working directory

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