class Travis
  def initialize owner, project
    @owner = owner
    @project = project
  end

  def status
    project_info["last_build_status"]
  end

  def id
    project_info["last_build_id"]
  end

  def last_commit
    build_info["commit"]
  end

  private
    def project_info
      @project_info ||= JSON.parse(open("http://travis-ci.org/#{@owner}/#{@project}.json").read) rescue {}
    end

    def build_info
      @build_info ||= JSON.parse(open("http://travis-ci.org/#{@owner}/#{@project}/builds/#{id}.json").read) rescue {}
    end
end