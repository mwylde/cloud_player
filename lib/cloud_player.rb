ROOT = File.expand_path(File.dirname(__FILE__))

require 'json'
require 'nokogiri'
require 'mechanize'
require 'uuidtools'
require 'thor'
require 'rubybits'
require 'eventmachine'
require 'unicode_utils/compatibility_decomposition'
require 'amatch'
require 'rainbow'

module CloudPlayer
  VERSION = "0.0.1"
  PORT = 6134
end

require "#{ROOT}/cloud_player/protocol"
require "#{ROOT}/cloud_player/server"
require "#{ROOT}/cloud_player/runner"
require "#{ROOT}/cloud_player/auth"
require "#{ROOT}/cloud_player/library"
require "#{ROOT}/cloud_player/client"
