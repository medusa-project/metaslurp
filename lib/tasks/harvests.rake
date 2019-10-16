namespace :harvests do

  desc 'Delete a harvest'
  task :delete, [:key] => :environment do |task, args|
    Harvest.find_by_key(args[:key]).destroy!
  end

  desc 'Delete old harvests'
  task :delete_older_than, [:days] => :environment do |task, args|
    days = args[:days].to_i
    raise ArgumentError if days < 0

    Harvest.where('created_at < ?', days.days.ago).destroy_all
  end

  desc 'Delete old incomplete (new/running) harvests'
  task :delete_incomplete_older_than, [:days] => :environment do |task, args|
    days = args[:days].to_i
    raise ArgumentError if days < 0

    Harvest
        .where(status: [Harvest::Status::NEW, Harvest::Status::RUNNING])
        .where('created_at < ?', days.days.ago)
        .destroy_all
  end

end
