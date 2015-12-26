require           'rack'
require           'erb'
require           'codebreaker'
require           'yaml'
require_relative  'app_helper'
require_relative  'app_controller'

class Racker
  DB_PATH     = "db/records.yml"
  TMP_DB_PATH = "db/temp.yml"
  PLAY_COOKIE = "play_story"

  def self.call(env)
    new(env).route.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
  end

  def route
    case @request.path
    when "/"            then index_page
    when "/start_game"  then start_game
    when "/play"        then play_page
    when "/guess"       then guess
    when "/hint"        then get_hint
    when "/result"      then result_page
    when "/record"      then save_record
    when "/temp"        then process_temperature
    else Rack::Response.new("Not Found", 404)
    end
  end

  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def clear_game_cookies(response)
    response.delete_cookie(PLAY_COOKIE)
  end

  def add_play_cookie(response, add)
    if @request.cookies[PLAY_COOKIE]
      history = YAML.load(@request.cookies[PLAY_COOKIE])
      history << add
    else
      history = [add]
    end
    history = YAML.dump(history)
    response.set_cookie(PLAY_COOKIE, history)
  end
end
