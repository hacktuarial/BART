import sys
import pandas as pd
import scipy as sp
sys.path.append('/volumes/no name/BART project') # MAC
# sys.path.append('F:/BART project') # PC
from Dijkstra_mod import *
# thanks to David Eppstein, UC Irvine, 4 April 2002
# http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/117228
stations = ['Millbrae', 'SFIA', 'San Bruno', 'South SF', 'Colma',
            'Daly City', 'Balboa Park', 'Glen Park', '24th St.', '16th St.', 
            'Civic Center', 'Powell', 'Montgomery', 'Embarcadero', 
            'West Oakland', 'Fremont', 'Union City', 'South Hayward', 'Hayward',
            'Bay Fair', 'San Leandro', 'Coliseum', 'Fruitvale', 'Lake Merritt', 
            'Castro Valley', 'West Dublin', 'Dublin/Pleasanton', '12th St.', 
            '19th St.', 'MacArthur', 'Ashby', 'Berkeley', 'North Berkeley',
            'El Cerrito Plaza', 'El Cerrito del Norte', 'Richmond', 'Rockridge',
            'Orinda', 'Lafayette', 'Walnut Creek', 'Pleasant Hill', 'Concord', 
            'North Concord', 'Pittsburg/Bay Pt'
            ]
neighbors = {} # dictionary

neighbors['Millbrae'] = {'SFIA': 5.4, 'San Bruno': 4.79} 
# direct connection btwn SFIA and San Bruno M-F before 8 pm
neighbors['SFIA'] = {'Millbrae':neighbors['Millbrae']['SFIA'], 
    'San Bruno': 4.06} 
neighbors['San Bruno'] = {'SFIA': neighbors['SFIA']['San Bruno'], 
    'South SF': 3.43, 'Millbrae': neighbors['Millbrae']['San Bruno']} 
neighbors['South SF'] = {'San Bruno':neighbors['San Bruno']['South SF'], 
    'Colma':1.91} 
neighbors['Colma'] = {'South SF':neighbors['South SF']['Colma'], 
    'Daly City':1.91} 
neighbors['Daly City'] = {'Colma':neighbors['Colma']['Daly City'], 
    'Balboa Park':1.74} 
neighbors['Balboa Park'] = {'Daly City':neighbors['Daly City']['Balboa Park'],
    'Glen Park':1.67} 
neighbors['Glen Park'] = {'Balboa Park':neighbors['Balboa Park']['Glen Park'], 
    '24th St.':1.83} 
neighbors['24th St.'] = {'Glen Park':neighbors['Glen Park']['24th St.'], 
    '16th St.':0.89} 
neighbors['16th St.'] = {'24th St.':neighbors['24th St.']['16th St.'], 
    'Civic Center':1.37} 
neighbors['Civic Center'] = {'16th St.':neighbors['16th St.']['Civic Center'],
    'Powell':0.44}
neighbors['Powell'] = {'Civic Center':neighbors['Civic Center']['Powell'], 
    'Montgomery':0.41} 
neighbors['Montgomery'] = {'Powell':neighbors['Powell']['Montgomery'], 
    'Embarcadero':0.34} 
neighbors['Embarcadero'] = {'Montgomery':neighbors['Montgomery']['Embarcadero'], 
    'West Oakland':(8.69 + 9.44)/2}
neighbors['West Oakland'] = {'Embarcadero':neighbors['Embarcadero']['West Oakland'],
    'Lake Merritt':2.00, '12th St.':1.76}
neighbors['Fremont'] = {'Union City':4.54} 
neighbors['Union City'] = {'Fremont':neighbors['Fremont']['Union City'], 
    'South Hayward':4.54} 
neighbors['South Hayward'] = {'Union City':neighbors['Union City']['South Hayward'], 
    'Hayward':3.37}
neighbors['Hayward'] = {'South Hayward':neighbors['South Hayward']['Hayward'], 
    'Bay Fair':4.14} 
neighbors['Bay Fair'] = {'Hayward':neighbors['Hayward']['Bay Fair'], 
    'San Leandro':3.32, 'Castro Valley':4.5} 
neighbors['San Leandro'] = {'Bay Fair':neighbors['Bay Fair']['San Leandro'], 
    'Coliseum':3.11} 
