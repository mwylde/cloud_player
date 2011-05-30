require 'nokogiri'
require 'mechanize'

module CloudPlayer
  module Amazon
    # Processes auth information to produce an auth token which is
    # necessary for other portions of the API.
    class Session
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
          login_form.email = @user
          login_form.password = @pass
          page = @agent.submit(login_form)
        else
          puts "no login form"
        end
      end
    end
  end
end
