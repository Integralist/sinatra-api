require 'spec_helper'

RSpec.describe PageConfig::Api::V1 do

  describe 'before filters' do

    context "when client doesn't specify correct Accept header" do
      it "returns 406 with appropriate message" do
        get "/pages", {}, {"HTTP_ACCEPT"=>"text/plain"}

        expect(last_response.body).to eq({msg: "Invalid Accept header."}.to_json)
        expect(last_response.status).to eq 406
      end
    end

    context "with correct Accept header" do
      it "allows to call underlying actions" do
        get "/pages", {}, {"HTTP_ACCEPT"=>"application/json"}

        expect(last_response.status).to eq 200
      end
    end

    it "sets correct content_type response header" do
      get "/pages"

      expect(last_response.header["Content-Type"]).to eq "application/json"
      expect(last_response.status).to eq 200
    end

    context "when page identifier is in the path" do
      let(:identifier) { "foo1" }

      context "and resource present" do
        before do
          Page.create(name: "foo1", config: {key1: "val1"})
        end

        it "retrieves page object based on that ID" do
          expect(Page).to receive(:find_by).with(name: identifier).and_call_original
          
          get "/pages/#{identifier}"

          expect(last_response.status).to eq 200
        end
      end

      context "and resource doesn't exist" do
        it "returns 404 with appropriate message" do
          expect(Page).to receive(:find_by).with(name: identifier) { nil }

          get "/pages/#{identifier}"
          
          expect(last_response.status).to eq 404
        end
      end
    end

  end

  describe "GET /pages" do

    context "when there is no configuration stored" do
      it "returns an empty list all configs" do
        get "/pages"

        expect(last_response.body).to eq({page: []}.to_json)
        expect(last_response.status).to eq 200
      end
    end

    context "when there is at least 1 page configuration" do
      before do
        Page.create(name: "foo1", config: {key1: "val1"})
        Page.create(name: "foo2", config: {key2: "val2"})
      end

      let(:expected_output) do
        {
          page: [
            {id: "foo2", config: {key2: "val2"}},
            {id: "foo1", config: {key1: "val1"}}
          ]
        }.to_json
      end

      it "returns all stored page configs" do
        get "/pages"

        expect(last_response.body).to eq expected_output
        expect(last_response.status).to eq 200
      end

      it "sets ETag, Last-Modified and Cache-Control headers" do
        get "/pages"

        expect(last_response.header["Cache-Control"]).to eq "public, must-revalidate"
        expect(last_response.header["Last-Modified"]).to_not be_empty
        expect(last_response.header["ETag"]).to_not be_empty
      end
    end
  end

  describe "GET /pages/foo" do

    context "when there is no resource of this ID" do
      it "returns 404 with appropriate message" do
        get "/pages/foo"

        expect(last_response.body).to eq({msg: "Resource doesn't exist."}.to_json)
        expect(last_response.status).to eq 404
      end
    end

    context "when configuration for given page ID exists" do
      before do
        Page.create(name: "foo", config: {key1: "val1"})
      end

      let(:expected_output) do
        {
          page: {
            id: "foo",
            config: {
              key1: "val1"
            }
          }
        }.to_json
      end

      it "returns requested configuration" do
        get "/pages/foo"

        expect(last_response.body).to eq expected_output
        expect(last_response.status).to eq 200
      end

      it "sets ETag, Last-Modified and Cache-Control headers" do
        get "/pages/foo"

        expect(last_response.header["Cache-Control"]).to eq "public, must-revalidate"
        expect(last_response.header["Last-Modified"]).to_not be_empty
        expect(last_response.header["ETag"]).to_not be_empty
      end

    end

  end

  describe "POST /pages" do
    let(:configuration) do
      {id: 'pageid', val1: 'val1', val2: 'val2'}.to_json
    end

    context "when configuration already exist for given page" do
      before do
        post "/pages", configuration
      end

      it "returns 409 with appropriate message" do
        post "/pages", configuration

        expect(last_response.body).to eq({msg: "Page configuration already exist."}.to_json)
        expect(last_response.status).to eq 409
      end
    end

    context "when there was an exception during configuration creation" do
      it "return 500 with appropriate message" do
        allow(Page).to receive(:create!).and_raise(ActiveRecord::StatementInvalid, "error desc")

        post "/pages", {key1: 'val1'}.to_json

        expect(last_response.body).to eq({msg: "Resource could't be created."}.to_json)
        expect(last_response.status).to eq 500
      end
    end

    context "when there was no errors" do
      it "creates a new configuration and sets Location header" do
        post "/pages", configuration

        expect(last_response.header["Location"]).to eq "/pages/pageid"
        expect(last_response.status).to eq 201
      end
    end

  end

  describe 'PUT /pages/foo' do
    let(:page) { Page.create(name: 'foo', config: {key0: 'val0'}) }

    context "when there is a mismatch between update resource ID and page ID in new configuration" do
      let(:new_config) do
        {
          id: 'bar',
          val1: 'key1'
        }.to_json
      end

      it "raturns 409 with appropriate message" do
        allow(Page).to receive(:find_by).with(name: 'foo') { page }

        put '/pages/foo', new_config

        expect(last_response.body).to eq({msg: "Page identifier mismatch. Resource ID and configuration page ID are different."}.to_json)
        expect(last_response.status).to eq 409
      end
    end

    context "for valid new configuration" do
      let(:new_config) do
        {
          id: 'foo',
          val1: 'key1'
        }.to_json
      end

      it "updates existing config and returns 204" do
        allow(Page).to receive(:find_by).with(name: 'foo') { page }
        expect(page).to receive(:update).with(config: {'val1' => 'key1'})

        put '/pages/foo', new_config

        expect(last_response.status).to eq 204
      end
    end

  end

  describe 'DELETE /pages/foo' do
    let(:page) { Page.create(name: 'foo', config: {key0: 'val0'}) }
    
    it "removes existing page configuration" do
      allow(Page).to receive(:find_by).with(name: 'foo') { page }
      expect(page).to receive(:delete)

      delete '/pages/foo'

      expect(last_response.status).to eq 204
    end
  end

end
