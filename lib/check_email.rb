require 'mail'

options = { :address              => "pop.gmail.com",
            :port                 => 995,
            :user_name            => 'rmu.rapportive.clone@gmail.com',
            :password             => 'whereswaldo',
            :enable_ssl           => true }

Mail.defaults do
  retriever_method :pop3, options
end

def parse_mail(mail)
  puts "Envelope From: #{mail.envelope_from}"
  puts "From Addrs: #{mail.from_addrs}"
  puts "From: #{mail.from}"
  puts "Sender: #{mail.sender}"
  puts "To: #{mail.to}"
  puts "CC: #{mail.cc}"
  puts "Subject: #{mail.subject}"
  puts "Date: #{mail.date.to_s}"
  puts "Message ID: #{mail.message_id}"
  puts "Body Decoded: #{mail.body.decoded}"
  puts "Body Encoded: #{mail.body.encoded}"
end

def check_mail
  emails = Mail.all
  emails.each do |email|
    parse_mail(email)
  end
end

check_mail
