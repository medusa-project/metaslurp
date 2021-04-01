# frozen_string_literal: true

class MetaslurpMailer < ApplicationMailer
  # This address is not arbitrary;
  # see https://answers.uillinois.edu/illinois/page.php?id=47888
  NO_REPLY_ADDRESS = "no-reply@illinois.edu"

  def error(error_text)
    @error_text = error_text
    mail(reply_to: NO_REPLY_ADDRESS,
         to:       ::Configuration.instance.admin_emails,
         subject:  "#{subject_prefix} System Error")
  end

  ##
  # Used to test email delivery. See also the `mail:test` rake task.
  #
  def test(recipient)
    mail(to: recipient, subject: "#{subject_prefix} Hello from Metaslurp")
  end

  private

  def subject_prefix
    "[#{Rails.env.to_s.upcase}: Metaslurp]"
  end
end
