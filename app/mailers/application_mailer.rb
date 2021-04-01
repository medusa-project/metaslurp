class ApplicationMailer < ActionMailer::Base
  default from: "Metaslurp <#{::Configuration.instance.mail[:from]}>",
          reply_to: ::Configuration.instance.mail[:reply_to]
  layout "mailer"
end
