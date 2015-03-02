stations = {0:'Millbrae', 1:'SFIA', 2:'San Bruno', 3:'South SF', 4:'Colma',
            5:'Daly City', 6:'Balboa Park', 7:'Glen Park', 8:'24th St.',
            9:'16th St.', 10:'Civic Center', 11:'Powell', 12:'Montgomery',
            13:'Embarcadero', 14:'West Oakland', 15:'Fremont', 16:'Union City',
            17:'South Hayward', 18:'Hayward', 19:'Bay Fair', 20:'San Leandro',
            21:'Coliseum', 22:'Fruitvale', 23:'Lake Merritt', 24:'Castro Valley',
            25:'West Dublin', 26:'Dublin/Pleasanton', 27:'12th St.', 28:'19th St.',
            29:'MacArthur', 30:'Ashby', 31:'Berkeley', 32:'North Berkeley',
            33:'El Cerrito Plaza', 34:'El Cerrito del Norte', 35:'Richmond',
            36:'Rockridge', 37:'Orinda', 38:'Lafayette', 39:'Walnut Creek',
            40:'Pleasant Hill', 41:'Concord', 42:'North Concord', 43:'Pittsburg/Bay Pt'
            }

adj_matrix = []
for x in range(44):
    adj_matrix.append([0]*44)
#is a station next to itself?

# Millbrae
adj_matrix[0][1] = 5.4 # SFIA 
adj_matrix[0][2] = 4.79 # direct connection to San Bruno M-F before 8 pm
# SFIA
adj_matrix[1][0] = adj_matrix[0][1] # Millbrae
adj_matrix[1][2] = 4.06 # San Bruno
# San Bruno
adj_matrix[2][1] = adj_matrix[1][2] # SFIA
adj_matrix[2][3] = 3.43 # South SF
adj_matrix[2][0] = adj_matrix[0][2] # direct connection to Millbrae M-F before 8 pm
# South SF
adj_matrix[3][2] = adj_matrix[2][3] # San Bruno
adj_matrix[3][4] = 1.91 # Colma
# Colma
adj_matrix[4][3] = adj_matrix[3][4] # South SF
adj_matrix[4][5] = 1.91 # Daly City
# Daly City
adj_matrix[5][4] = adj_matrix[4][5] # Colma
adj_matrix[5][6] = 1.74 # Balboa Park
# Balboa Park
adj_matrix[6][5] = adj_matrix[5][6]
adj_matrix[6][7] = 1.67 # Glen Park
# Glen Park
adj_matrix[7][6] = adj_matrix[6][7]
adj_matrix[7][8] = 1.83 # 24th St.
# 24th St.
adj_matrix[8][7] = adj_matrix[7][8]
adj_matrix[8][9] = 0.89 # 16th St.
# 16th St.
adj_matrix[9][8] = adj_matrix[8][9]
adj_matrix[9][10] = 1.37 # Civic Center
# Civic Center
adj_matrix[10][9] = adj_matrix[9][10]
adj_matrix[10][11] = 0.44 # Powell
# Powell
adj_matrix[11][10] = adj_matrix[10][11]
adj_matrix[11][12] = 0.41 # Montgomery
# Montgomery
adj_matrix[12][11] = adj_matrix[11][12]
adj_matrix[12][13] = 0.34 # Embarcadero
# Embarcadero
adj_matrix[13][12] = adj_matrix[12][13]
adj_matrix[13][14] = (8.69 + 9.44)/2 # West Oakland
# West Oakland
adj_matrix[14][13] = adj_matrix[13][14] # Embarcadero
adj_matrix[14][23] = 2.00 # Lake Merritt
adj_matrix[14][27] = 1.76 # 12th St.
# Fremont, end of the line
adj_matrix[15][16] = 4.54 # Union City
# Union City
adj_matrix[16][15] = adj_matrix[15][16] # Fremont
adj_matrix[16][17] = 4.54 # South Hayward
# South Hayward
adj_matrix[17][16] = adj_matrix[16][17] # Union City
adj_matrix[17][18] = 3.37 # Hayward
#Hayward
adj_matrix[18][17] = adj_matrix[17][18] # South Hayward
adj_matrix[18][19] = 4.14 # Bay Fair
# Bay Fair
adj_matrix[19][18] = adj_matrix[18][19] # Hayward
adj_matrix[19][20] = 3.32 # San Leandro
adj_matrix[19][24] = 4.5 # Castro Valley
# San Leandro
adj_matrix[20][19] = adj_matrix[19][20] # Bay Fair
adj_matrix[20][21] = 3.11 # Coliseum
# Coliseum
adj_matrix[21][20] = adj_matrix[20][21] # San Leandro
adj_matrix[21][22] = 2.2 # Fruitvale
# Fruitvale
adj_matrix[22][21] = adj_matrix[21][22] # Coliseum
adj_matrix[22][23] = 3.03 # Lake Merritt
# Lake Merritt
adj_matrix[23][22] = adj_matrix[22][23] # Fruitvale
adj_matrix[23][14] = adj_matrix[14][23] # West Oakland
adj_matrix[23][27] = 0.66 # 12th St.
# Castro Valley
adj_matrix[24][19] = 4.5 # Bay Fair
adj_matrix[24][25] = 9.25 # West Dublin
# West Dublin
adj_matrix[25][24] = adj_matrix[24][25] # Castro Valley
adj_matrix[25][26] = 2.38 # Dublin/Pleasanton
# Dublin/Pleasanton, end of the line
adj_matrix[26][25] = adj_matrix[25][26] # West Dublin
# 12th St. Oakland City Center
adj_matrix[27][14] = adj_matrix[14][27] # West Oakland
adj_matrix[27][23] = adj_matrix[23][27] # Lake Merritt
adj_matrix[27][28] = 0.35 # 19th St.
# 19th St.
adj_matrix[28][27] = adj_matrix[27][28] # 12th St
adj_matrix[28][29] = 1.92 # MacArthur
# MacArthur
adj_matrix[29][28] = adj_matrix[28][29] # 19th St.
adj_matrix[29][30] = 1.87 # Ashby
adj_matrix[29][36] = 1.77 # Rockridge
# Ashby
adj_matrix[30][29] = adj_matrix[29][30] # MacArthur
adj_matrix[30][31] = 1.67 # Berkeley
# Berkeley
adj_matrix[31][30] = adj_matrix[30][31] # Ashby
adj_matrix[31][32] = 1.13 # North Berkeley
# North Berkeley
adj_matrix[32][31] = adj_matrix[31][32] # Berkeley
adj_matrix[32][33] = 3.38 # El Cerrito Plaza
# El Cerrito Plaza
adj_matrix[33][32] = adj_matrix[32][33] # North Berkeley
adj_matrix[33][34] = 2.34 # El Cerrito del Norte
# El Cerrito del Norte
adj_matrix[34][33] = adj_matrix[33][34] # El Cerrito Plaza
adj_matrix[34][35] = 2.21 # Richmond
# Richmond, end of the line
adj_matrix[35][34] = adj_matrix[34][35] # El Cerrito del Norte
# Rockridge
adj_matrix[36][29] = adj_matrix[29][36] # MacArthur
adj_matrix[36][37] = 5.35 # Orinda
# Orinda
adj_matrix[37][36] = adj_matrix[36][37] # Rockridge
adj_matrix[37][38] = 4.51 # Lafayette
# Lafayette
adj_matrix[38][37] = adj_matrix[37][38] # Orinda
adj_matrix[38][39] = 3.92 # Walnut Creek
# Walnut Creek
adj_matrix[39][38] = adj_matrix[38][39] # Lafayette
adj_matrix[39][40] = 2.35 # Pleasant Hill
# Pleasant Hill
adj_matrix[40][39] = adj_matrix[39][40]
adj_matrix[40][41] = 4.85 # Concord
# Concord
adj_matrix[41][40] = adj_matrix[40][41] # Pleasant Hill
adj_matrix[41][42] = 2.83 # North Concord
# North Concord
adj_matrix[42][41] = adj_matrix[41][42] # Concord
adj_matrix[42][43] = 5.67 # Pittsburg/Bay Pt
# Pittsburg/Bay Pt
adj_matrix[43][42] = adj_matrix[42][43]

