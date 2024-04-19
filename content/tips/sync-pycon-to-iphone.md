---
{
  "aliases": ["/writing/how-to-sync-pycon-videos-to-your-iphone"],
  "title": "How to sync PyCon videos to your iPhone",
  "description": "Using Python to fetch and convert YouTube videos for syncing to iPhone",
  "tags": ["python"],
  "slug": "how-to-sync-pycon-videos-to-your-iphone",
  "date": "2012-03-11",
}
---

### Problem

You want to all the [PyCon](http://pycon.org/) videos on your iPhone for offline
viewing.

### Solution

Use the following Python script to fetch pycon videos from YouTube and convert
them to M4V format so they can be imported to iTunes.

<script src="https://gist.github.com/2018487.js"> </script>

<div class="admonition warning">
    This gist is stale now - the code for downloading videos has been
    expanding into a [Github repository](https://github.com/codeinthehole/pyvideo2quicktime).
</div>

To run the script:

1. Ensure you have
   [requests](http://docs.python-requests.org/en/v0.10.7/index.html) and
   [BeautifulSoup](http://www.crummy.com/software/BeautifulSoup/) installed in
   your Python environment;
2. Ensure you have `ffmpeg` available on your path;
3. Download [youtube-dl](http://rg3.github.com/youtube-dl/) to the same
   directory as this script

Run this script using:

```bash
python fetch_pyvideo.py
```

The script will display the title and description of each available PyCon video
and prompt you as to whether you want to download it. Once all videos have been
reviewed, each selected one will be downloaded and converted. When all videos
have been processed, you can import the files into iTunes and sync them onto
your Apple device.

### Discussion

As is plain to see, the script is a hacky bit of Python plumbing that:

- Scrapes the PyCon category and video pages of
  [pyvideo.org](http://pyvideo.org/);
- Prompts the user to choose which videos to download;
- Fetches the Flash content from YouTube using the `youtube-dl` utility;
- Converts the `.flv` files to the M4V QuickTime format.
