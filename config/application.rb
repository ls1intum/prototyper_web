require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Prototyper
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Berlin'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.middleware.use Rack::ContentLength

    config.active_record.raise_in_transactional_callbacks = true
    config.active_job.queue_adapter = :sidekiq

    config.autoload_paths += %W(#{config.root}/app/models/releases)

    config.bamboo_options = {
      :signature_method   => 'RSA-SHA1',
      :request_token_path => '/plugins/servlet/oauth/request-token',
      :authorize_path     => '/plugins/servlet/oauth/authorize',
      :access_token_path  => '/plugins/servlet/oauth/access-token',
      :site               => ENV["bamboo_url"]
    }
  end
end
