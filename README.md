# RTMPS-HLS-Server Docker

**Docker image for video streaming server that supports RTMP, RTMPS, HLS, and DASH streams.**

## Description

This Docker image can be used to create a video streaming server that supports [**RTMP**](https://en.wikipedia.org/wiki/Real-Time_Messaging_Protocol) & **RTMPS**\* Ingest, **RTMP** & **RTMPS** (via Stunnel) Pushing, and **RTMP**, [**HLS**](https://en.wikipedia.org/wiki/HTTP_Live_Streaming) & [**DASH**](https://en.wikipedia.org/wiki/Dynamic_Adaptive_Streaming_over_HTTP) playback out of the box.
It also allows adaptive streaming and custom transcoding of video streams.
All modules are built from source on Debian and Alpine Linux base images.

## Features

- The backend is [**Nginx**](http://nginx.org/en/) with [**nginx-rtmp-module**](https://github.com/arut/nginx-rtmp-module).
- [**FFmpeg**](https://www.ffmpeg.org/) for transcoding and adaptive streaming
- Stunnel for RTMPS support (primarily for Facebook Live)
- Default settings:
  - RTMP is ON
  - HLS is ON
  - DASH is ON
  - Other Nginx configuration files are also provided to allow for RTMP-only streams or FFmpeg transcoding and adaptive streaming.
- Statistic page of RTMP streams at `http://<server ip>:<server port>/stats`.
- Available web video players (based on [video.js](https://videojs.com/) and [hls.js](https://github.com/video-dev/hls.js/)) at `/usr/local/nginx/html/players`.

Current Image is built using:

- Nginx 1.18.0 (compiled from source)
- Nginx-rtmp-module 1.2.1 (compiled from source)
- FFmpeg 4.3.1 (compiled from source)

This image was inspired by similar docker images from [tiangolo](https://hub.docker.com/r/tiangolo/nginx-rtmp/) and [alfg](https://hub.docker.com/r/alfg/nginx-rtmp/). It has small build size, adds support for HTTP-based streams and adaptive streaming using FFmpeg.

## Usage

### To run the server

```shell
docker run -d -p 1935:1935 -p 1936:1936 -p 8080:8080 -e PUID=$UID -e PGID=0 -e SSL_DOMAIN='rtmp.domain.loc' -v /your/local/assets/:/assets jamiephonic/rtmps-hls-server:latest
```

When you start the container, the default players and configuration files will be copied into `/your/local/assets/` to allow you to easily access and edit them.
This will only be done once when you first start the container. If you want to restore the default configs, delete `/your/local/assets/.initialized` amd restart the container.

For more examples, see the [Wiki](https://github.com/JamiePhonic/rtmps-hls-server/wiki/usage)

***

### To stream to the server

- **Stream live RTMP content to:**

 `rtmp://<server ip>:1935/live/<stream_key>`

  where `<stream_key>` is any stream key you specify.

- **Configure [OBS](https://obsproject.com/) to stream content:** <br />
  Go to Settings > Stream, choose the following settings:
  - Service: Custom Streaming Server.
  - Server: `rtmp://<server ip>:1935/live`.
  - Stream key: anything you want, however provided video players assume stream key is `test`
  
See the [Wiki](https://github.com/JamiePhonic/rtmps-hls-server/wiki/streaming-to-the-server) for how to stream to the server with RTMPS

***

### To view the stream

- **Using [VLC](https://www.videolan.org/vlc/index.html):**

  - Go to Media > Open Network Stream.
  - Enter the streaming URL: `rtmp://<server ip>:1935/live/<stream-key>`
    Replace `<server ip>` with the IP of where the server is running, and
    `<stream-key>` with the stream key you used when setting up the stream.
  - For HLS and DASH, the URLs are of the forms:
    `http://<server ip>:8080/hls/<stream-key>.m3u8` and
    `http://<server ip>:8080/dash/<stream-key>_src.mpd` respectively.
  - Click Play.

- **Using provided web players:** <br/>
  The provided demo players assume the stream-key is called `test` and the player is opened from localhost.
  - To play RTMP content (requires Flash): `http://<server ip>:8080/players/rtmp.html`
  - To play HLS content: `http://<server ip>:8080/players/hls_basic.html`
  - To play HLS content using hls.js library: `http://<server ip>:8080/players/hls.html`
  - To play DASH content: `http://<server ip>:8080/players/dash.html`

  **Notes:**

  - These web players are hardcoded to play stream key "test" at localhost.
  - To change the stream source for these players, Modify the `src` attribute in the video tag in the html file and then reload the page.

## Copyright

Released under MIT license.

## More info

- **GitHub repo**: <https://github.com/JamiePhonic/rtmp-hls-server.git>

- **Docker Hub image**: <https://hub.docker.com/r/jamiephonic/rtmp-hls-stunnel>
