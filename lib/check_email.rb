require 'mail'

options = { :address              => "pop.gmail.com",
            :port                 => 995,
            :user_name            => 'rmu.rapportive.bot@gmail.com',
            :password             => 'kh0jyakh0jai',
            :enable_ssl           => true }

Mail.defaults do
  retriever_method :pop3, options
end

def parse_mail(mail)
#  puts "Envelope From: #{mail.envelope_from}"
#  puts "From Addrs: #{mail.from_addrs}"
  puts "From: #{mail.from}"
#  puts "Sender: #{mail.sender}"
  puts "To: #{mail.to}"
#  puts "CC: #{mail.cc}"
  puts "Subject: #{mail.subject}"
#  puts "Date: #{mail.date.to_s}"
#  puts "Message ID: #{mail.message_id}"
  puts "Body Decoded: #{mail.body.decoded}"
  puts "Body Encoded: #{mail.body.encoded}"
  
  puts "Search Parameters: #{extract_search_parameters(mail.body.decoded)}"
end

def check_mail
  emails = Mail.all
  emails.each do |email|
    parse_mail(email)
  end
end

def extract_search_parameters(body)
  { :email => extract_email(body),
    :networks => extract_networks(body) }
end

def extract_email(text)
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  text.split(/\s+/).delete_if do |term|
    !term.match(email_regex)
  end
end

def extract_networks(text)
  allowed_networks = ['twitter', 'facebook', 'linkedin', 'github', 'flickr', 'skype']
  
  text.split(/\s+/).delete_if do |term|
    !allowed_networks.map(&:upcase).include?(term.upcase)
  end
end

check_mail
