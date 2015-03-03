#This file calculates distance between stations
#written by Timothy Sweetser @hacktuarial
#https://sites.google.com/site/tsweetser
#April 2014

writeYN = False
folder = '/users/timothysweetser/box sync/BART project/'

sys.path.append('/Applications/Spyder.app/Contents/Resources/lib/python2.7/geopy')
sys.path.append(folder) # for Dijkstra and googlemaps

# Import libraries
import sys
import pandas as pd
from geopy import distance
from geopy.point import Point
from googlemaps import GoogleMaps
gmaps = GoogleMaps('AIzaSyA3M8HhR07NzG5L-IKl_Yd2bF-xtfy4UbU')

from Dijkstra_mod import *
# thanks to David Eppstein, UC Irvine, 4 April 2002 for this
# implementation of Dijktra's algorithm
# http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/117228

# BART data available at http://www.bart.gov/schedules/developers/gtfs
stops = pd.read_csv(folder + 'google_transit_2/stops.txt',\
 sep=',',header=0)

#stations = ['MLBR', 'SFIA', 'SBRN', 'SSAN', 'COLM', 'DALY', 'BALB', 'GLEN', 
#            '24TH', '16TH', 'CIVC', 'POWL', 'MONT', 'EMBR', 'WOAK', 'FRMT', 
#            'UCTY', 'SHAY', 'HAYW', 'BAYF', 'SANL', 'COLS', 'FTVL', 'LAKE', 
#            'CAST', 'WDUB', 'DUBL', '12TH', '19TH', 'MCAR', 'ASHB', 'DBRK', 
#            'NBRK', 'PLZA', 'DELN', 'RICH', 'ROCK', 'ORIN', 'LAFY', 'WCRK', 
#            'PHIL', 'CONC', 'NCON', 'PITT'
#            ]
neighbors = {} # dictionary

neighbors['MLBR'] = {'SFIA': 5.4, 'SBRN': 4.79} 
# direct connection btwn SFIA and SBRN M-F before 8 pm
neighbors['SFIA'] = {'MLBR':neighbors['MLBR']['SFIA'], 
    'SBRN': 4.06} 
neighbors['SBRN'] = {'SFIA': neighbors['SFIA']['SBRN'], 
    'SSAN': 3.43, 'MLBR': neighbors['MLBR']['SBRN']} 
neighbors['SSAN'] = {'SBRN':neighbors['SBRN']['SSAN'], 
    'COLM':1.91} 
neighbors['COLM'] = {'SSAN':neighbors['SSAN']['COLM'], 
    'DALY':1.91} 
neighbors['DALY'] = {'COLM':neighbors['COLM']['DALY'], 
    'BALB':1.74} 
neighbors['BALB'] = {'DALY':neighbors['DALY']['BALB'],
    'GLEN':1.67} 
neighbors['GLEN'] = {'BALB':neighbors['BALB']['GLEN'], 
    '24TH':1.83} 
neighbors['24TH'] = {'GLEN':neighbors['GLEN']['24TH'], 
    '16TH':0.89} 
neighbors['16TH'] = {'24TH':neighbors['24TH']['16TH'], 
    'CIVC':1.37} 
neighbors['CIVC'] = {'16TH':neighbors['16TH']['CIVC'],
    'POWL':0.44}
neighbors['POWL'] = {'CIVC':neighbors['CIVC']['POWL'], 
    'MONT':0.41} 
neighbors['MONT'] = {'POWL':neighbors['POWL']['MONT'], 
    'EMBR':0.34} 
neighbors['EMBR'] = {'MONT':neighbors['MONT']['EMBR'], 
    'WOAK':(8.69 + 9.44)/2}
neighbors['WOAK'] = {'EMBR':neighbors['EMBR']['WOAK'],
    'LAKE':2.00, '12TH':1.76}
neighbors['FRMT'] = {'UCTY':4.54} 
neighbors['UCTY'] = {'FRMT':neighbors['FRMT']['UCTY'], 
    'SHAY':4.54} 
neighbors['SHAY'] = {'UCTY':neighbors['UCTY']['SHAY'], 
    'HAYW':3.37}
neighbors['HAYW'] = {'SHAY':neighbors['SHAY']['HAYW'], 
    'BAYF':4.14} 
neighbors['BAYF'] = {'HAYW':neighbors['HAYW']['BAYF'], 
    'SANL':3.32, 'CAST':4.5} 
neighbors['SANL'] = {'BAYF':neighbors['BAYF']['SANL'], 
    'COLS':3.11} 
neighbors['COLS'] = {'SANL':neighbors['SANL']['COLS'], 
    'FTVL':2.2} 
neighbors['FTVL'] = {'COLS':neighbors['COLS']['FTVL'], 
    'LAKE':3.03} 
