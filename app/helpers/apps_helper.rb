module AppsHelper

  Project = Struct.new(:name, :key)

  def bamboo_projects(user)
    if user.bamboo_access_token.nil?
      return Array.new
    end

    body = user.bamboo_access_token.get('/rest/api/latest/project?max-result=1000', { 'Accept'=>'application/json' }).body
    begin
      dict = JSON.parse(body)

      projectsHash = dict["projects"]["project"]
      return projectsHash.map { |p| {name: p["name"], key: p["key"]} }
    rescue JSON::ParserError => e
      return Array.new
    end
  end

  def bamboo_plans(user, project)
    if user.bamboo_access_token.nil?
      return Array.new
    end

    body = user.bamboo_access_token.get("/rest/api/latest/project/#{project}?expand=plans&max-result=1000", { 'Accept'=>'application/json' }).body
    begin
      dict = JSON.parse(body)

      plansHash = dict["plans"]["plan"]
      plansHash.map { |p| {name: p["shortName"], key: p["shortKey"]} }
    rescue JSON::ParserError => e
      return Array.new
    end
  end

end
