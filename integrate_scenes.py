import os
from pathlib import Path

PROJECT_ROOT = Path("C:/Users/ANTONIO/Desktop/GardenWay/garden-way")
SCENES_DIR = PROJECT_ROOT / "Scenes"

def inject_model_to_tscn(tscn_path, model_path, parent_node_path, instance_name, transform_line=""):
    print(f"Injecting {model_path} into {tscn_path} at {parent_node_path}")
    if not tscn_path.exists():
        print(f"Error: {tscn_path} not found.")
        return

    with open(tscn_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    last_ext_idx = -1
    max_id = 0
    for i, line in enumerate(lines):
        if line.startswith("[ext_resource"):
            last_ext_idx = i
            parts = line.split('id="')
            if len(parts) > 1:
                id_str = parts[1].split('"')[0]
                num = ''.join(c for c in id_str.split('_')[0] if c.isdigit())
                if num.isdigit() and int(num) > max_id:
                    max_id = int(num)
                    
        if line.startswith(f'[node name="{instance_name}"'):
            print("Already injected.")
            return

    new_ext_id = f"{max_id + 1}_asset"
    ext_resource_line = f'[ext_resource type="PackedScene" path="{model_path}" id="{new_ext_id}"]\n'
    
    if last_ext_idx != -1:
        lines.insert(last_ext_idx + 1, ext_resource_line)
    else:
        lines.insert(1, ext_resource_line)

    node_definition = f'\n[node name="{instance_name}" parent="{parent_node_path}" instance=ExtResource("{new_ext_id}")]\n'
    if transform_line:
        node_definition += f'transform = {transform_line}\n'

    lines.append(node_definition)

    with open(tscn_path, 'w', encoding='utf-8') as f:
        f.writelines(lines)
    print("Done.")

def remove_node_from_tscn(tscn_path, node_name_to_remove):
    if not tscn_path.exists():
        return
    with open(tscn_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    out_lines = []
    skip = False
    for line in lines:
        if line.startswith("[node "):
            if f'name="{node_name_to_remove}"' in line:
                skip = True
            else:
                skip = False
                
        if not skip:
            out_lines.append(line)
            
    with open(tscn_path, 'w', encoding='utf-8') as f:
        f.writelines(out_lines)

TARGETS = [
    "TargetAimLab.tscn",
    "Target.tscn",
    "GridshotTarget.tscn",
    "PrecisionTarget.tscn",
    "LongRangeTarget.tscn"
]

MODEL_PATH = "res://Assets/Targets/standard_firing_target.glb"

for t in TARGETS:
    tscn_path = SCENES_DIR / t
    remove_node_from_tscn(tscn_path, "CSGSphere3D")
    inject_model_to_tscn(tscn_path, MODEL_PATH, ".", "TargetModel")

print("All targets assigned to the silhouette!")
