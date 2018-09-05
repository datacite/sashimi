namespace :reports do

  desc 'Index all reports'
  task :index => :environment do
    reports = Report.all
    reports.each do |report|
      report.queue_report
      puts "Queued indexing for #{report.uid} Data Usage Reports."
    end

  end
end
