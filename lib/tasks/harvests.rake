namespace :harvests do

  desc 'Clear old harvests'
  task :clear_older_than, [:days] => :environment do |task, args|
    days = args[:days].to_i
    raise ArgumentError if days < 0

    Harvest.where('created_at < ?', days.days.ago).destroy_all
  end

end
