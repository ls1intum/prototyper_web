class BuildsController < ApplicationController
  #before_action :logged_in_user, only: [:create]
  before_action :has_download_access_to_release, only: [:manifest]

  def create
    @app = App.find(params[:app_id])
    @release = @app.releases.find(params[:release_id])
    @build = @release.builds.build(build_params)

    @build.ipa = params[:build][:ipa]
    @build.bundle_id = params[:build][:bundle_id]

    if @build.save
      @build.manifest_url = app_release_build_manifest_url(@app, @release, @build)
      @build.save
      render :text => "Build added"
    else
      render :text => @build.errors.full_messages.to_s, :status => 400
    end
  end

  def manifest
    @build = @release.builds.find(params[:build_id])

    ipaURL = "https://" + request.host_with_port + @build.ipa.url

    manifestContent = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
    <!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
    <plist version=\"1.0\">
    <dict>
    	<key>items</key>
    	<array>
    		<dict>
    			<key>assets</key>
    			<array>
    				<dict>
    					<key>kind</key>
    					<string>software-package</string>
    					<key>url</key>
    					<string>#{ipaURL}</string>
    				</dict>
    			</array>
    			<key>metadata</key>
    			<dict>
    				<key>bundle-identifier</key>
    				<string>#{@build.bundle_id}</string>
    				<key>bundle-version</key>
    				<string>#{@release.version}</string>
    				<key>subtitle</key>
    				<string>tbd</string>
    				<key>title</key>
    				<string>#{@app.name}</string>
    				<key>kind</key>
    				<string>software</string>
    			</dict>
    		</dict>
    	</array>
    </dict>
    </plist>"

    render :text => manifestContent, :content_type => Mime::XML
  end

  private

    def build_params
      params.require(:build).permit(:ipa, :manifest, :bundle_id)
    end
end
