import os

player_tscn = 'C:/Users/ANTONIO/Desktop/GardenWay/garden-way/Scenes/Player.tscn'

with open(player_tscn, 'r', encoding='utf-8') as f:
    lines = f.readlines()

out = []
for line in lines:
    out.append(line)
    if line.startswith('[node name="TorsoMesh"') or line.startswith('[node name="Legs"'):
        out.append('visible = false\n')

with open(player_tscn, 'w', encoding='utf-8') as f:
    f.writelines(out)
