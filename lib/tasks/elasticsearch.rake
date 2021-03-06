namespace :elasticsearch do

  namespace :indexes do

    desc 'Create an index with the current index schema'
    task :create, [:name] => :environment do |task, args|
      ElasticsearchClient.instance.create_index(args[:name])
    end

    desc 'Create an index alias'
    task :create_alias, [:index_name, :alias_name] => :environment do |task, args|
      index_name = args[:index_name]
      alias_name = args[:alias_name]
      client     = ElasticsearchClient.instance
      if client.index_exists?(alias_name)
        client.delete_index_alias(index_name, alias_name)
      end
      client.create_index_alias(index_name, alias_name)
    end

    desc 'Delete an index by name'
    task :delete, [:name] => :environment do |task, args|
      ElasticsearchClient.instance.delete_index(args[:name])
    end

    desc 'Delete an index alias by name'
    task :delete_alias, [:index_name, :alias_name] => :environment do |task, args|
      ElasticsearchClient.instance.
          delete_index_alias(args[:index_name], args[:alias_name])
    end

    desc 'List indexes'
    task :list => :environment do
      puts ElasticsearchClient.instance.indexes
    end

    # N.B.: This is used in the testing Dockerfile
    desc 'Recreate an index with the current index schema'
    task :recreate, [:name] => :environment do |task, args|
      client = ElasticsearchClient.instance
      client.delete_index(args[:name], raise_on_not_found: false)
      client.create_index(args[:name])
    end

    desc 'Copy the current index into the latest index'
    task :reindex, [:from_index, :to_index] => :environment do |task, args|
      ElasticsearchClient.instance.reindex(args[:from_index], args[:to_index])
    end

  end

  desc 'Execute an arbitrary query'
  task :query, [:file] => :environment do |task, args|
    file_path = File.expand_path(args[:file])
    json      = File.read(file_path)
    puts ElasticsearchClient.instance.query(json)

    config = Configuration.instance
    curl_cmd = sprintf('curl -X POST -H "Content-Type: application/json" '\
        '"%s/%s/_search?pretty&size=0" -d @"%s"',
                       config.elasticsearch_endpoint,
                       config.elasticsearch_index,
                       file_path)
    puts 'cURL equivalent: ' + curl_cmd
  end

  desc 'Refresh the current index'
  task :refresh => :environment do |task, args|
    ElasticsearchClient.instance.refresh
  end

end
