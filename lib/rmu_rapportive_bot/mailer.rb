require 'mail'

module RMURapportiveBot
  
  module Mailer
    
    def self.config(config)
      Mail.defaults do
        retriever_method :pop3, config[:pop3]
        delivery_method :smtp, config[:smtp]
      end
    end
    
    def self.fetch_requests
      requests = Mail.all
    end
    
    def self.respond_to_request(message, response)
      validate_presence_of(message.from)
      Mail.deliver do
        to      message.from
        from    message.to
        subject message.subject
        body    response
      end
    end
    
    private
    
    def self.validate_presence_of(recipient)
      unless recipient 
        raise MissingRecipientError, "You need a recipient to send an email"
      end
    end
    
  end
end
