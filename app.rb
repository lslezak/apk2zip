require "sinatra/base"
require "i18n"
require "i18n/backend/fallbacks"

require_relative "apk"

# I18n setup
I18n.available_locales = [:en, :cs, :sk]
I18n.default_locale = :en

# allow using fallbacks
I18n.fallbacks[:sk] = [:cs, :en]
I18n.fallbacks[:cs] = [:cs, :en]
I18n.enforce_available_locales = false

Zip.default_compression = Zlib::BEST_COMPRESSION

class App < Sinatra::Base
  use Rack::Locale

  configure do
    enable :logging
    # disable temple caching, breaks translations 
    enable :reload_templates
    I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
  end
  
  helpers do
    def find_template(views, name, engine, &block)
      logger.info "Loading template for #{name}"
      # then try views/<name>.<lang>.erb files
      I18n.fallbacks[I18n.locale].each do |locale|
        super(views, "#{name}.#{locale}", engine, &block)
      end
      # then use the generic views/<name>.erb file
      super(views, name, engine, &block)
    end
  end

  before do
    logger.info "Using locale #{I18n.locale}"
    logger.info "Params: #{params.inspect}"
    logger.info "Headers: #{headers.inspect}"
  end

  get "/" do
    erb :index
  end

  not_found do
    erb :not_found
  end
  
  post "/convert" do
    logger.info "Starting conversion..."

    unless params[:apkfile] && params[:apkfile][:tempfile]
      return [422, erb(:error, :layout => false)]
    end

    begin
      apk = ApkReader.new(params[:apkfile][:tempfile].read)
    rescue Zlib::GzipFile::Error
      return [422, erb(:error, :layout => false)]
    end

    zip = ZipMaker.new(apk.content)

    filename = params[:apkfile][:filename]
    if filename.end_with?(".apk") || filename.end_with?(".APK")
      newfile = filename[0..-4] + "zip"
    else
      newfile = filename + ".zip"
    end

    attachment newfile
    content_type :zip

    zip.build
  end
end
