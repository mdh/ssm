namespace :ssm do
  namespace :graph do
    desc 'Generate a url for a google chart. You must specify class=ClassName'
    task :url => :environment do
      if clazz = ENV['class']
        puts clazz.constantize.state_machine_definition.google_chart_url
      else
        puts "Missing argument: class. Please specify class=ClassName"
      end
    end

    desc 'Opens the google chart in your browser. You must specify class=ClassNAME'
    task :open => :environment do
      if clazz = ENV['class']
        `open '#{::CGI.unescape(clazz.constantize.state_machine_definition.google_chart_url)}'`
      else
        puts "Missing argument: class. Please specify class=ClassName"
      end
    end
  end
end
