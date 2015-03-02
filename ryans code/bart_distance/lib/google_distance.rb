require "rubygems"
require "bundler/setup"
require "httparty"
require 'nokogiri'
require 'active_support/all'

class GoogleDistance
  def initialize(from, to)
    @from = from
    @to = to
  end

  def status
    @status ||= doc.css("status").text
  end
  
  def distance_in_miles
    if status == 'OK'
      distance_in_meters = doc.css("distance value").last.text
      (distance_in_meters.to_f / 1610.22).round(2)
    else
      raise "Bad status: #{status}"
    end
  end
  
  def doc
    @doc ||= send_request
  end
  
  def send_request
    params = {
      origin: @from,
      destination: @to,
      sensor: false
    }
    
    response = HTTParty.get("http://maps.googleapis.com/maps/api/directions/xml?#{params.to_query}")
    doc = Nokogiri::XML(response.body)
  end
end