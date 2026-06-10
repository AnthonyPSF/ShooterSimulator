import os
import json
import zipfile
import shutil
from pathlib import Path
import pymupdf  # fitz

# Configuration
PROJECT_ROOT = Path("C:/Users/ANTONIO/Desktop/GardenWay/garden-way")
INPUT_DIR = PROJECT_ROOT / "Resources" / "INPUT"
WORKSPACE_DIR = PROJECT_ROOT / "workspace"
EXTRACTED_DIR = WORKSPACE_DIR / "extracted"
CATALOG_DIR = WORKSPACE_DIR / "catalog"
REPORTS_DIR = PROJECT_ROOT / "reports"

# Ensure directories exist
for d in [WORKSPACE_DIR, EXTRACTED_DIR, CATALOG_DIR, REPORTS_DIR]:
    d.mkdir(parents=True, exist_ok=True)

for cat in ["Models", "Weapons", "Targets", "Textures", "Materials", "Sounds", "UI", "Animations", "Scenes", "Scripts", "Shaders", "Documentation"]:
    (CATALOG_DIR / cat).mkdir(parents=True, exist_ok=True)

# Extension mappings
CATEGORIES = {
    ".glb": "Models", ".gltf": "Models", ".fbx": "Models", ".obj": "Models",
    ".png": "Textures", ".jpg": "Textures", ".jpeg": "Textures", ".tga": "Textures", ".webp": "Textures",
    ".wav": "Sounds", ".ogg": "Sounds", ".mp3": "Sounds",
    ".tscn": "Scenes",
    ".res": "Materials", ".tres": "Materials", ".material": "Materials",
    ".gdshader": "Shaders", ".shader": "Shaders",
    ".gd": "Scripts", ".cs": "Scripts",
    ".cfg": "Documentation", ".md": "Documentation", ".txt": "Documentation"
}

FPS_KEYWORDS = {
    "weapons": ["pistol", "rifle", "shotgun", "sniper", "smg", "launcher", "ak47", "gun"],
    "targets": ["target", "silhouette", "plate", "dummy"],
    "ui": ["crosshair", "ammo", "hit", "score", "indicator", "hud"],
    "audio": ["shoot", "fire", "reload", "impact", "ambient", "step"]
}

def step1_discovery():
    print("Step 1: Discovery")
    discovery = {"files": [], "counts_by_extension": {}}
    for root, dirs, files in os.walk(INPUT_DIR):
        for f in files:
            ext = Path(f).suffix.lower()
            discovery["files"].append(f)
            discovery["counts_by_extension"][ext] = discovery["counts_by_extension"].get(ext, 0) + 1
            
    with open(REPORTS_DIR / "discovery_report.json", "w", encoding="utf-8") as f:
        json.dump(discovery, f, indent=2)
    return discovery

def step2_process_pdf():
    print("Step 2: Process PDF")
    pdf_path = INPUT_DIR / "GUNS.pdf"
    if not pdf_path.exists():
        print("PDF not found!")
        return
        
    doc = pymupdf.open(str(pdf_path))
    content = "# GUNS Documentation\n\n"
    
    for page_num in range(len(doc)):
        page = doc[page_num]
        text = page.get_text()
        links = page.get_links()
        
        content += f"## Page {page_num + 1}\n"
        content += f"{text}\n\n"
        if links:
            content += "### Links Found:\n"
            for link in links:
                if 'uri' in link:
                    content += f"- {link['uri']}\n"
        content += "\n---\n"
        
    with open(REPORTS_DIR / "guns_documentation.md", "w", encoding="utf-8") as f:
        f.write(content)

def safe_extract(zip_path, target_dir):
    with zipfile.ZipFile(zip_path, 'r') as zip_ref:
        for member in zip_ref.namelist():
            # Basic collision handling by appending numbers if needed, but for zip extraction, we just extract.
            # Shutil or ZipFile might overwrite, so let's extract to a unique folder.
            folder_name = Path(zip_path).stem
            extract_path = target_dir / folder_name
            zip_ref.extractall(extract_path)

