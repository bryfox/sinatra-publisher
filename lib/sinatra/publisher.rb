require 'sinatra/base'
require 'rack/test'
require 'zipruby'
require 'fileutils'

module Sinatra

  # Publisher adds a `/static` method to the app, which generates a static version of all GET routes
  module Publisher
    VERSION = "0.2.1"

    def define_publish_options_for(path, opts)
      pattern, keys = compile(path)
      @@publisher_options = {
        pattern.to_s.to_sym => opts
      }
    end

    # options:
    # app.set :publisher_respond_with_zip, [true|false]
    # app.set :publisher_dir, 'published'
    def self.registered(app)
      mime_type :zip, 'application/zip'
      @@publisher_options = {}

      app.get '/static' do
        # app -> class
        # self -> instance
        if defined?(settings.publisher_dir)
          out_dir = settings.publisher_dir.start_with?('/') ? settings.publisher_dir : "#{Dir.pwd}/#{settings.publisher_dir}"
          zip_name = "published.zip"
        else
          out_dir = Dir.tmpdir
          zip_name = "#{settings.publisher_dir.gsub(/[\/\\:]/, '_')}.zip"
        end

        out_zip = File.join(out_dir, '..', zip_name)
        browser = Rack::Test::Session.new(Rack::MockSession.new(app))
        paths = []
        param_placeholder = defined?(settings.param_placeholder) ? settings.param_placeholder : ':::PARAM:::'

        File.delete(out_zip) if File.exists? out_zip
        FileUtils.rm_r(out_dir) if File.directory? out_dir
        FileUtils.mkdir_p(out_dir)

        # First convert the defined routes into a collection of paths to hit
        # A route containing a param can define many paths to render
        # 
        # route: pattern, keys, conditions, block (see base.rb, 477)
        app.routes['GET'].each do | route |
          route_name_match = 
            route[0].to_s.                           # Stringified route pattern
            gsub(/\(\[.+\]\+\)/, param_placeholder). # Placeholder for splats & params
            gsub(/\\\//, '/').                       # remove escaped slashes
            match(/\/[:\/\w-]+/)                     # 
          route_name = route_name_match ? route_name_match[0] : ''
          next if route_name == '/static'
          param_values = @@publisher_options[route[0].to_s.to_sym]
          paths.concat((param_values || ['']).collect {|param| route_name.sub(param_placeholder, param)})
        end
        
        # Now render each path
        paths.each do | path |
          browser.get path
          next unless browser.last_response.ok?
          html = browser.last_response.body
          if path.empty?
            path = 'index'
            output_path = "#{out_dir}/index.html"
          else
            FileUtils::mkdir_p("#{out_dir}#{path}")
            output_path = "#{out_dir}#{path}/index.html"
          end
          File.open(output_path, 'w+') {|f| f.write(html) }
        end

        if settings.static
          Dir["#{settings.public_folder}/**"].each { |path| FileUtils.cp_r(path, out_dir) }
        end

        if defined?(settings.publisher_create_zip) && settings.publisher_create_zip
          Zip::Archive.open(out_zip, Zip::CREATE) do |zip|
            Dir["#{out_dir}/**/*"].each do |path|
              File.directory?(path) ? zip.add_dir(path) : zip.add_file(path, path)
            end
          end
        end
        
        settings.publisher_respond_with_zip ?
          send_file("#{out_zip}", 
            :disposition => 'attachment', 
            :filename => File.basename("app_#{DateTime.now.strftime('%Y-%m-%dT%H:%M:%S')}.zip")) :
          "Files created in #{out_dir}."
      end
    end

    private
    def compile(path)
      keys = []
      if path.respond_to? :to_str
        special_chars = %w{. + ( )}
        pattern =
          path.to_str.gsub(/((:\w+)|[\*#{special_chars.join}])/) do |match|
            case match
            when "*"
              keys << 'splat'
              "(.*?)"
            when *special_chars
              Regexp.escape(match)
            else
              keys << $2[1..-1]
              "([^/?&#]+)"
            end
          end
        [/^#{pattern}$/, keys]
      elsif path.respond_to?(:keys) && path.respond_to?(:match)
        [path, path.keys]
      elsif path.respond_to? :match
        [path, keys]
      else
        raise TypeError, path
      end
    end

  end
  register Publisher
  # helpers Publisher::Helpers
end