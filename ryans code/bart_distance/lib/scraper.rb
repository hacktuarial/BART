require 'rubygems'
require 'bundler/setup'
require 'capybara'
require 'capybara/dsl'
require 'capybara/mechanize'

Capybara.run_server = false
Capybara.current_driver = :mechanize
Capybara.app_host = "http://www.bart.gov/"

class Scraper
  include Capybara::DSL
  
  def find_stations
    visit '/stations/index.aspx'
    all('#stations-directory li a').each do |a|
      visit '/stations/' << a[:href]
      
      subheader = page.find_by_id('subheader')
      name = subheader.find('h1').text
      address = subheader.find('.subtitle').text.gsub(' / ', ', ')
      
      puts %("#{name}","#{address}")
    end
  end
end

Scraper.new.find_stations