# Check for symmetry
sym = True
for i in range(44):
    for j in range(44):
        sym = sym and (adj_matrix[i][j] == adj_matrix[j][i])
        if not sym:
            print i, j
            break
print sym # symmetric!

# Dijkstra's algorithm - find shortest distance between each pair of stations

def Dijkstra(from_station, to_station, am):
    # Initialize distance
    dist = [10**10 for x in range(44)]
    dist[from_station] = 0
    # dist represents the shortest distance btwn from_station and each station
    
    visited = [False for x in range(44)] # mark all nodes unvisited
    current_node = from_station
    while True:
        # Calculate tentative distance from current_node to unvisited neighbors
        td = [10**10 for x in range(44)]
        for j in range(0, 44):
            # unvisited, and is a neighbor. A station is not its own n'bor
            if (not visited[j]) and adj_matrix[from_station][j] > 0: 
                td[j] = dist[current_node] + am[from_station][j]
                dist[j] = min(dist[j], td[j])
        visited[current_node] = True # Mark current node as visited
        # print dist
        if visited[to_station]:
            break
        else:
            current_node = dist.index(min(dist))
    return dist[to_station]
# http://www.personal.kent.edu/~rmuhamma/Algorithms/MyAlgorithms/GraphAlgor/dijkstraAlgor.htm
# s, u, v, x, y
km = [[0, 10, 0, 5, 7], [10, 0, 1, 3, 0], [0, 1, 0, 9, 6], [5, 3, 9, 0, 2], [7, 0, 6, 2, 0]]
print Dijkstra(0, 4, km)
