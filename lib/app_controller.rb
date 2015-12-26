class Racker
  def index_page
    Rack::Response.new(render("index.html.erb"))
  end

  def start_game
    Rack::Response.new do |response|
      @request.session.clear
      clear_game_cookies(response)
      @request.session[:game] = Codebreaker::Game.new
      @request.session[:game].start(@request.params["diff"].to_sym)
      response.redirect("/play")
    end
  end

  def play_page
    response = Rack::Response.new(render("play.html.erb"))
    @request.session[:error] = nil
    response
  end

  def guess
    Rack::Response.new do |response|
      code = @request.params["code"].split("").map{|x| x.to_i(16)}
      begin
        @request.session[:respond] = game.guess(code)
        add_play_cookie(response, [game.attempts_taken, @request.params["code"], formated_respond])
      rescue IndexError => e
        @request.session[:error] = "You have to input #{game.symbols_count} chars."
      rescue ArgumentError => e
        @request.session[:error] = "You have to input chars in range 1-#{game.symbols_range.to_s(16)}"
      end
      if game.state == :playing
        response.redirect("/play")
      else
        response.redirect("/result")
      end
    end
  end

  def get_hint
    Rack::Response.new do |response|
      begin
        @request.session[:hint] = game.hint
        add_play_cookie(response, ['HINT', 'HINT', formated_hint])
        response.redirect("/play")
      rescue Exception => e
        @request.session[:error] = e.message
        response.redirect("/play")
      end
    end
  end

  def result_page
    Rack::Response.new(render("result.html.erb"))
  end

  def save_record
    Rack::Response.new do |response|
      db = File.open(DB_PATH,'a+')
      loaded = [@request.params["name"], game.score]
      db.write(loaded.to_yaml)
      db.close
      response.redirect("/")
    end
  end

  def process_temperature
    Rack::Response.new do |response|
      temperature = @request.params["temp"]
      db  = File.open(TMP_DB_PATH, 'a+')
      to_load = [ Time.now, temperature ]
      db.write(to_load.to_yaml)
      db.close
    end
  end

  def show_temperatures
    Rack::Response.new(render("temp_stat.html.erb"))
  end
end