neighbors['Coliseum'] = {'San Leandro':neighbors['San Leandro']['Coliseum'], 
    'Fruitvale':2.2} 
neighbors['Fruitvale'] = {'Coliseum':neighbors['Coliseum']['Fruitvale'], 
    'Lake Merritt':3.03} 
neighbors['Lake Merritt'] = {'Fruitvale':neighbors['Fruitvale']['Lake Merritt'], 
    'West Oakland':neighbors['West Oakland']['Lake Merritt'], '12th St.':0.66} 
neighbors['Castro Valley'] = {'Bay Fair':4.5, 'West Dublin':9.25}
neighbors['West Dublin'] = {'Castro Valley':neighbors['Castro Valley']['West Dublin'], 
    'Dublin/Pleasanton':2.38} 
neighbors['Dublin/Pleasanton'] = {'West Dublin':neighbors['West Dublin']['Dublin/Pleasanton']} 
neighbors['12th St.'] = {'West Oakland':neighbors['West Oakland']['12th St.'], 
    'Lake Merritt':neighbors['Lake Merritt']['12th St.'], '19th St.':0.35} 
neighbors['19th St.'] = {'12th St.':neighbors['12th St.']['19th St.'], 
    'MacArthur':1.92}
neighbors['MacArthur'] = {'19th St.':neighbors['19th St.']['MacArthur'], 
    'Ashby':1.87, 'Rockridge':1.77} 
neighbors['Ashby'] = {'MacArthur':neighbors['MacArthur']['Ashby'], 
    'Berkeley':1.67} 
neighbors['Berkeley'] = {'Ashby':neighbors['Ashby']['Berkeley'],
    'North Berkeley':1.13}
neighbors['North Berkeley'] = {'Berkeley':neighbors['Berkeley']['North Berkeley'], 
    'El Cerrito Plaza':3.38} 
neighbors['El Cerrito Plaza'] = {'North Berkeley':neighbors['North Berkeley']['El Cerrito Plaza'], 
    'El Cerrito del Norte':2.34} 
neighbors['El Cerrito del Norte'] = {'El Cerrito Plaza':neighbors['El Cerrito Plaza']['El Cerrito del Norte'], 
    'Richmond':2.21} 
neighbors['Richmond'] = {'El Cerrito del Norte':neighbors['El Cerrito del Norte']['Richmond']}
neighbors['Rockridge'] = {'MacArthur':neighbors['MacArthur']['Rockridge'], 
    'Orinda':5.35} 
neighbors['Orinda'] = {'Rockridge':neighbors['Rockridge']['Orinda'],
    'Lafayette':4.51} 
neighbors['Lafayette'] = {'Orinda':neighbors['Orinda']['Lafayette'], 
    'Walnut Creek':3.92} 
neighbors['Walnut Creek'] = {'Lafayette':neighbors['Lafayette']['Walnut Creek'],
    'Pleasant Hill':2.35} 
neighbors['Pleasant Hill'] = {'Walnut Creek':neighbors['Walnut Creek']['Pleasant Hill'],
    'Concord':4.85} 
neighbors['Concord'] = {'Pleasant Hill':neighbors['Pleasant Hill']['Concord'],
    'North Concord':2.83} 
neighbors['North Concord'] = {'Concord':neighbors['Concord']['North Concord'],
    'Pittsburg/Bay Pt':5.67} 
neighbors['Pittsburg/Bay Pt'] = {'North Concord':neighbors['North Concord']['Pittsburg/Bay Pt']}

# Check for symmetry
sym = True
for st1 in stations:
    for st2 in neighbors[st1].keys():
        sym = sym and (neighbors[st1][st2] == neighbors[st2][st1])
        if not sym:
            print st1 + " " + st2
            break
print sym # symmetric!

# Now create a matrix of distances between every pair of stations
trips = pd.DataFrame({'From':['x'], 'To':['y'], 'Miles':[0]})
i = 0
for st1 in stations:
    for st2 in stations:
        trips = trips.append( {'From':st1, 'To':st2, 'Miles':max(Dijkstra(neighbors, st1, st2)[0].values())}, ignore_index=True)
        i += 1
trips.to_csv('/volumes/no name/BART project/data/BART/Dijkstra miles.csv')