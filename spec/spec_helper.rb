ENV['RACK_ENV'] = 'test'

require "./api"

RSpec.configure do |config|
  include Rack::Test::Methods
  def app() described_class end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation  # clean DB of any leftover data
    DatabaseCleaner.strategy = :transaction # rollback transactions between each test
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.warnings = true

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  config.profile_examples = 10

  config.order = :random

  Kernel.srand config.seed
end
