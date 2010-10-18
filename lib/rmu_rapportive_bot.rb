$LOAD_PATH << File.join(File.expand_path(File.dirname(__FILE__)),'rmu_rapportive_bot')

require 'mailer'
require 'network_profile'
require 'yaml'

module RMURapportiveBot
  
  DEFAULT_NETWORKS = ["flickr", "github", "ohloh"]
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  def self.engage
    config_path = File.join(File.expand_path(File.dirname(__FILE__)),'..','config')
    config = YAML.load_file(File.join(config_path,'config.yml'))
    p config
    Mailer.config(config["mail"])
    
    Mailer.fetch_requests.each do |request|
      params = parse_request(request.body.to_s)
      np = NetworkProfile.new(config["api"])
      profiles = np.search(params)
      response = compose_response(profiles)
      Mailer.respond_to_request(request, response)
    end
  end
  
  private
  
  def self.parse_request(text)
    params = Hash.new
    params[:email] = extract_email(text)
    params[:networks] = extract_networks(text) || DEFAULT_NETWORKS
    params
  end

  def self.extract_email(text)    
    text.split(/\s+/).delete_if do |term|
      !term.match(EMAIL_REGEX)
    end.first
  end

  def self.extract_networks(text)    
    text.split(/\s+/).map(&:upcase).map(&:downcase).delete_if do |term|
      term.match(EMAIL_REGEX)
    end
  end
  
  def self.compose_response(profiles)
    response = ""
    profiles.each do |network, url|
      response << "#{network}: #{url}\n"
    end
    response
  end
end
