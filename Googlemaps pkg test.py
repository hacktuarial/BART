# -*- coding: utf-8 -*-
"""
Created on Thu Apr 17 18:39:11 2014

@author: timothysweetser
"""

folder = '/volumes/thumbie/BART project/'
sys.path.append(folder) 
from googlemaps import GoogleMaps
gmaps = GoogleMaps('AIzaSyBEGzQa5g0Onvq_sg4YvHH1SLam20zC-JQ')
address = 'Constitution Ave NW & 10th St NW, Washington, DC'
lat, lng = gmaps.address_to_latlng(address)
print lat, lng