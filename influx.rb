require "./lib/cli"
require "./lib/payload"
require "./lib/connection"
require "./lib/crc8"

require "influxdb-client"

hostname = `hostname`.strip

cli = BTWATTCH2::CLI.new

cli.addr = ENV['BTWATCH2_ADDR']

iclient = InfluxDB2::Client.new(
  'https://localhost:8086',
  ENV['INFLUXDB_TOKEN'],
  use_ssl: false,
  org: ENV['INFLUXDB_ORG'],
  bucket: ENV['INFLUXDB_BUCKET'],
  precision: InfluxDB2::WritePrecision::NANOSECOND
)

write_api = iclient.create_write_api

conn = BTWATTCH2::Connection.new(cli)
conn.subscribe_measure! do |e|
  puts "v: #{e[:voltage]}, a: #{e[:ampere]}, w: #{e[:wattage]}"

  point = InfluxDB2::Point.new(name: 'btwattch2')
    .add_tag('host', hostname)
    .add_tag('addr', cli.addr)
    .add_field('voltage', e[:voltage])
    .add_field('ampere', e[:ampere])
    .add_field('wattage', e[:wattage])
  write_api.write(data: point)
end
