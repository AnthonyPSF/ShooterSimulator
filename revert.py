import os
from pathlib import Path

SCENES_DIR = Path("C:/Users/ANTONIO/Desktop/GardenWay/garden-way/Scenes")
targets = ["GridshotTarget.tscn", "PrecisionTarget.tscn", "LongRangeTarget.tscn"]

for t in targets:
    path = SCENES_DIR / t
    if not path.exists(): continue
    with open(path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    out = []
    for line in lines:
        if 'res://Assets/Targets/' in line: continue
        if 'name="TargetModel"' in line: continue
        out.append(line)
        
    with open(path, 'w', encoding='utf-8') as f:
        f.writelines(out)

print("Reverted untracked targets")
