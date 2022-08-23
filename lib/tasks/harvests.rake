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

  desc 'List running harvests'
  task :list_running => :environment do |task, args|
    include ActionView::Helpers::DateHelper
    include ActionView::Helpers::NumberHelper
    puts "KEY\t\t\t\t\tSERVICE\t\tTOTAL\t\tRUNTIME\t\tPROGRESS\tIPM\tSUCCEEDED\tFAILED\t\tETA"
    Harvest.where(status: Harvest::Status::RUNNING).order(updated_at: :desc).each do |harvest|
      puts "#{harvest.key}\t"\
           "#{harvest.content_service.name.truncate(12)}\t"\
           "#{number_with_delimiter(harvest.canonical_num_items)}\t\t"\
           "#{distance_of_time_in_words(harvest.created_at, Time.now)}\t"\
           "#{(harvest.progress * 100).round(2)}%\t\t"\
           "#{number_with_delimiter((harvest.items_per_second * 60).round)}\t"\
           "#{number_with_delimiter(harvest.num_succeeded)}\t\t"\
           "#{number_with_delimiter(harvest.num_failed)}\t\t"\
           "#{time_ago_in_words(harvest.estimated_completion)}\n"
    end
  end

end
