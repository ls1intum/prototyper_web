module UsersHelper

  # Returns the Gravatar for the given user.
  def gravatar_for(user)
    email = user.nil? ? "" : user.email.downcase
    gravatar_id = Digest::MD5::hexdigest(email)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}"
    username = user.nil? ? "Anonymous" : user.name
    image_tag(gravatar_url, alt: username, class: "gravatar")
  end

  def check_tum_id_password(tum_id, password)
    dict = call_api tum_id, password
    if dict["display-name"].nil?
      return false
    end
    return true
  end

  def register_with_tum_id(tum_id, password)
    dict = call_api tum_id, password
    name = dict["display-name"]
    email = dict["email"]
    return nil if name.nil?

    if (existingUser = User.find_by(email: email))
      existingUser.name = name
      existingUser.activated = true
      existingUser.activated_at = Time.zone.now
      existingUser.tum_id = tum_id
      existingUser.save
      return existingUser
    end

    return User.create(name: name, email: email, tum_id: tum_id, activated: true, activated_at: Time.zone.now)
  end

  private
    def call_api(tum_id, password)
      begin
        endpoint = "#{Rails.application.secrets.jira_auth_endpoint}?username=#{tum_id}"
        response = RestClient.post endpoint, "<?xml version=\"1.0\" encoding=\"UTF-8\"?><password><value>#{password}</value></password>", {content_type: :xml, accept: :json, Authorization: "Basic #{Rails.application.secrets.jira_auth_token}"}
        dict = JSON.parse(response)
      rescue => e
        dict = Hash.new
      end

      return dict
    end
end
