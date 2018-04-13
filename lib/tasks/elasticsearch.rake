namespace :elasticsearch do

  namespace :indexes do

    desc 'Create all latest indexes'
    task :create_latest => :environment do |task, args|
      ElasticsearchIndex::ALL_INDEX_TYPES.each do |type|
        create_latest_index(type)
      end
    end

    desc 'Print the current schema version'
    task :current_version => :environment do
      puts ElasticsearchIndex.current_version
    end

    desc 'Delete an index by name'
    task :delete, [:name] => :environment do |task, args|
      ElasticsearchClient.instance.delete_index(args[:name])
    end

    desc 'Delete all current indexes'
    task :delete_current => :environment do |task, args|
      ElasticsearchIndex::ALL_INDEX_TYPES.each do |type|
        delete_current_index(type)
      end
    end

    desc 'Delete all latest indexes'
    task :delete_latest => :environment do |task, args|
      if ElasticsearchIndex.current_version != ElasticsearchIndex.latest_version
        ElasticsearchIndex::ALL_INDEX_TYPES.each do |type|
          delete_latest_index(type)
        end
      else
        STDERR.puts 'Latest index version is the same as the current version. '\
            'Use delete_current if you\'re sure you want to delete them.'
      end
    end

    desc 'List indexes'
    task :list => :environment do |task, args|
      puts ElasticsearchClient.instance.indexes
    end

    desc 'Migrate to the latest schema_version'
    task :migrate => :environment do |task, args|
      ElasticsearchIndex.migrate_to_latest
    end

    desc 'Print schema versions'
    task :versions => :environment do |task, args|
      puts "Current: #{ElasticsearchIndex.current_version}"
      puts "Latest:  #{ElasticsearchIndex.latest_version}"
    end

  end

  desc 'Execute an arbitrary query'
  task :query, [:index, :file] => :environment do |task, args|
    index = args[:index]
    file_path = File.expand_path(args[:file])
    json = File.read(file_path)
    puts ElasticsearchClient.instance.query(index, json)

    curl_cmd = sprintf('curl -X POST -H "Content-Type: application/json" '\
        '"%s/%s/_search?pretty=true&size=0" -d @"%s"',
                       Configuration.instance.elasticsearch_endpoint,
                       index,
                       file_path)
    puts 'cURL equivalent: ' + curl_cmd
  end

  def create_current_index(type)
    index = ElasticsearchIndex.current(type)
    ElasticsearchClient.instance.create_index(index)
  end

  def delete_current_index(type)
    index = ElasticsearchIndex.current(type)
    ElasticsearchClient.instance.delete_index(index.name)
  end

  def create_latest_index(type)
    index = ElasticsearchIndex.latest(type)
    ElasticsearchClient.instance.create_index(index)
  end

  def delete_latest_index(type)
    index = ElasticsearchIndex.latest(type)
    ElasticsearchClient.instance.delete_index(index.name)
  end

end
