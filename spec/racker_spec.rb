require 'spec_helper'

describe Racker do
  include Rack::Test::Methods
  let(:app) { Racker.new TEST_ENV }

  describe '#clear_game_cookies' do
    it 'clears PLAY_COOKIE' do
      response = double("response")
      expect(response).to receive(:delete_cookie).with(Racker::PLAY_COOKIE)
      app.clear_game_cookies(response)
    end
  end

  describe '#add_play_cookie' do
    it 'YAML dumps the data before save' do
      expect(YAML).to receive(:dump)
      app.add_play_cookie(Rack::Response.new, 0)
    end

    it 'saves to the cookies' do
      response = double("response")
      allow(response).to receive(:set_cookie)
      expect(response).to receive(:set_cookie)
      app.add_play_cookie(response, 0)
    end

    context 'when play cookie is empty' do
      before do
        app.instance_variable_get(:@request).cookies["play_story"] = 0
      end

      it 'loads existing cookie' do
        allow(YAML).to receive(:load).and_return([])
        expect(YAML).to receive(:load)
          .with(app.instance_variable_get(:@request).cookies["play_story"])
        app.add_play_cookie(Rack::Response.new, 0)
      end
    end
  end
end
