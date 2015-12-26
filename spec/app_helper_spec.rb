require 'spec_helper'

describe Racker do
  include Rack::Test::Methods
  let(:app) { Racker.new TEST_ENV }

  describe '#play_cookies' do
    context 'when it has any cookies' do
      before do
          allow(app.instance_variable_get(:@request))
            .to receive(:cookies).and_return({ "play_story" => 0 })
      end

      it 'does YAML load' do
        expect(YAML).to receive(:load)
        app.play_cookies
      end
    end

    context 'when no cookies' do
      it 'returns nil' do
        expect(app.play_cookies).to be_nil
      end
    end
  end

  ['game', 'respond', 'hint', 'error'].each do |method|
    describe "##{method}" do
      it "getter for session variable :#{method}" do
        for x in 0..10 do
          app.instance_variable_get(:@request).session[method.to_sym] = x
          expect(app.send(method)).to eq(x)
        end
      end
    end
  end

  describe '#formated_respond' do
    describe 'returns fancy respond' do
      { [1,1] => '+ - ', [0,0] => '',
        [2,1] => '+ + - ', [2,4] => '+ + - - - - ' }.each do |k, v|
          it "for #{k} => #{v}" do
            allow(app).to receive(:respond).and_return(k)
            expect(app.formated_respond).to eq(v)
          end
        end
    end
  end

  describe '#leaderboards' do
    it 'returns Array' do
      expect(app.leaderboards).to be_an Array
    end

    it 'sorted by score' do
      last_score = nil
      expect(app.leaderboards).to all(satisfy do |record|
        if last_score
          record[2] < last_score
        else
          last_score = record[2]
        end
      end)
    end

    it 'has place index' do
      last_index = nil
      expect(app.leaderboards).to all(satisfy do |record|
        if last_index
          record[0] > last_index
        else
          last_index = record[0]
        end
      end)
    end
  end

  describe '#place' do
    before do
      game = double('game')
      allow(game).to receive(:score).and_return(140)
      app.instance_variable_get(:@request).session[:game] = game
    end

    it 'returns a Fixnum' do
      expect(app.place).to be_a Fixnum
    end

    it 'defines place relatively to other players' do
      allow(app).to receive(:leaderboards).and_return([[0,0,150], [0,0,100]])
      expect(app.place).to eq(2)
    end
  end
end
