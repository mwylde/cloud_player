ROOT = File.expand_path(File.dirname(__FILE__))

require 'json'
require 'nokogiri'
require 'mechanize'
require 'uuidtools'
require 'thor'
require 'rubybits'
require 'eventmachine'

require "#{ROOT}/cloud_player/runner"
require "#{ROOT}/cloud_player/auth"
require "#{ROOT}/cloud_player/library"

module CloudPlayer
  VERSION = "0.0.1"
end
