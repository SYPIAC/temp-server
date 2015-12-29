require           'rack'
require           'erb'
require           'yaml'

class Racker
  TMP_DB_PATH = "db/temp.yml"
  def self.call(env)
    new(env).route.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
  end

  def route
    case @request.path
    when "/"            then index_page
    when "/temp"        then process_temperature
    else Rack::Response.new("Not Found", 404)
    end
  end

  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def index_page
    Rack::Response.new(render("index.html.erb"))
  end

  def process_temperature
    Rack::Response.new do |response|
      temperature = @request.params["temp"]
      time = @request.params["time"]
      db  = File.open(TMP_DB_PATH, 'a+')
      to_load = [ time[0...-6], temperature ]#cut off the "GMT +2" at the end
      db.write(to_load.to_yaml)
      db.close
    end
  end

  def temperatures
    db = File.open(TMP_DB_PATH)
    loaded = YAML.load_stream(db)
    loaded.reverse!
    loaded
  end
end
