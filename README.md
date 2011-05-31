# cloud_player  #

CloudPlayer is an implementation of the undocumented (read: may break
at any time) API of Amazon's Cloud Player. It's pretty basic right
now, handling authentication and getting tracks, albums, artists
and playlists. The eventual goal is to create a local daemon that can
play music from Cloud Player as well as a client for interacting with
it. This would allow use of Cloud Player outside of the browser.

The library is pretty simple to use:

```ruby
# First create a Session object
session = CloudPlayer::Amazon::Session.new(user, pass)

# Send auth information to Amazon
session.login

# Then use that to create a Library
library = CloudPlayer::Amazon::Library.new(session)

# Download data from Amazon. This is on-demand to reduce
# instantiation time in case you don't need something
library.load_albums
library.load_tracks
library.load_playlists

# Now we can use the information
library.albums[12].albumName # => "Antifogmatic"
library.tracks[40].objectId # => "8d4d7f39-fea2-4179-b08d-e76ce66f4582"
```
