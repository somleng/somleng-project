Dir["#{File.dirname(__FILE__)}/**/*.rb"].sort.each { |f| require f }
Dir["#{File.dirname(__FILE__)}/../app/**/*.rb"].sort.each { |f| require f }
