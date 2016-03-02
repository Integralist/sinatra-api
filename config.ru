require "./api"

map('/v1') { run PageConfig::Api::V1 }
