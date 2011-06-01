module CloudPlayer
  module Amazon
    # Processes auth information to produce an auth token which is
    # necessary for other portions of the API.
    class Session
      attr_reader :agent, :customer_id, :did, :dtid, :tid
      # Creates a new Auth object for the given username and password.
      # @param String user The username for the account
      # @params String pass The password for the account
      def initialize user, pass
        @user = user
        @pass = pass
        @agent = Mechanize.new
        # Amazon won't give you a real session id unless you have a
        # real user agent
        @agent.user_agent_alias = 'Mac Safari'
      end

      # Produces an auth token for the account
      def login
        puts @agent.cookies[1]
        page = @agent.get("https://www.amazon.com/cloudplayer")
        login_form = page.form("signIn")
        if login_form
          retried = false
          begin
            login_form.email = @user
            login_form.password = @pass
            page = @agent.submit(login_form)
            body = page.send(:html_body)
            @customer_id = body.match(/amznMusic\.customerId = '(.+)'/)[1]
            @did = body.match(/amznMusic\.did = '(.+)'/)[1]
            @dtid = body.match(/amznMusic\.dtid = '(.+)'/)[1]
            @tid = body.match(/amznMusic\.tid = '(.+)'/)[1]
          rescue
            unless retried
              retried = true
              retry
            else
              raise Exception.new("Unable to authenticate")
            end
          end
        else
          puts "no login form"
        end
      end

      def request params
        params = {
          "ContentType" => "JSON",
          "customerInfo.customerId" =>  @customer_id,
          "customerInfo.deviceId" => @did,
          "customerInfo.deviceType" => @dtid
        }.merge params
        headers = {
          "ContentType" => "application/x-www-form-urlencoded",
          "x-amzn-RequestId" => UUIDTools::UUID.random_create,
          "x-adp-token" => @tid
        }

        result = @agent.post(ENDPOINT, params, headers)
        JSON.load(result.body)
      end
    end
  end
end
