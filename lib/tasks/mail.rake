namespace :mail do

  desc "Send a test email"
  task :test, [:recipient] => :environment do |task, args|
    MetaslurpMailer.test(args[:recipient]).deliver_now
  end

end
