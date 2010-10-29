require 'sinatra/base'
require 'rack/test'
require 'zip/zip'

module Sinatra

	# Publisher adds a `/static` method to the app, which generates a static version of all GET routes
	# @TODO
	# Use tmpdir, Support Zipping
	# Remove dependency on rack::test
	# Create gemfile, require dependencies
	module Publisher

		def self.registered(app)
			app.set :static, false
			app.set :out_dir, 'static'

			mime_type :zip, 'application/zip'
		
			app.get '/static' do
				# app -> class
				# self -> instance
				out_dir ||= options.out_dir ? "#{Dir.pwd}/#{options.out_dir}" : Dir.tmpdir
				browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))

				FileUtils.rm_r(out_dir) if File.directory? out_dir
				FileUtils.mkdir_p(out_dir)

				app.routes['GET'].each do | route |
					# pattern, keys, conditions, block
					# see base.rb, 477
					route_name_match = route[0].to_s.match(/\/\w+/)
					route_name = route_name_match ? route_name_match[0] : ''
					next if route_name == '/static'

					browser.get route_name
					html = browser.last_response.body

					route_name = 'index' if route_name.empty?
					# FIXME: permissions on tmpdir
					File.open("#{out_dir}/#{route_name}.html", 'w+') {|f| f.write(html) }
				end

				Zip::ZipFile::open("#{options.out_dir}/app.zip", true) { 
				   |zf| 
				   Dir["#{options.out_dir}/*"].each { |f| zf.add(f, f) } 
				}
								
				send_file "#{options.out_dir}/app.zip", :disposition => 'attachment', :filename => File.basename("app_#{DateTime.now.strftime('%Y-%m-%dT%H:%M:%S')}.zip")
				
				"Assets created in #{out_dir}."
			end
		end

	end
	register Publisher
end