require 'json'
require 'omniauth-oauth'

module OmniAuth
  module Strategies
    class Bamboo < OmniAuth::Strategies::OAuth
      option :client_options, Rails.application.config.bamboo_options

      uid{ user_info['name'] }

      info do
        {
          nickname:  user_info['name'],
          email:     user_info['email'],
          name:      user_info['fullName']
        }
      end

      credentials do
        if access_token.params.has_key?(:oauth_expires_in)
          {
            "expires"    => true,
            "expires_at" => (Time.now + (access_token.params[:oauth_expires_in].to_i / 1000)).to_i
          }
        end
      end

      def user_info
        @user_info ||= MultiJson.decode(access_token.get('/rest/api/latest/currentUser', { 'Accept'=>'application/json' }).body)
      rescue ::Errno::ETIMEDOUT
        raise ::Timeout::Error
      end
    end
  end
end
