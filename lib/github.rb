class Github
  def initialize owner, project, sha
    @owner = owner
    @project = project
    @sha = sha
  end

  def user_info
    @user_info ||= JSON.parse(open("https://api.github.com/users#{username}").read) rescue {}
  end

  private
    def commit_page
      @commit_page ||= Nokogiri::HTML(open("https://github.com/#{@owner}/#{@project}/commit/#{@sha}").read) rescue nil
    end

    def username
      commit_page.xpath("//div[@class='name']/a/@href").first.value if commit_page
    end
end