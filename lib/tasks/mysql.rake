namespace :mysql do
  desc 'Clears the Rails cache'
  task :max_allowed_packet => :environment do
    ActiveRecord::Base.connection.execute("set global max_allowed_packet=64000000;")    
  end
end
