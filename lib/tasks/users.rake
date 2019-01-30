namespace :users do

  desc 'Create a user'
  task :create, [:username] => :environment do |task, args|
    user = User.new(username: args[:username])
    user.roles << Role.find_by_key('admin')
    user.save!

    puts "User #{args[:username]} created and added to the admin role."
  end

end
