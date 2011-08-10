require 'sinatra'
require 'open-uri'
require 'json'
require 'nokogiri'

require './lib/travis'
require './lib/github'

get '/' do
  if params[:user] && params[:project]
    @project = params[:project]
    @travis = Travis.new(params[:user], params[:project])
    github = Github.new(params[:user], params[:project], @travis.last_commit)

    @user = github.user_info

  end
  haml :blame, :locals => { :project => @project, :travis => @travis, :user => @user }
end