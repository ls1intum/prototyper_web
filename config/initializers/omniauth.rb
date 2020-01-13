module OmniAuth
  module Strategies
    # tell OmniAuth to load our strategy
    autoload :Bamboo, 'omniauth/strategies/bamboo_strategy'
  end
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :bamboo, Rails.application.secrets.bamboo_consumer,
    OpenSSL::PKey::RSA.new(IO.read(Rails.root.join("private_key.pem"))),
    :client_options => { :site => Rails.application.secrets.bamboo_url }
end
