require 'mail'

options = { :address              => "smtp.gmail.com",
            :port                 => 587,
            :user_name            => 'rmu.rapportive.clone@gmail.com',
            :password             => 'whereswaldo',
            :authentication       => 'plain',
            :enable_starttls_auto => true }

Mail.defaults do
  delivery_method :smtp, options
end

def send_email(options = {})
  begin
    mail         = Mail.new
    mail.to      = options.fetch(:to)
    mail.from    = options.fetch(:from, 'rmu.rapportive.clone@gmail.com')
    mail.subject = options.fetch(:subject, "")
    mail.body    = options.fetch(:body, "")
    mail.deliver!
  rescue KeyError => e
    puts "You must specify who you want to send the email to in order to send an email"
    puts e.message
    puts e.backtrace.inspect
  rescue ArgumentError => e
    puts e.message
    p e.backtrace
  end
end
