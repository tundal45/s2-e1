require 'rubygems'
require 'json'
require 'open-uri'
require 'nokogiri'
require 'digest/md5'

module RMURapportiveBot
  
  class NetworkProfile
    attr_accessor :config
    
    def initialize(config)
      puts config
      @config = config
    end
    
    def search(params)
      ret_hash = Hash.new
      params[:networks].each do |network|
        ret_hash[network] = case network
        when 'flickr'
          flickr = FlickrProfile.new(@config[:flickr])
          flickr.search(params[:email])
        when 'github'
          github = GitHubProfile.new(@config[:github])
          github.search(params[:email])
        when 'ohloh'
          ohloh = OhLohProfile.new(@config[:ohloh])
          ohloh.search(params[:email])
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
    
    def initialize(config)
      @config = config
    end
    
    def search(email)
      request_url = "#{@config[:api_base_url]}method=#{@config[:email_method]}&api_key=#{@config[:api_key]}&find_email=#{email}"
      response = Nokogiri::XML(open(request_url))
      
      if response.at_css("rsp").attributes["stat"].value.eql?("ok")
        nsid = response.at_css("user").attributes["nsid"].inner_text
        request_url = "#{@config[:api_base_url]}method=#{@config[:profile_method]}&api_key=#{@config[:api_key]}&user_id=#{nsid}"
        
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
    
    def initialize(config)
      @config = config
    end
      
    def search(email)
      request_url = "#{@config[:api_base_url]}#{email}"
      user_name = JSON.parse(open(request_url).read)["user"]["login"]
      profile_url = "#{@config[:profile_base_url]}#{user_name}"
    end    
  end
  
  class OhLohProfile < NetworkProfile
    
    def initialize(config)
      @config = config
    end
      
    def search(email)
      md5 = Digest::MD5.hexdigest(email)
      request_url = "#{@config[:profile_base_url]}#{md5}"
      response = Nokogiri::HTML(open(request_url))
      user_name = response.at_css("title").children.inner_text.gsub!(/\s-.*/, "")
      profile_url = "#{@config[:profile_base_url]}#{user_name}"
    end
  end  
end
