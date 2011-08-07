require 'sinatra'
require 'open-uri'
require 'json'
require 'nokogiri'

class Github
  def initialize owner, project, sha
    @owner = owner
    @project = project
    @sha = sha
  end

  def user_info
    @user_info ||= JSON.parse(open("https://api.github.com/users#{username}").read)
  end

  private
    def commit_page
      @commit_page ||= Nokogiri::HTML(open("https://github.com/#{@owner}/#{@project}/commit/#{@sha}").read)
    end

    def username
      commit_page.xpath("//div[@class='name']/a/@href").first.value
    end
end

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
      @project_info ||= JSON.parse(open("http://travis-ci.org/#{@owner}/#{@project}.json").read)
    end

    def build_info
      @build_info ||= JSON.parse(open("http://travis-ci.org/#{@owner}/#{@project}/builds/#{id}.json").read)
    end
end

get '/' do
  form = "<div style='text-align:center; margin-top:10%'>
            <form action='/'>
              <label for='user'>Owner:</label>
              <input name='user' />
              <label for='project'>Project:</label>
              <input name='project' />
              <input type='submit' value='Blame!' />
            </form>
          </div>"
  if params[:user] && params[:project]
    travis = Travis.new(params[:user], params[:project])

    if travis.status == 1
      github = Github.new(params[:user], params[:project], travis.last_commit)
      user = github.user_info
      "<html>
        <head></head>
        <body>
          <header style='text-align:center'>
            <h2>Who is to blame?</h2>
            <h3>Build status of #{params[:project]}: <span style='color:red'>Failed!</span></h3>
          </header>
          <div style='margin-top:10%;margin-left:40%'>
            <span style='margin-left:10%'>
              <img src='#{user['avatar_url']}' />
            </span>
            <p>Name: #{user['name']}</p>
            <p>Github: <a href='#{user['html_url']}'>#{user['login']}</a></p>
            <p>Email: #{user['email']}</p>
            <p>Location: #{user['location']}</p>
          </div>
          #{form}
        </body>
      </html>"
    else
    "<html>
      <head></head>
      <body>
        <header style='text-align:center'>
          <h2>Who is to blame?</h2>
          <h3>Build status of #{params[:project]}: <span style='color:green'>Passed!</span></h3>
        </header>
        <div style='margin-top:10%;margin-left:40%'>
          <h1>No blame! <3 </h1>
        </div>
        #{form}
      </body>
    </html>"
    end
  else
    "<html>
      <head></head>
      <body>
        <header style='text-align:center'>
          <h2>Who is to blame?</h2>
        </header>
        #{form}
      </body>
    </html>"
  end
end