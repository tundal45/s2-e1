require 'rubygems'
require 'json'
require 'open-uri'
require 'nokogiri'
require 'digest/md5'

module RMURapportiveBot
  
  class NetworkProfile
  
    def self.config(config)
      config
    end
    
    def self.search(params)
      ret_hash = Hash.new
      params[:networks].each do |network|
        ret_hash[network] = case network
          when 'flickr'
            FlickrProfile.search(params[:email])
          when 'github'
            GitHubProfile.search(params[:email])
          when 'ohloh'
            OhLohProfile.search(params[:email])
          when 'twitter', 'linkedin', 'facebook'
            "Unfortunately, #{network} currently does not allow to search for users via email"
          else
            "Unfortunately, the bot does not currently support #{network}"
          end
      end
      ret_hash
    end
  end
  
  class FlickrProfile < NetworkProfile
       
    def self.search(email)
      method = "flickr.people.findByEmail"
      api_key = "b379176b4ea72661eb04294366e3928e"
      request_url = "http://api.flickr.com/services/rest/?method=#{method}&api_key=#{api_key}&find_email=#{email}"
      response = Nokogiri::XML(open(request_url))
      
      if response.at_css("rsp").attributes["stat"].value.eql?("ok")
        nsid = response.at_css("user").attributes["nsid"].inner_text
        method = "flickr.urls.getUserProfile"
        request_url = "http://api.flickr.com/services/rest/?method=#{method}&api_key=#{api_key}&user_id=#{nsid}"
        
        response = Nokogiri::XML(open(request_url))
        profile_url = response.at_css("user").attributes["url"].inner_text
      elsif response.at_css("err").attributes["code"].value.eql?("1")
        profile_url = "The bot could not find #{email} on Flickr :-("
      else
        error_msg = response.at_css("err").attributes["msg"].inner_text
        profile_url = <<-ERROR 
          The bot encountered an error trying to find profile for #{email}
          Error Message:
          #{error_msg}"
        ERROR
      end
      
    end
    
  end
  
  class GitHubProfile < NetworkProfile
  
    def self.search(email)
      request_url = "http://github.com/api/v2/json/user/email/#{email}"
      user_name = JSON.parse(open(request_url).read)["user"]["login"]
      profile_url = "http://github.com/#{user_name}"
    end
    
  end
  
  class OhLohProfile < NetworkProfile
  
    def self.search(email)
      md5 = Digest::MD5.hexdigest(email)
      request_url = "http://www.ohloh.net/accounts/#{md5}"
      response = Nokogiri::HTML(open(request_url))
      user_name = response.at_css("title").children.inner_text.gsub!(/\s-.*/, "")
      profile_url = "http://www.ohloh.net/accounts/#{user_name}"
    end

  end
  
end
