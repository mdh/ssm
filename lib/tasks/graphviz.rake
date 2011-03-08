namespace :ssm do
  namespace :graph do
    desc 'Generate a url for a google chart for [class]'
    task :url => :environment do
      puts ENV['class'].constantize.state_machine_definition.google_chart_url
    end

    desc 'Opens the google chart in the browser for [class]'
    task :open => :environment do
      `open '#{::CGI.unescape(ENV['class'].constantize.state_machine_definition.google_chart_url)}'`
    end
  end
end
