require 'sinatra/base'
require 'rack/test'
require 'zipruby'
require 'fileutils'

module Sinatra

	# Publisher adds a `/static` method to the app, which generates a static version of all GET routes
	# @TODO
	# Remove dependency on rack::test
	# Create gemfile, require dependencies
	module Publisher
		VERSION = "0.1.2"
	
		# options:
		# app.set :publisher_respond_with_zip, [true|false]
		# app.set :publisher_dir, 'published'
		def self.registered(app)
			mime_type :zip, 'application/zip'

			app.get '/static' do
				# app -> class
				# self -> instance
				if defined?(options.publisher_dir)
					out_dir = options.publisher_dir.start_with?('/') ? options.publisher_dir : "#{Dir.pwd}/#{options.publisher_dir}"
					zip_name = "published.zip"
				else
					out_dir = Dir.tmpdir
					zip_name = "#{options.publisher_dir.gsub(/[\/\\:]/, '_')}.zip"
				end

				out_zip = "#{out_dir}/../#{zip_name}"
				browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))

				File.delete(out_zip) if File.exists? out_zip
				FileUtils.rm_r(out_dir) if File.directory? out_dir
				FileUtils.mkdir_p(out_dir)

				app.routes['GET'].each do | route |
					# pattern, keys, conditions, block
					# see base.rb, 477
					route_name_match = route[0].to_s.match(/\/[\w-]+/)
					route_name = route_name_match ? route_name_match[0] : ''
					next if route_name == '/static'

					browser.get route_name
					html = browser.last_response.body

					if route_name.empty?
						route_name = 'index'
						output_path = "#{out_dir}/index.html"
					else
						FileUtils::mkdir_p("#{out_dir}#{route_name}")
						output_path = "#{out_dir}#{route_name}/index.html"
					end

					File.open(output_path, 'w+') {|f| f.write(html) }
				end

				if settings.static
					Dir["#{settings.public}/**"].each { |path| FileUtils.cp_r(path, out_dir) }
				end

				if defined?(options.publisher_create_zip) && options.publisher_create_zip
					Zip::Archive.open(out_zip, Zip::CREATE) do |zip|
						Dir["#{out_dir}/**/*"].each do |path|
							File.directory?(path) ? zip.add_dir(path) : zip.add_file(path, path)
						end
					end
				end
				
				options.publisher_respond_with_zip ?
					send_file("#{out_zip}", 
						:disposition => 'attachment', 
						:filename => File.basename("app_#{DateTime.now.strftime('%Y-%m-%dT%H:%M:%S')}.zip")) :
					"Files created in #{out_dir}."
			end
		end

	end
	register Publisher
end