namespace :items do

  desc 'Delete all items from a content service'
  task :delete_from_service, [:key] => :environment do |task, args|
    service = ContentService.find_by_key(args[:key])
    raise ArgumentError, 'No such service' unless service

    puts "\n" + service.delete_all_items
  end

end