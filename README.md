# Delphi-YouTube-Channel-parsing-plugin-for-Zoom-Player
This Zoom Player plugin uses the YouTube data API to:<br>
<ol>
<li>Accurately convert a YouTube User Name or Custom URL (e.g. "https://www.youtube.com/@zptechnology") to a YouTube Channel ID.
<li>Download channel meta-data using a YouTube Channel ID (title/description/thumbnail/etc...).
<li>Download a channel's video list meta-data (title/description/thumbnail/etc...) based on the Channel ID with 3 API entry points ("search", "activity" and "upload playlist").
<li>Download meta-data on videos based on trending videos in a specific geographic region and video category.
<li>Download meta-data on videos based on a search query.
<li>Get YouTube playlist title from a playlist URL.
<li>Download meta-data on videos from a YouTube playlist URL.
</ol>
<font size=-1>
  <br>
YOUTUBE_PLUGIN_DEFINES.INC includes the compiler directives to switch between the multiple Plugin modes (Channel/Search/Trending/Playlist/etc...)
</font>
