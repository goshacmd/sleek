require 'sleek'
require 'database_cleaner'

Mongoid.configure do |config|
  config.connect_to('sleek_test', consistency: :strong)
end

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.orm = 'mongoid'
  end

  config.before(:each) do
    DatabaseCleaner.clean
  end
end
