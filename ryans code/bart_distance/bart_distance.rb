require 'csv'
require 'ostruct'
require_relative 'lib/google_distance'

start_index = (ARGV.length == 1) ? ARGV.first.to_i : 0
stations = CSV.read('station_address.csv').map{|name, address| OpenStruct.new(name: name, address: address)}

puts "Station Pair ID,From Name,From Address,To Name,To Address,Distance in Miles"

stations.permutation(2).each_with_index do |station_pair, index|
  next if index < start_index
  
  begin
    s1, s2 = station_pair
    distance = GoogleDistance.new(s1.address, s2.address)  
    puts %(#{index},"#{s1.name}","#{s1.address}","#{s2.name}","#{s2.address}",#{distance.distance_in_miles})
    sleep(2)
  rescue
    raise "Died attempting to process station pair #{index}, #{station_pair.map{|s| s.name }.inspect}\n" + 
          "The last successful API call was pair #{index-1}"
  end
end