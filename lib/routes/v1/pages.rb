require 'digest/sha1'

module PageConfig
  module Routes
    module V1
      class Pages < Sinatra::Application

        before do
          unless request.accept?('application/json')
            halt 406, msg('Invalid Accept header.')
          end
        end

        before do
          content_type 'application/json'
        end

        before do
          page_identifier = request.path_info.split('/')[2]
          pass unless page_identifier
          @page = Page.find_by(name: page_identifier)
          halt 404, msg("Resource doesn't exist.") if @page.nil?
        end

        get '/pages/?' do
          pages = Page.order(updated_at: :desc)
          set_cache_headers(pages)
          PageRepresenter.for_collection.prepare(pages).to_json
        end

        get '/pages/:name/?' do
          set_cache_headers(@page)
          PageRepresenter.prepare(@page).to_json
        end

        post '/pages/?' do
          config = ::MultiJson.decode(request.body)
          begin
            page_config = Page.create!(name: config.delete('id'), config: config)
          rescue ActiveRecord::RecordNotUnique => e
            halt 409, msg("Page configuration already exist.")
          rescue => e
            halt 500, msg("Resource could't be created.")
          end
          response.headers['Location'] = "/pages/#{page_config.name}"
          status 201
        end

        put '/pages/:name/?' do
          config = ::MultiJson.decode(request.body)
          if params[:name] != config.delete('id')
            halt 409, msg("Page identifier mismatch. Resource ID and configuration page ID are different.")
          end
          @page.update(config: config)
          status 204
        end

        delete '/pages/:name' do
          @page.delete
          status 204
        end

        private

        def msg(message)
          {msg: message}.to_json
        end

        def set_cache_headers(resource)
          resource = resource.first if resource.is_a?(ActiveRecord::Relation)
          return if resource.nil?
          cache_control :public, :must_revalidate
          last_modified resource.updated_at
          etag Digest::SHA1.hexdigest(resource.inspect)
        end

      end
    end
  end
end
