Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  config.i18n.available_locales = :en

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = true

  # Do not eager load code on boot.
  config.eager_load = true

  # Show full error reports and disable caching.
  # config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.serve_static_files = true

  # Don't care if the mailer can't send.
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log
  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  config.log_level = :warn
  #config.force_ssl = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = false

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  host = 'localhost:3000'
  config.action_mailer.default_url_options = { :protocol => 'http', :host => host }

  # Change smtp settings
  config.action_mailer.smtp_settings = {
    :user_name => Rails.application.secrets.mail_username,
    :password => Rails.application.secrets.mail_password,
    :address => Rails.application.secrets.mail_address,
    :domain => $FILL_ME,
    :port => $FILL_ME,
    :authentication => :cram_md5
  }
  
end
