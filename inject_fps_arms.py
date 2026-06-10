import os
from pathlib import Path

SCENES_DIR = Path("C:/Users/ANTONIO/Desktop/GardenWay/garden-way/Scenes")
player_tscn = SCENES_DIR / "Player.tscn"

with open(player_tscn, 'r', encoding='utf-8') as f:
    lines = f.readlines()

out = []
inserted_ext = False
inserted_node = False

for i, line in enumerate(lines):
    # Hide 3rd person arms
    if line.startswith('[node name="RightArmMesh"') or line.startswith('[node name="LeftArmMesh"'):
        out.append(line)
        out.append('visible = false\n')
        continue
        
    if not inserted_ext and line.startswith('[sub_resource'):
        out.append('[ext_resource type="PackedScene" path="res://Scenes/FPSArms.tscn" id="5_fpsarms"]\n')
        inserted_ext = True

    out.append(line)
    
    if not inserted_node and line.startswith('[node name="ToolAttachmentPoint"'):
        # Skip the transform line of ToolAttachmentPoint to insert after it
        pass
        
    if not inserted_node and "transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, -0.6)" in line and lines[i-1].startswith('[node name="ToolAttachmentPoint"'):
        out.append('\n[node name="FPSArms" parent="HeadPivot/MainCamera/ViewmodelPivot" instance=ExtResource("5_fpsarms")]\n')
        inserted_node = True

with open(player_tscn, 'w', encoding='utf-8') as f:
    f.writelines(out)

print("FPSArms injected into Player.tscn!")
