module SlackHelper
  require 'uri'

  SLACK_API_URL = "https://slack.com/api/chat.postMessage"
  SLACK_API_TOKEN = Rails.application.secrets.slack_api_token

  def send_new_release_creation_notification(app, release)
    title = "New release created"
    text = "<#{app_release_url(app, release)}|Version #{release.version}> of #{app.name} has been created."
    fallback = "Version #{release.version} of #{app.name} has been created."
    return call_api SLACK_API_URL, app.slack_channel, title, text, fallback, color_for_release(release), nil
  end

  def send_new_release_submission_notification(app, release, group, user)
    title = "New release submission"
    text = "<#{app_release_url(app, release)}|Version #{release.version}> of #{app.name} has been released by #{user.name} to #{group.name}."
    fallback = "Version #{release.version} of #{app.name} has been released to #{group.name}."
    return call_api SLACK_API_URL, app.slack_channel, title, text, fallback, color_for_release(release), nil
  end

  def send_new_feedback_notification(app, release, feedback)
    username = feedback.user.nil? ? (feedback.username.present? ? feedback.username : "Anonymous") : feedback.user.name
    title = "Version #{release.version} of #{app.name} got new feedback"
    text = "#{username}: *#{feedback.title}*\n#{feedback.text}\n<#{app_release_feedbacks_url(app, release)}|See feedback>"
    fallback = "#{username}: #{feedback.title}\n#{feedback.text}"
    image_url = feedback.screenshot.url.nil? ? nil : (URI.parse(root_url) + feedback.screenshot.url).to_s
    return call_api SLACK_API_URL, app.slack_channel, title, text, fallback, color_for_release(release), image_url
  end

  def send_new_share_request_notification(app, release, username, shared_email, explanation)
    title = "#{username} has requested to share the app with #{shared_email}"
    text = "To add his email to a release group <#{app_url(app)}|click here>.\nExplanation: #{explanation}"
    fallback = "Add his email to a release group."
    return call_api SLACK_API_URL, app.slack_channel, title, text, fallback, color_for_release(release), nil
  end

  private
    def call_api(api_endpoint, channel, title, text, fallback, color, image_url)
      if channel.nil?
        return false
      end

      begin
        options = {
            :token => SLACK_API_TOKEN,
            :text => " ",
          	:channel => channel,
          	:username => "Prototyper",
          	:icon_emoji => ":calling:",
          	:attachments => [
                  {
                  	  :author_name => title,
                      :fallback => fallback,
                      :color => color,
                      :text => text
                  }
              ]
        }
        options[:attachments].first[:image_url] = image_url unless image_url.nil?
        options[:attachments] = options[:attachments].to_json
        RestClient.post api_endpoint, options
        return true
      rescue => e
        return false
      end
    end

    def color_for_release(release)
      if release.type == "Prototype"
        return "#F08E2D"
      end
      return "#0F7E12"
    end
end
