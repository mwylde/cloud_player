module CloudPlayer
  module Amazon
    ENDPOINT = "https://www.amazon.com/cirrus/"
    class Track
      @props = [:albumArtistName, :albumName, :artistName,
                :duration, :extension, :objectId, :title, :trackNum]

      attr_reader *@props

      def self.props; @props; end

      def initialize(hash)
        self.class.props.each{|p|
          instance_variable_set("@#{p}", hash[p.to_s]) rescue nil
        }
      end

      def streaming_url session
        if @streaming_url
          @streaming_url
        else
          params = {
            "trackIdList.member.1" => @objectId,
            "Operation" => "getStreamUrls",
            "https" => "true",
            "caller" => "player.playSong"
          }
          resp = session.request params
          begin
            @streaming_url = resp["getStreamUrlsResponse"]["getStreamUrlsResult"]["trackStreamUrlList"][0]["url"]
          rescue NoMethodError
            raise Exception.new("Unable to get streaming URL")
          end
        end
      end
    end

    class Album
      @props = [:albumArtistName, :albumCoverImageFull,
               :albumCoverImageLarge, :albumCoverImageMedium,
               :albumCoverImageSmall, :albumCoverImageTiny,
               :albumName, :artistName, :assetType, :bitrate,
               :creationDate, :distinctCount, :duration, :extension,
               :hidden, :keywords, :lastUpdatedDate, :localFilePath,
               :md5, :mimeType, :name, :objectId, :parentObjectId,
               :payerId, :primaryGenre, :purchased, :size,
               :sortAlbumArtistName, :sortAlbumName, :sortArtistName,
               :sortTitle, :status, :title, :trackNum, :type, :uploaded,
               :version]

      attr_reader *@props

      def self.props; @props; end

      def tracks
      end

      def initialize(hash)
        self.class.props.each{|p|
          instance_variable_set("@#{p}", hash[p.to_s]) rescue nil
        }
      end
    end

    class Playlist
      @props = [:objectId, :adriveId, :playlistEntryList, :title,
                :trackCount, :version]

      attr_reader *@props

      def self.props; @props; end

      def initialize(hash)
        self.class.props.each{|p|
          instance_variable_set("@#{p}", hash[p.to_s]) rescue nil
        }
      end
    end
    
    class Library
      attr_reader :tracks, :albums, :playlists
      
      def initialize session
        @session = session
        # All library items indexed by id
        @items_by_id = {}
        # Tracks index by a pair [album, artist]
        @tracks_by_album_artist = {}
      end

      def find id
        @items_by_id[id]
      end

      def tracks_for_album album
        @tracks_by_album_artist[[album.albumName, album.albumArtistName]]
      end

      def load_tracks
        params = {
          "searchReturnType" => "TRACKS",
          "searchCriteria.member.1.attributeName" => "keywords",
          "searchCriteria.member.1.comparisonType" => "LIKE",
          "searchCriteria.member.1.attributeValue" => "",
          "searchCriteria.member.2.attributeName" => "assetType",
          "searchCriteria.member.2.comparisonType" => "EQUALS",
          "searchCriteria.member.2.attributeValue" => "AUDIO",
          "searchCriteria.member.3.attributeName" => "status",
          "searchCriteria.member.3.comparisonType" => "EQUALS",
          "searchCriteria.member.3.attributeValue" => "AVAILABLE",
          "albumArtUrlsRedirects" => "false",
          "distinctOnly" => "false",
          "countOnly" => "false",
          "sortCriteriaList" => "",
          "caller" => "getServerSongs",
          "Operation" => "searchLibrary",
          "selectedColumns.member.1" => "albumArtistName",
          "selectedColumns.member.2" => "albumName",
          "selectedColumns.member.3" => "artistName",
          "selectedColumns.member.4" => "assetType",
          "selectedColumns.member.5" => "duration",
          "selectedColumns.member.6" => "objectId",
          "selectedColumns.member.7" => "sortAlbumArtistName",
          "selectedColumns.member.8" => "sortAlbumName",
          "selectedColumns.member.9" => "sortArtistName",
          "selectedColumns.member.10" => "title",
          "selectedColumns.member.11" => "status",
          "selectedColumns.member.12" => "trackStatus",
          "selectedColumns.member.13" => "extension",
          "selectedColumns.member.14" => "trackNum",
          "sortCriteriaList.member.1.sortColumn" => "sortTitle",
          "sortCriteriaList.member.1.sortType" => "ASC"
        }

        tracks = load_items params
        @tracks = tracks.collect{|t| Track.new(t["metadata"])}
        @tracks_by_album_artist = {}
        @tracks.each{|t|
          @items_by_id[t.objectId] = t
          aaa = [t.albumName, t.albumArtistName]
          @tracks_by_album_artist[aaa] ||= []
          @tracks_by_album_artist[aaa] << t
        }
      end

      def load_albums
        params = {
          "searchReturnType" => "ALBUMS",
          "searchCriteria.member.1.attributeName" => "status",
          "searchCriteria.member.1.comparisonType" => "EQUALS",
          "searchCriteria.member.1.attributeValue" => "AVAILABLE",
          "searchCriteria.member.2.attributeName" => "trackStatus",
          "searchCriteria.member.2.comparisonType" => "IS_NULL",
          "searchCriteria.member.2.attributeValue" => "",
          "sortCriteriaList" => "",
          "albumArtUrlsRedirects" => "false",
          "countOnly" => "false",
          "Operation" => "searchLibrary",
          "caller" => "getAllServerData",
          "albumArtUrlsSizeList.member.1" => "MEDIUM",
          "sortCriteriaList.member.1.sortColumn" => "sortAlbumName",
          "sortCriteriaList.member.1.sortType" => "ASC"
        }

        albums = load_items params
        @albums = albums.collect{|a| Album.new(a["metadata"])}
        @albums.each{|a| @items_by_id[a.objectId] = a}
      end

      def load_playlists
        params = {
          "includeTrackMetadata" => "false",
          "trackCountOnly" => "true",
          "Operation" => "getPlaylists",
          "caller" => "getServerListSongs",
          "albumArtUrlsRedirects" => "false",
          "playlistIdList" => "",
          "trackColumns.member.1" => "albumArtistName",
          "trackColumns.member.2" => "albumName",
          "trackColumns.member.3" => "artistName",
          "trackColumns.member.4" => "assetType",
          "trackColumns.member.5" => "duration",
          "trackColumns.member.6" => "objectId",
          "trackColumns.member.7" => "sortAlbumArtistName",
          "trackColumns.member.8" => "sortAlbumName",
          "trackColumns.member.9" => "sortArtistName",
          "trackColumns.member.10" => "title"
        }

        playlists = load_items params, "playlistInfoList"
        @playlists = playlists.collect{|p| Playlist.new(p)}
        @playlists.each{|p| @items_by_id[p.objectId] = p}
      end

      def load_everything
        load_playlists
        load_tracks
        load_albums
      end

      def get_count params
        params = params.dup
        params["countOnly"] = "true"
        params.delete_if{|k,v| k.match("selectedColumns")}
        params["selectedColumns.member.1"] = "*"
        resp = @session.request params
        resp["#{params["Operation"]}Response"]["#{params["Operation"]}Result"]["resultCount"]
      end
      
      def load_items params, list = "searchReturnItemList"
        params["maxResults"] = "500"

        # first get count so we make sure we get the right number of
        # results, as Amazon seems to sometimes screw this up
        count = get_count params
        
        items = []
        next_results_token = ""
        while next_results_token
          params["nextResultsToken"] = next_results_token
          resp = @session.request params
          begin
            results = resp["#{params["Operation"]}Response"]["#{params["Operation"]}Result"]
            next_results_token = results["nextResultsToken"]
            items += results[list]
            # puts [results["resultCount"],
            # next_results_token].inspect
            # puts "Got #{items.size}, next #{next_results_token}"
            if next_results_token == "" && count
              next_results_token = (items.size + params["maxResults"]).to_s
            end
            break if next_results_token == ""
          rescue
            # puts resp.inspect
            break
          end
        end
        items
      end

      def update
        params = {
          "caller" => "checkServerChange",
          "Operation" => "getGlobalLastUpdatedDate"
        }
        @session.request params
      end
    end
  end
end
