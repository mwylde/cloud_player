module CloudPlayer
  module Amazon
    class Library
      def initialize session
        @session = session
      end

      def load_tracks
        params = {
          "searchReturnType" => "TRACKS",
          "maxResults" => 50,
          "searchCriteria.member.1.attributeName" => "keywords",
          "searchCriteria.member.1.comparisonType" => "LIKE",
          "searchCriteria.member.1.attributeValue" => "",
          "searchCriteria.member.2.attributeName" => "assetType",
          "searchCriteria.member.2.comparisonType" => "EQUALS",
          "searchCriteria.member.2.attributeValue" => "AUDIO",
          "searchCriteria.member.3.attributeName" => "status",
          "searchCriteria.member.3.comparisonType" => "EQUALS",
          "searchCriteria.member.3.attributeValue" => "AVAILABLE",
          "albumArtUrlsRedirects" => false,
          "distinctOnly" => false,
          "selectedColumns.member.1" => "albumArtistName",
          "selectedColumns.member.2" => "artistName",
          "selectedColumns.member.3" => "assetType",
          "selectedColumns.member.5" => "duration",
          "selectedColumns.member.6" => "objectId",
          "selectedColumns.member.7" => "sortAlbumArtistName",
          "selectedColumns.member.8" => "sortAlbumName",
          "selectedColumns.member.9" => "sortArtistName",
          "selectedColumns.member.10" => "title",
          "selectedColumns.member.11" => "status",
          "selectedColumns.member.12" => "trackStatus",
          "selectedColumns.member.13" => "extension",
          "nextResultToken" => "",
          "caller" => "getServerSongs",
          "Operation" => "searchLibrary"
        }
        request params
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
          "x-amzn-RequestId" => "b132417g-b10d-dmcp-82de-f0ed6b075dc9",
          "x-adp-token" => @session.tid
        }

        @session.agent.post("https://www.amazon.com/cirrus/", params, headers)
      end
    end
  end
end
