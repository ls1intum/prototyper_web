module ReleasesHelper
  require 'json'
  require 'rmagick'
  require 'rubygems'
  require 'zip'
  include SlackHelper

  BAMBOO_AUTHENTICATED_HOST = "#{Rails.application.secrets.bamboo_username}:#{Rails.application.secrets.bamboo_password}@#{Rails.application.secrets.bamboo_host}"

  BAMBOO_API_TRIGGER_URL = "https://#{BAMBOO_AUTHENTICATED_HOST}/rest/api/latest/queue/BAKR-BAKR?stage&executeAllStages"
  BAMBOO_API_STATUS_URL = "https://#{BAMBOO_AUTHENTICATED_HOST}/rest/api/latest/result/status/"
  BAMBOO_API_RESULT_URL = "https://#{BAMBOO_AUTHENTICATED_HOST}/rest/api/latest/result/"

  def sendReleaseToBamboo(release)
    begin
      icon_path = release.app.icon.url
      icon_path = "blank_icon.png" if icon_path.nil?
      icon_url = URI.join(root_url, icon_path).to_s

      response = RestClient.post BAMBOO_API_TRIGGER_URL, {
                        :"bamboo.variable.bundle_identifier" => release.app.bundle_id,
                        :"bamboo.variable.app_name" => release.app.name,
                        :"bamboo.variable.app_id" => release.app.id,
                        :"bamboo.variable.prot_id" => release.id,
                        :"bamboo.variable.app_version" => release.version,
                        :"bamboo.variable.icon_url" => icon_url,
                        :"bamboo.variable.prototype_url" => release.url,
                        :"bamboo.variable.container_url" => app_release_container_url(release.app,release),
                        :"bamboo.variable.hide_statusbar" => release.hide_statusbar
                      }, :accept => :json
    rescue => e
      response = e.response
    end

    dict = JSON.parse(response)
    build_result_key = dict["buildResultKey"]
  end

  def storeResultsOfBetaRelease(user, release)
    @build = @release.builds.new

    url_hash = ipa_url_for_build(release.build_key)
    url = url_hash["ipa"]

    if !url.nil? && url.length > 0
      url[Rails.application.secrets.bamboo_url] = ""

      download_body = user.bamboo_access_token.get(url).body

      tempfile = Tempfile.new('temp.ipa')
      File.open(tempfile.path,'wb') do |f|
        f.write download_body
      end

      @build.ipa = tempfile
      @build.bundle_id = @app.bundle_id
      @build.bundle_version = user.bamboo_access_token.get(url_hash["build_version"]).body.sub("\n", "")

      if @build.save
        @build.manifest_url = app_release_build_manifest_url(@app, @release, @build)
        @build.save
        return true
      else
        p @build.errors.full_messages.to_s
      end
    else
      p "No artifact found"
    end

    return false

  end

  def storeResultsOfBuildRelease(user, release, build_file)
    if File.extname(build_file.path()) == ".ipa" 
      storeResultsOfIpaRelease(user, release, build_file)
    else
      storeResultsOfApkRelease(user, release, build_file)
    end
  end

  def storeResultsOfIpaRelease(user, release, ipa)
    plist_content = readIPAContent(ipa.path())
    if plist_content['CFBundleIdentifier'] != @app.bundle_id
      return false
    end

    @build = @release.builds.new

    @build.ipa = ipa
    @build.bundle_id = @app.bundle_id
    @build.bundle_version = plist_content['CFBundleVersion']

    if @build.save
      @build.manifest_url = app_release_build_manifest_url(@app, @release, @build)
      @build.save
      return true
    else
      p @build.errors.full_messages.to_s
    end

    return false
  end

  def storeResultsOfApkRelease(user, release, apk)
    bundle_id_sed = 'sed -n "s/.*package: name=\'\([^\']*\).*/\1/p"'
    bundle_version_sed = 'sed -n "s/.*versionCode=\'\([^\']*\).*/\1/p"'

    bundle_id = `aapt dump badging #{apk.path()} | #{bundle_id_sed}`.strip
    bundle_version = `aapt dump badging #{apk.path()} | #{bundle_version_sed}`.strip
    
    if bundle_id != @app.bundle_id
      return false
    end

    @build = @release.builds.new

    @build.ipa = apk
    @build.bundle_id = @app.bundle_id
    @build.bundle_version = bundle_version

    if @build.save
      return true
    else
      p @build.errors.full_messages.to_s
    end

    return false
  end

  def getProgressForBuildKey(build_key, user)
    return "Failed" if build_key.nil?

    begin
      if user.nil?
        response = RestClient.get BAMBOO_API_STATUS_URL+build_key, :accept => :json
      else
        response = user.bamboo_access_token.get('/rest/api/latest/result/status/', { 'Accept'=>'application/json' }).body
      end
    rescue => e
      begin
        response = RestClient.get BAMBOO_API_RESULT_URL+build_key, :accept => :json
        dict = JSON.parse(response)
        return dict["state"]
      rescue => e
        return "Succeeded"
      end
    end

    dict = JSON.parse(response)

    if dict["progress"].nil?
      return "Not found"
    end

    percentage_pretty = dict["progress"]["percentageCompletedPretty"]
    remaining_time_pretty = dict["progress"]["prettyTimeRemainingLong"]
    return "#{percentage_pretty} done, #{remaining_time_pretty}"
  end

  def createMarvelBundleForRelease(release)
    if release.url =~ /https?:\/\/marvelapp.com\/[\S]+/
      # Remove screen extension
      if release.url =~ /https?:\/\/marvelapp.com\/[\S]+\/screen\/[\S]+/
        release.url = release.url.split('/screen/').first
      end
      release.url = release.url.chomp("/")
      release.save

      @marvel_id = release.url.split('/').last
      @release = release

      copy_static_files
      download_website release.url
      download_prototype_json
      return container_path
    else
      logger.warn "Wrong url format"
    end
  end

  def createMarvelBundleForContainer(container)
    if container.marvel_url =~ /https?:\/\/marvelapp.com\/[\S]+/
      # Remove screen extension
      if container.marvel_url =~ /https?:\/\/marvelapp.com\/[\S]+\/screen\/[\S]+/
        container.marvel_url = container.marvel_url.url.split('/screen/').first
      end
      container.marvel_url = container.marvel_url.chomp("/")
      container.save

      @marvel_id = container.marvel_url.split('/').last
      @container = container

      copy_static_files
      download_website container.marvel_url
      download_prototype_json
      return container_path
    else
      logger.warn "Wrong url format"
    end
  end

  def send_zip_of_folder(folder_path)
    temp_path = Rails.root.join("temp")
    Dir.mkdir(temp_path) unless File.exists?(temp_path)

    date_string = @container.created_at.strftime("%d_%m_%Y-%H_%M")

    if @release.nil?
      filename = "container-#{date_string}"
    else
      marvel_id = @release.url.split('/').last
      filename = "#{marvel_id}-#{date_string}"
    end
    
    destination_path = temp_path.join("#{filename}.zip")

    Dir.chdir("#{folder_path}/..")

    folder_name = @release.nil? ? "c_#{@container.id}" : "#{@release.id}"
    system("rm #{destination_path}")
    system("zip -r \"#{destination_path}\" \"#{folder_name}\"")

    send_file destination_path
  end

  def create_prototype
    version = new_release_version
    @release = @app.releases.build(prototype_params)
    @release.version = version
    if @release.save
      Thread.new do
        @release.container_path = createMarvelBundleForRelease(@release)
        @release.build_key = sendReleaseToBamboo(@release)
        @release.save
      end
      flash[:success] = "Creating release from Marvel mockup ..."
      send_new_release_creation_notification(@app, @release)
      redirect_to app_url(@app)
    else
      @prototype = @release
      render "new_prototype"
    end
  end

  def create_beta
    version = new_release_version
    @release = @app.releases.build(beta_params)
    @release.version = version
    if @release.save
      if storeResultsOfBetaRelease(current_user, @release)
        @release.save
        flash[:success] = "Created release from Xcode project"
        send_new_release_creation_notification(@app, @release)
        redirect_to app_url(@app)
      else
        @release.destroy
        flash[:danger] = "No build artifact found"
        redirect_to app_releases_new_beta_url(@app)
      end
    else
      @beta = @release
      @branches = @app.branches(current_user)
      render "new_beta"
    end
  end

  def create_from_build
    version = new_release_version
    build_file = ipa_params[:beta][:build]
    save_params = ipa_params.require(:beta).permit(:version, :description, :type, :build_key)
    @release = @app.releases.build(save_params)
    @release.version = version
    if @release.save
      if storeResultsOfBuildRelease(current_user, @release, build_file)
        @release.save
        if @is_api_call 
          render :text => "Release added"
        else
          flash[:success] = "Created release from build"
          send_new_release_creation_notification(@app, @release)
          redirect_to app_url(@app)  
        end
      else
        if @is_api_call 
          render :text => "No build artifact found or wrong bundle identifier", :status => 400
        else
          @release.destroy
          flash[:danger] = "No build artifact found or wrong bundle identifier"
          redirect_to app_releases_new_from_build_url(@app)
        end
      end
    else
      if @is_api_call 
        render :text => @release.errors.full_messages.to_s, :status => 400
      else
        @ipa = @release
        render "new_from_build"
      end
    end
  end

  def prepare_web_container(container_path)
    public_path = Rails.root.join("public")
    Dir.mkdir(public_path) unless File.exists?(public_path)
    system("cp -R #{container_path} #{public_path}")
  end

  def builds_for_branch(branch_key)
    body = current_user.bamboo_access_token.get("/rest/api/latest/result/#{branch_key}?expand=results.result.buildStartedTime&max-results=3&buildstate=Successful", { 'Accept'=>'application/json' }).body
    dict = JSON.parse(body)

    if dict["results"].nil? || dict["results"]["result"].nil?
      return Array.new
    end

    resultsHash = dict["results"]["result"]
    return resultsHash.map { |p|
      {
        time_ago: p["buildRelativeTime"], resultKey: p["buildResultKey"], buildReason: p["buildReason"], number: p["buildNumber"]
      }
    }
  end

  def ipa_url_for_build(build_id)
    body = current_user.bamboo_access_token.get("/rest/api/latest/result/#{build_id}?expand=artifacts", { 'Accept'=>'application/json' }).body
    dict = JSON.parse(body)

    ret = Hash.new

    artifacts = dict["artifacts"]["artifact"]
    artifacts.each do |artifactHash|
      if artifactHash["name"] == "IPA"
        ret["ipa"] = artifactHash["link"]["href"]
      end
      if artifactHash["name"] == "Build String"
        ret["build_version"] = artifactHash["link"]["href"]
      end
    end

    return ret
  end

  def create_annotated_icon(release)
    icon_path = Rails.root.join("public/release_icon_#{release.app.id}_#{release.id}.png")
    unless File.exist?(icon_path)
      img = nil
      if release.app.icon.file.nil?
          img = Magick::Image.read(Rails.root.join(asset_path('images/default_icon.png')))[0]
      else
          img = Magick::Image.read(release.app.icon.file.file)[0]
      end

      gc = Magick::Draw.new
      if release.type == "Prototype"
        gc.stroke('#F08E2D')
      else
        gc.stroke('green')
      end
      gc.stroke_width(img.rows*0.2)
      gc.line(img.columns*0.35, img.rows*1.2, img.columns*1.2, img.rows*0.35)
      gc.draw(img)

      textImage = Magick::Image.new(img.columns, img.rows) do |c|
        c.background_color= "Transparent"
      end

      text = Magick::Draw.new
      text.font_family = 'helvetica'
      text.pointsize = img.rows*0.13
      text.gravity = Magick::CenterGravity

      text.annotate(textImage, 0,0,0,img.rows*0.405, "Ver. #{release.version}") {
        self.fill = 'white'
        self.font_weight = Magick::BoldWeight
      }

      textImage.rotate!(-45)
      img.composite!(textImage, Magick::CenterGravity, Magick::HardLightCompositeOp)

      img.write(icon_path)
    end

    response.headers["Expires"] = 1.week.from_now.httpdate
    response.headers["Cache-Control"] = 'public, max-age=31536000'
    send_file(icon_path)
  end

  private

    def containers_folder
      Rails.root.join("containers")
    end

    def container_path
      Dir.mkdir(containers_folder) unless File.exists?(containers_folder)
      folder_name = @release.nil? ? "c_#{@container.id}" : "#{@release.id}"
      final_destination_folder_path = containers_folder.join(folder_name)
      return final_destination_folder_path
    end

    def copy_static_files
      marvelapp_folder = containers_folder.join("marvelapp.com")
      Dir.mkdir(container_path)
      system("cp -R #{marvelapp_folder} #{container_path}")
    end

    def download_website(website_url)
      download_url = website_url.gsub(/#.*/, '')
      system("wget -P #{container_path} -p -N -k -e robots=off -H -r --domains marvelapp.com #{download_url}")
      rename_index_file
      fix_index_file
    end

    def download_prototype_json
      json_path = container_path.join("marvelapp.com/data.json")
      js_path = container_path.join("marvelapp.com/data.js")
      url = "https://marvelapp.com/api/prototype/#{@marvel_id}/?xf="
      system("wget -O #{json_path} #{url}")
      fix_js_file
      make_protototype_local(json_path)
      system("cat #{json_path} >> #{js_path}")
      system("rm #{json_path}")
    end

    def fix_js_file
      folder_name = @release.nil? ? "c_#{@container.id}" : "#{@release.id}"
      replace_text = "return fetch(\"/#{folder_name}/#{@marvel_id}.json\","

      js_path = Dir["#{container_path}/marvelapp.com/static/prototype-bundle.*"].first
      outdata = File.read(js_path).gsub(/return fetch\(e,/, replace_text)
      File.open(js_path, 'w') do |out|
        out << outdata
      end

      css_path = Dir["#{container_path}/marvelapp.com/static/css/prototype.*"].first
      outdata = File.read(css_path).gsub(/z-index:800/, "z-index:-800")
      File.open(css_path, 'w') do |out|
        out << outdata
      end
    end

    def rename_index_file
      html_path_old = container_path.join("marvelapp.com/#{@marvel_id}")
      html_path_new = container_path.join("marvelapp.com/index.html")
      File.rename(html_path_old, html_path_new)
    end

    def fix_index_file
      html_path_new = container_path.join("marvelapp.com/index.html")
      outdata = File.read(html_path_new).gsub(/offline: false/, "offline: true")
      outdata = File.read(html_path_new).gsub(/offline = false/, "offline = true")
      outdata = outdata.gsub(/<\/head>/, "<script type=\"text/javascript\" src=\"data.js\"></script>")
      File.open(html_path_new, 'w') do |out|
        out << outdata
      end
    end

    def make_protototype_local(json_path)
      @mapped_urls = {}

      file = File.read(json_path)
      dict = JSON.parse(file)

      final_dict = make_dict_local(dict)

      File.open(json_path,"w") do |f|
        f.write(final_dict.to_json)
      end
    end

    def make_dict_local(dict)
      dict.each do |key, value|
        if value.is_a?(Hash)
          dict[key] = make_dict_local(dict[key])
        else
          if key == "url"
            if @mapped_urls[value].nil?
              random_id = (0...10).map { ('a'..'z').to_a[rand(26)] }.join
              system("mkdir -p #{container_path}/images/ && wget -O #{container_path}/images/#{random_id} #{value}")
              dict[key] = "../images/#{random_id}"
              @mapped_urls[value] = dict[key]
            else
              dict[key] = @mapped_urls[value]
            end
          end
        end
      end
    end

    def branch_with_key(key, branches)
      @branches.each do |branch|
        if branch[:key] == key
          return branch
        end
      end
    end

    def new_release_version
      lastReleaseVersion = 0
      lastReleaseVersion = @app.releases.last.version.to_i unless @app.releases.last.nil?
      return lastReleaseVersion + 1
    end

    def readIPAContent(file)
      Zip::File.open(file) do |zip_file|
        info_plist = zip_file.glob('Payload/*.app/Info.plist').first
        xml_content = info_plist.get_input_stream.read
        Plist.parse_xml(xml_content)
      end
    end

end
