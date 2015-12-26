require_relative '../lib/racker'
require 'rack/test'

ENV['RACK_ENV'] = 'test'
TEST_ENV = Hash.new


class Racker
  DB_PATH = File.expand_path("../fixtures/#{DB_PATH}", __FILE__)
end
