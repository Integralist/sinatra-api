## Page Configuration Service

A simple Sinatra based page configuration service. 

It stores page configuration in local SQLite. Each stored page configuration consists of resource identifier and config part. It's possible to list, retrieve, create, update and delete individual page configuration. List of all configurations currently doesn't support pagination.

### Getting started

#### Install dependencies

Run `bundler`:

    $ bundle install

#### Run Migrations

    $ bundle exec rake db:migrate

    and 

    $ RACK_ENV=test bundle exec rake db:migrate

#### Launch the API server

    $ bundle exec rackup

It'll start Thin server on default port 9292.

### Tests

    $ bundle exec rspec

### IMPORTANT Assumptions

This API assumes that new page configuration is provided as well formatted JSON. This configuration *must* include `id` field which value is used to identify resource. `id` must not contain spaces or non-alphanumeric character to ensure correct operation. `id` will be sanitised at the time of resource creation to remove all non-alphanumeric characters. Other than that, configuration JSON must include at least one configuration key with appropriate value. There is no limit of number or naming convention of other configuration keys.

#### Example configuration

    {
      "id": "pageId",
      "key1": "value1",
      "key2": "value2",
      ...
      "keyN": "valueN"
    }

### Versioning

This service uses API versioning. Currently all service endpoints are namespaced with `/v1`.

### Usage

#### GET /v1/pages 

It will return collection of all stored page configuration. Currently this endpoint doesn't support pagination. 

##### Example request

    curl -H "Accept: application/json" http://localhost:9292/v1/pages

##### Example response

    {
      "page": [
        {
          "id": "foo",
          "config": {
            "value": "some value"
          }
        },
        {
          "id": "bar",
          "config": {
            "key": "value"
          }
        }
      ]
    }

##### Statuses

  `200` - successful response.

#### GET /v1/pages/:page_identifier

It will return page configuration resource for given identifier.

##### Example request

    curl -H "Accept: application/json" http://localhost:9292/v1/pages/foo

##### Example response

    {
      "page": {
        "id": "foo",
        "config": {
          "value": "some value"
        }
      }
    }

##### Errors
  `404` - returned when requested resource wasn't found.

##### Statuses
  `200` - successful response.

#### POST /v1/pages

It will create a new page configuration resource. 

##### Example request

    curl -H "Accept: application/json" \
         -X POST \
         -d '{"id": "foo","value": "I am foo"}' \ 
         http://localhost:9292/v1/pages

##### Example response

  Response should contain `Location` header with newly created resource URI.

##### Errors
  `409` - returned when resource already exists.
  `500` - returned when there was an issue when creating new resource.

##### Statuses
  `201` - returned when resource was succesfully created.


#### PUT /v1/pages/:page_identifier

It will update existing page configuration for specified resource.

##### Example request

    curl -H "Accept: application/json" \
         -X PUT \
         -d '{"id": "foo", "value": "Some new value"}' \ 
         http://localhost:9292/v1/pages/foo

##### Example response

  No content.

##### Errors
  `404` - returned when requested resource doensn't exist.
  `409` - returned when there was page identifier mismatch between updated resource and the one from new configuration ("id" field value).

##### Statuses
  `204` - No content is returned when operation was succesful.


#### DELETE /v1/pages/:page_identifier

It will delete existing page configuration for specified resource.

##### Example request

    curl -H "Accept: application/json" \
         -X DELETE \
         http://localhost:9292/v1/pages/foo

##### Example response

  No content.

##### Errors
  `404` - returned when requested resource doensn't exist.

##### Statuses
  `204` - No content is returned when operation was succesful.

