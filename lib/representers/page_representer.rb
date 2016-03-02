require 'roar/json/json_api'

module PageRepresenter
  include Roar::JSON::JSONAPI
  type :page

  property :name, as: :id
  property :config
end
