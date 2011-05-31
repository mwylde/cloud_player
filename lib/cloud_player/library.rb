module CloudPlayer
  module Amazon
    ENDPOINT = "https://www.amazon.com/cirrus/"
    class Library
      def initialize session
        @session = session
      end

      def load_tracks
        tracks = []
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
          "maxResults" => "50",
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
          "sortCriteriaList.member.1.sortColumn" => "sortTitle",
          "sortCriteriaList.member.1.sortType" => "ASC"
        }

        next_results_token = ""
        while next_results_token
          params["nextResultsToken"] = next_results_token
          resp = request params
          begin
            results = resp["searchLibraryResponse"]["searchLibraryResult"]
            next_results_token = results["nextResultsToken"]
            tracks += results["searchReturnItemList"]
            puts [results["resultCount"], next_results_token].inspect
          rescue
            puts resp.inspect
            break
          end
        end
        tracks
      end

      def update
        params = {
          "caller" => "checkServerChange",
          "Operation" => "getGlobalLastUpdatedDate"
        }
        request params
      end

      def request params
        params = {
          "ContentType" => "JSON",
          "customerInfo.customerId" =>  @session.customer_id,
          "customerInfo.deviceId" => @session.did,
          "customerInfo.deviceType" => @session.dtid
        }.merge params
        headers = {
          "ContentType" => "application/x-www-form-urlencoded",
          "x-amzn-RequestId" => UUIDTools::UUID.random_create,
          "x-adp-token" => @session.tid
        }

        result = @session.agent.post(ENDPOINT, params, headers)
        JSON.load(result.body)
      end
    end
  end
end