neighbors['LAKE'] = {'FTVL':neighbors['FTVL']['LAKE'], 
    'WOAK':neighbors['WOAK']['LAKE'], '12TH':0.66} 
neighbors['CAST'] = {'BAYF':4.5, 'WDUB':9.25}
neighbors['WDUB'] = {'CAST':neighbors['CAST']['WDUB'], 
    'DUBL':2.38} 
neighbors['DUBL'] = {'WDUB':neighbors['WDUB']['DUBL']} 
neighbors['12TH'] = {'WOAK':neighbors['WOAK']['12TH'], 
    'LAKE':neighbors['LAKE']['12TH'], '19TH':0.35} 
neighbors['19TH'] = {'12TH':neighbors['12TH']['19TH'], 
    'MCAR':1.92}
neighbors['MCAR'] = {'19TH':neighbors['19TH']['MCAR'], 
    'ASHB':1.87, 'ROCK':1.77} 
neighbors['ASHB'] = {'MCAR':neighbors['MCAR']['ASHB'], 
    'DBRK':1.67} 
neighbors['DBRK'] = {'ASHB':neighbors['ASHB']['DBRK'],
    'NBRK':1.13}
neighbors['NBRK'] = {'DBRK':neighbors['DBRK']['NBRK'], 
    'PLZA':3.38} 
neighbors['PLZA'] = {'NBRK':neighbors['NBRK']['PLZA'], 
    'DELN':2.34} 
neighbors['DELN'] = {'PLZA':neighbors['PLZA']['DELN'], 
    'RICH':2.21} 
neighbors['RICH'] = {'DELN':neighbors['DELN']['RICH']}
neighbors['ROCK'] = {'MCAR':neighbors['MCAR']['ROCK'], 
    'ORIN':5.35} 
neighbors['ORIN'] = {'ROCK':neighbors['ROCK']['ORIN'],
    'LAFY':4.51} 
neighbors['LAFY'] = {'ORIN':neighbors['ORIN']['LAFY'], 
    'WCRK':3.92} 
neighbors['WCRK'] = {'LAFY':neighbors['LAFY']['WCRK'],
    'PHIL':2.35} 
neighbors['PHIL'] = {'WCRK':neighbors['WCRK']['PHIL'],
    'CONC':4.85} 
neighbors['CONC'] = {'PHIL':neighbors['PHIL']['CONC'],
    'NCON':2.83} 
neighbors['NCON'] = {'CONC':neighbors['CONC']['NCON'],
    'PITT':5.67} 
neighbors['PITT'] = {'NCON':neighbors['NCON']['PITT']}

# this function calculates Euclidean distance "as the crow flies" 
# between 2 stations
def EuclideanDistance(st1, st2):
    P1 = Point(str(float(stops[stops.stop_id == st1].stop_lat)) + ";" + \
    str(float(stops[stops.stop_id == st1].stop_lon)))
    P2 = (str(float(stops[stops.stop_id == st2].stop_lat)) + ";" + \
    str(float(stops[stops.stop_id == st2].stop_lon)))
    return distance.distance(P1, P2).miles  # Vincenty distance

def drivingDistance(st1, st2):
    # gmaps.directions needs street addresses, not latitude/longitude
    if st1 == st2: 
        return 0
    else:
        add1 = gmaps.latlng_to_address(float(stops[stops.stop_id == st1].stop_lat),\
        float(stops[stops.stop_id == st1].stop_lon))
        add2 = gmaps.latlng_to_address(float(stops[stops.stop_id == st1].stop_lat),\
        float(stops[stops.stop_id == st1].stop_lon))
        return gmaps.directions(add1, add2)['Directions']['Distance']['miles']

# Calculate distance and enforce symmetry
sym = True
for st1 in stations:
    for st2 in neighbors[st1].keys():
        neighbors[st1][st2] = 0.5*(EuclideanDistance(st1, st2) + \
        EuclideanDistance(st2, st1))

# Now create a matrix of distances between every pair of stations using
# Dijkstra's graph traversal algorithm
trips = pd.DataFrame({'From':['x'], 'To':['y'], 'EuclidMiles':[0], \
'DrivingMiles':[0]})
for st1 in stations:
    for st2 in stations:
        trips = trips.append( {'From':st1, 'To':st2, \
        'EuclidMiles':max(Dijkstra(neighbors, st1, st2)[0].values()),\
        'DrivingMiles': drivingDistance(st1, st2) },\
        ignore_index=True)

# Remove first row, which was justfor initializatin
trips = trips.iloc[1:, :] # indexing starts at zero
if(writeYN):
    trips.to_csv('/volumes/no name/BART project/data/BART/Euclidean miles.csv', \
    index=False)