class BuildsController < ApplicationController
  #before_action :logged_in_user, only: [:create]
  before_action :has_download_access_to_release, only: [:manifest, :download]

  def create
    @app = App.find(params[:app_id])
    @release = @app.releases.find(params[:release_id])
    @build = @release.builds.build(build_params)

    @build.ipa = params[:build][:ipa]
    @build.bundle_id = params[:build][:bundle_id]

    if @build.save
      @build.manifest_url = app_release_build_manifest_url(@app, @release, @build)
      @build.save
      render :plain => "Build added"
    else
      render :plain => @build.errors.full_messages.to_s, :status => 400
    end
  end

  def manifest
    @build = @release.builds.find(params[:build_id])

    ipaURL = app_release_build_download_url(@app, @release, @build)

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

    render :plain => manifestContent, :content_type => Mime::XML
  end

  def download
    @build = @release.builds.find(params[:build_id])
    send_file @build.ipa.path(), :x_sendfile=>true
  end

  private

    def build_params
      params.require(:build).permit(:ipa, :manifest, :bundle_id)
    end
end
