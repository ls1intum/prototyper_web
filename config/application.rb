require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Prototyper
  class Application < Rails::Application
    config.autoload_paths += %W(#{config.root}/app/models/releases)
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0

    config.bamboo_options = {
      :signature_method   => 'RSA-SHA1',
      :request_token_path => '/plugins/servlet/oauth/request-token',
      :authorize_path     => '/plugins/servlet/oauth/authorize',
      :access_token_path  => '/plugins/servlet/oauth/access-token',
      :site               => Rails.application.secrets.bamboo_url
    }
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
