require 'rubygems'
require 'bundler'

Bundler.require(:default)
Bundler.require(Sinatra::Base.environment)

require "sinatra/reloader" if development?
require "sinatra/activerecord"

$: << File.expand_path('../', __FILE__)
$: << File.expand_path('../lib', __FILE__)

require 'models'
require 'representers'
require 'routes'

module PageConfig
  module Api 
    class Base < Sinatra::Base
      register Sinatra::ActiveRecordExtension

      configure :development do
        register Sinatra::Reloader
      end

      configure do
        set :database, { 
          adapter: "sqlite3", 
          database: test? ? "page_config_test.sqlite3" : "page_config.sqlite3"
        }
        disable :method_override
        disable :static
      end

      configure :development, :staging do
        database.logger = Logger.new(STDOUT)
        database.logger.level = Logger::INFO
      end

      not_found do
        {error: 'Invalid URL.'}.to_json
      end
    end

    class V1 < Base
      use Routes::V1::Pages
    end
  end
end
