require 'spec_helper'

describe Racker do
  include Rack::Test::Methods
  let(:app) { Racker.new TEST_ENV }

  describe '#index_page' do
    it 'renders index.html page' do
      expect(Rack::Response).to receive(:new).with(app.render("index.html.erb"))
      app.index_page
    end
  end

  describe '#start_game' do
    before do
      allow(Codebreaker::Game).to receive(:start)
      allow(app.instance_variable_get(:@request))
        .to receive(:params).and_return({"diff"=>"easy"})
    end

    it 'clears session' do
        expect(app.instance_variable_get(:@request).session)
          .to receive(:clear)
        app.start_game
    end

    it 'clears game cookies' do
        expect(app).to receive(:clear_game_cookies)
        app.start_game
    end

    it 'creates a new game' do
      expect(app.game).to be_a(Codebreaker::Game)
      app.start_game
    end

    it 'starts game' do
      expect_any_instance_of(Codebreaker::Game).to receive(:start)
      app.start_game
    end

    it 'redirects away' do
      action = app.start_game
      expect(action.location).to eq '/play'
      expect(action.status).to eq(302)
    end
  end

  describe '#play_page' do
    it 'renders play.html page' do
      expect(Rack::Response).to receive(:new).with(app.render("play.html.erb"))
      app.play_page
    end
  end

  describe '#get_hint' do
    it 'receives a new hint' do
      expect{app.get_hint}
        .to change{app.instance_variable_get(:@request).session[:hint]}
    end

    it 'adds play cookie' do
      expect(app).to receive(:add_play_cookie)
      app.get_hint
    end

    it 'redirects to "/play"' do
      action = app.get_hint
      expect(action.location).to eq '/play'
      expect(action.status).to eq(302)
    end
  end

  describe '#result_page' do
    it 'renders result.html page' do
      expect(Rack::Response).to receive(:new).with(app.render("result.html.erb"))
      app.result_page
    end
  end

  describe '#save_record' do
    before do
      game = double('game')
      allow(game).to receive(:score).and_return(140)
      app.instance_variable_get(:@request).session[:game] = game
      allow(app.instance_variable_get(:@request))
        .to receive(:params).and_return({"name"=>"plair"})
    end

    it 'adds new record to DB' do
      expect{app.save_record}.to change{File.open(Racker::DB_PATH).read}
    end

    it 'redirects to "/"' do
      action = app.save_record
      expect(action.location).to eq '/'
      expect(action.status).to eq(302)
    end
  end
end
