Dir["#{Gem.searcher.find('simple_state_machine').full_gem_path}/**/tasks/*.rake"].each { |ext| load ext }