def step3_controlled_extraction():
    print("Step 3: Controlled Extraction")
    for file in INPUT_DIR.glob("*.zip"):
        safe_extract(file, EXTRACTED_DIR)

def classify_file(file_path):
    ext = file_path.suffix.lower()
    cat = CATEGORIES.get(ext, "Documentation")
    
    # Check if it's a specific type based on name for FPS
    name_lower = file_path.name.lower()
    for w in FPS_KEYWORDS["weapons"]:
        if w in name_lower and cat == "Models":
            cat = "Weapons"
            break
    for t in FPS_KEYWORDS["targets"]:
        if t in name_lower and cat == "Models":
            cat = "Targets"
            break
            
    return cat

def step4_5_6_7_8():
    print("Steps 4-8: Cataloging, Evaluation and Inventory")
    database = []
    inventory = {"total": 0, "categories": {}, "fps_assets": [], "unrecognized": []}
    model_analysis = []
    import_report = "# Godot Import Compatibility Report\n\n"
    
    for root, dirs, files in os.walk(EXTRACTED_DIR):
        for f in files:
            file_path = Path(root) / f
            cat = classify_file(file_path)
            
            # Copy to catalog
            target_path = CATALOG_DIR / cat / f
            
            # Conflict resolution for copying
            if target_path.exists():
                target_path = CATALOG_DIR / cat / f"{file_path.parent.name}_{f}"
                
            shutil.copy2(file_path, target_path)
            
            asset_entry = {
                "name": f,
                "type": cat,
                "original_path": str(file_path),
                "catalog_path": str(target_path)
            }
            database.append(asset_entry)
            
            # Inventory tracking
            inventory["total"] += 1
            inventory["categories"][cat] = inventory["categories"].get(cat, 0) + 1
            
            # FPS specifics
            name_lower = f.lower()
            is_fps = False
            for category, keywords in FPS_KEYWORDS.items():
                if any(kw in name_lower for kw in keywords):
                    is_fps = True
                    break
            if is_fps:
                inventory["fps_assets"].append(f)
                
            # Model Analysis & Godot Compat
            if cat in ["Models", "Weapons", "Targets"]:
                # simplified analysis
                polycount = 0 # Not easy to calculate polycount without a 3D library
                model_entry = {
                    "file": f,
                    "format": file_path.suffix,
                    "materials_assumed": True if "material" in f.lower() else False,
                    "textures_assumed": True if "albedo" in f.lower() or "normal" in f.lower() else False
                }
                model_analysis.append(model_entry)
                
                if file_path.suffix.lower() not in [".glb", ".gltf"]:
                    import_report += f"- [WARNING] {f} is {file_path.suffix}, recommend GLB/GLTF for Godot 4.x\n"
                else:
                    import_report += f"- [OK] {f} is natively supported by Godot 4.x\n"

    with open(PROJECT_ROOT / "asset_database.json", "w", encoding="utf-8") as f:
        json.dump(database, f, indent=2)
        
    with open(REPORTS_DIR / "model_analysis.json", "w", encoding="utf-8") as f:
        json.dump(model_analysis, f, indent=2)
        
    with open(REPORTS_DIR / "godot_import_report.md", "w", encoding="utf-8") as f:
        f.write(import_report)
        
    with open(REPORTS_DIR / "master_asset_inventory.md", "w", encoding="utf-8") as f:
        f.write("# Master Asset Inventory\n\n")
        f.write(f"Total Assets: {inventory['total']}\n\n")
        f.write("## Categories\n")
        for k, v in inventory["categories"].items():
            f.write(f"- {k}: {v}\n")
        f.write("\n## FPS Identified Assets\n")
        for asset in inventory["fps_assets"]:
            f.write(f"- {asset}\n")

if __name__ == "__main__":
    step1_discovery()
    step2_process_pdf()
    step3_controlled_extraction()
    step4_5_6_7_8()
    print("Phase 1 Complete!")
