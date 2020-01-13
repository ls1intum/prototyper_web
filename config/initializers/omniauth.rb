module OmniAuth
  module Strategies
    # tell OmniAuth to load our strategy
    autoload :Bamboo, 'omniauth/strategies/bamboo_strategy'
  end
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :bamboo, ENV["bamboo_comsumer"],
    OpenSSL::PKey::RSA.new(IO.read(Rails.root.join("private_key.pem"))),
    :client_options => { :site => ENV["bamboo_url"] }
end
