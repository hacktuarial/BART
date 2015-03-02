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
adj_matrix[0][1] = 1 # SFIA 
adj_matrix[0][2] = 1 # direct connection to San Bruno M-F before 8 pm
# SFIA
adj_matrix[1][0] = 1 # Millbrae
adj_matrix[1][2] = 1 # San Bruno
# San Bruno
adj_matrix[2][1] = 1 # SFIA
adj_matrix[2][3] = 1 # South SF
adj_matrix[2][0] = 1 # direct connection to Millbrae M-F before 8 pm
# South SF
adj_matrix[3][2] = 1 # San Bruno
adj_matrix[3][4] = 1 # Colma
# Colma
adj_matrix[4][3] = 1 # South SF
adj_matrix[4][5] = 1 # Daly City
# Daly City
adj_matrix[5][4] = 1 # Colma
adj_matrix[5][6] = 1 # Balboa Park
# Balboa Park
adj_matrix[6][5] = adj_matrix[5][6]
adj_matrix[6][7] = 1 # Glen Park
# Glen Park
adj_matrix[7][6] = adj_matrix[6][7]
adj_matrix[7][8] = 1 # 24th St.
# 24th St.
adj_matrix[8][7] = adj_matrix[7][8]
adj_matrix[8][9] = 1 # 16th St.
# 16th St.
adj_matrix[9][8] = adj_matrix[8][9]
adj_matrix[9][10] = 1 # Civic Center
# Civic Center
adj_matrix[10][9] = adj_matrix[9][10]
adj_matrix[10][11] = 1 # Powell
# Powell
adj_matrix[11][10] = adj_matrix[10][11]
adj_matrix[11][12] = 1 # Montgomery
# Montgomery
adj_matrix[12][11] = adj_matrix[11][12]
adj_matrix[12][13] = 1 # Embarcadero
# Embarcadero
adj_matrix[13][12] = adj_matrix[12][13]
adj_matrix[13][14] = 1 # West Oakland
# West Oakland
adj_matrix[14][13] = 1 # Embarcadero
adj_matrix[14][23] = 1 # Lake Merritt
adj_matrix[14][27] = 1 # 12th St.
# Fremont, end of the line
adj_matrix[15][16] = 1 # Union City
# Union City
adj_matrix[16][15] = 1 # Fremont
adj_matrix[16][17] = 1 # South Hayward
# South Hayward
adj_matrix[17][16] = 1 # Union City
adj_matrix[17][18] = 1 # Hayward
#Hayward
adj_matrix[18][17] = 1 # South Hayward
adj_matrix[18][19] = 1 # Bay Fair
# Bay Fair
adj_matrix[19][18] = 1 # Hayward
adj_matrix[19][20] = 1 # San Leandro
adj_matrix[19][24] = 1 # Castro Valley
# San Leandro
adj_matrix[20][19] = 1 # Bay Fair
adj_matrix[20][21] = 1 # Coliseum
# Coliseum
adj_matrix[21][20] = 1 # San Leandro
adj_matrix[21][22] = 1 # Fruitvale
# Fruitvale
adj_matrix[22][21] = 1 # Coliseum
adj_matrix[22][23] = 1 # Lake Merritt
# Lake Merritt
adj_matrix[23][22] = 1 # Fruitvale
adj_matrix[23][14] = 1 # West Oakland
adj_matrix[23][27] = 1 # 12th St.
# Castro Valley
adj_matrix[24][19] = 1 # Bay Fair
adj_matrix[24][25] = 1 # West Dublin
# West Dublin
adj_matrix[25][24] = 1 # Castro Valley
adj_matrix[25][26] = 1 # Dublin/Pleasanton
# Dublin/Pleasanton, end of the line
adj_matrix[26][25] = 1 # West Dublin
# 12th St. Oakland City Center
adj_matrix[27][14] = 1 # West Oakland
adj_matrix[27][23] = 1 # Lake Merritt
adj_matrix[27][28] = 1 # 19th St.
# 19th St.
adj_matrix[28][27] = 1 # 12th St
adj_matrix[28][29] = 1 # MacArthur
# MacArthur
adj_matrix[29][28] = 1 # 19th St.
adj_matrix[29][30] = 1 # Ashby
adj_matrix[29][36] = 1 # Rockridge
# Ashby
adj_matrix[30][29] = 1 # MacArthur
adj_matrix[30][31] = 1 # Berkeley
# Berkeley
adj_matrix[31][30] = 1 # Ashby
adj_matrix[31][32] = 1 # North Berkeley
# North Berkeley
adj_matrix[32][31] = 1 # Berkeley
adj_matrix[32][33] = 1 # El Cerrito Plaza
# El Cerrito Plaza
adj_matrix[33][32] = 1 # North Berkeley
adj_matrix[33][34] = 1 # El Cerrito del Norte
# El Cerrito del Norte
adj_matrix[34][33] = 1 # El Cerrito Plaza
adj_matrix[34][35] = 1 # Richmond
# Richmond, end of the line
adj_matrix[35][34] = 1 # El Cerrito del Norte
# Rockridge
adj_matrix[36][29] = 1 # MacArthur
adj_matrix[36][37] = 1 # Orinda
for i in range(37, 44):
    adj_matrix[i][i-1] = 1
    if i < 43:
        adj_matrix[i][i+1] = 1

# Check for symmetry
sym = True
for i in range(44):
    for j in range(44):
        sym = sym and (adj_matrix[i][j] == adj_matrix[j][i])
print sym # symmetric!

# Dijkstra's algorithm
