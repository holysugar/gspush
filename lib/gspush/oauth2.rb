require 'highline'
require 'oauth2'

class Gspush
  class Oauth2
    attr_accessor :access_token, :refresh_token, :expires_at
    attr_accessor :client_id, :client_secret, :redirect_uri

		def initialize(file_path = nil)
      @file_path = file_path || "#{ENV["HOME"]}/.gspushrc"
      @redirect_uri = "urn:ietf:wg:oauth:2.0:oob"
    end

		def token
      self.load or raise "First you need gspush_generate to create oauth2 configuration"
      token = OAuth2::AccessToken.from_hash(client, to_hash)

      if expired?
        token.refresh!
        save
      end

      token
		end

    def self.generate
      puts "Input your application information"
      puts "(see https://code.google.com/apis/console )"

			oauth2 = new

      hi = HighLine.new
      oauth2.client_id = hi.ask("Client ID? > ")
      oauth2.client_secret = hi.ask("Client Secret? > ")

      oauth2.get_access_token
      oauth2.save
    end

    def save
			File.open(@file_path, 'w') do |f|
				f.print to_hash.to_yaml
			end
			puts "ok saved in #{@file_path}"
    end

    def load
      if FileTest.exist?(@file_path)
        o = YAML.load(File.read(@file_path))
        @access_token = o[:access_token]
        @refresh_token = o[:refresh_token]
        @expires_at = o[:expires_at]
        @client_id = o[:client_id]
        @client_secret = o[:client_secret]
        @redirect_uri = o[:redirect_uri]
        true
      else
        false
      end
    end

    def client
      OAuth2::Client.new(
        @client_id, @client_secret,
        :site => "https://accounts.google.com",
        :token_url => "/o/oauth2/token",
        :authorize_url => "/o/oauth2/auth")
    end

    def get_access_token
      auth_url = client.auth_code.authorize_url(
        :redirect_uri => @redirect_uri,
        :scope =>
          ["https://docs.google.com/feeds/",
           "https://docs.googleusercontent.com/",
           "https://spreadsheets.google.com/feeds/"].join(" "))
      hi = HighLine.new

      puts "Access in your browser: #{auth_url}"
      authorization_code = hi.ask("And please input authorization code: ")

      auth_token = client.auth_code.get_token(
        authorization_code, :redirect_uri => @redirect_uri)

      @access_token  = auth_token.token
      @refresh_token = auth_token.refresh_token
      @expires_at    = auth_token.expires_at

      @access_token
    end

    def expired?
      @expires_at && Time.now.to_i > @expires_at
    end

    def to_hash
      {
        :client_id => client_id,
        :client_secret => client_secret,
        :redirect_uri => redirect_uri,
        :access_token => access_token,
        :refresh_token => refresh_token,
        :expires_at => expires_at,
      }
    end
  end
end


