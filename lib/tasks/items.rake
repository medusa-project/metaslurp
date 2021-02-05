namespace :items do

  desc 'Delete all items from a content service whose harvest key does not match the given key'
  task :delete_except_from_harvest, [:key] => :environment do |task, args|
    harvest = Harvest.find_by_key(args[:key])
    raise ArgumentError, 'No such harvest' unless harvest

    harvest.purge_unharvested_items(wait_for_completion: false)
  end

  desc 'Delete all items from a content service'
  task :delete_from_service, [:key] => :environment do |task, args|
    service = ContentService.find_by_key(args[:key])
    raise ArgumentError, 'No such service' unless service

    puts "\n" + service.delete_all_items
  end

  desc 'Delete items older than n days from a content service'
  task :delete_older_than, [:key, :days] => :environment do |task, args|
    service = ContentService.find_by_key(args[:key])
    raise ArgumentError, 'No such service' unless service

    puts "\n" + service.delete_items_older_than(args[:days].to_i)
  end

end
