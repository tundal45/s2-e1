require 'mail'

options = { :address              => "smtp.gmail.com",
            :port                 => 587,
            :user_name            => 'rmu.rapportive.bot@gmail.com',
            :password             => 'kh0jyakh0jai',
            :authentication       => 'plain',
            :enable_starttls_auto => true }

Mail.defaults do
  delivery_method :smtp, options
end

MissingRecipientError = Class.new(StandardError)

def send_mail(options = {})
  recipient    = options.fetch(:to, nil)
  validate_presence_of(recipient)
  mail         = Mail.new
  mail.to      = recipient  
  mail.from    = options.fetch(:from, 'rmu.rapportive.clone@gmail.com')
  mail.subject = options.fetch(:subject, "")
  mail.body    = options.fetch(:body, "")
  mail.deliver!
end

def validate_presence_of(recipient)
  unless recipient 
    raise MissingRecipientError, "You need a recipient to send an email"
  end
end

send_mail :to => "rmu.rapportive.bot@gmail.com",
          :subject => "One more time",
          :body => "tundal45@gmail.com twitter facebook linkedin github nonexistent blah blah blah"
