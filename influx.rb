require "./lib/cli"
require "./lib/payload"
require "./lib/connection"
require "./lib/crc8"

require "influxdb-client"

cli = BTWATTCH2::CLI.new

cli.addr = ENV['BTWATCH2_ADDR']

conn = BTWATTCH2::Connection.new(cli)
conn.subscribe_measure! do |e|
  puts "v: #{e[:voltage]}, a: #{e[:ampere]}, w: #{e[:wattage]}"
end
