import os
import json
import shutil
from pathlib import Path

# Configuration
PROJECT_ROOT = Path("C:/Users/ANTONIO/Desktop/GardenWay/garden-way")
CATALOG_DIR = PROJECT_ROOT / "workspace" / "catalog"
ASSETS_DIR = PROJECT_ROOT / "Assets"
REPORTS_DIR = PROJECT_ROOT / "reports"
DB_PATH = PROJECT_ROOT / "asset_database.json"

# Define target directories
TARGET_DIRS = {
    "Weapons": ASSETS_DIR / "Weapons",
    "Targets": ASSETS_DIR / "Targets",
    "Textures": ASSETS_DIR / "Textures",
    "Materials": ASSETS_DIR / "Materials",
    "Sounds": ASSETS_DIR / "Audio",
    "UI": ASSETS_DIR / "UI",
    "Models": ASSETS_DIR / "Models",
    "Shared": ASSETS_DIR / "Shared"
}

# Ensure directories exist
for d in TARGET_DIRS.values():
    d.mkdir(parents=True, exist_ok=True)

def run_phase_2():
    print("Starting Phase 2 Integration...")
    
    if not DB_PATH.exists():
        print("Error: asset_database.json not found!")
        return

    with open(DB_PATH, "r", encoding="utf-8") as f:
        database = json.load(f)

    import_log = "# Godot Asset Import Log\n\n"
    final_usage = "# Final Asset Usage\n\n"
    unused_assets = "# Unused Assets\n\n"
    
    db_updated = []
    counts = {k: 0 for k in TARGET_DIRS.keys()}
    counts["Unused"] = 0

    for asset in database:
        src_path = Path(asset["catalog_path"])
        name = asset["name"]
        asset_type = asset["type"]

        # Selection criteria (Etapa 2)
        # Skip files that are size 0 or obviously corrupt
        if not src_path.exists() or src_path.stat().st_size == 0:
            unused_assets += f"- [CORRUPT/MISSING] {name}\n"
            counts["Unused"] += 1
            asset["status"] = "discarded"
            asset["reason"] = "corrupt or missing"
            db_updated.append(asset)
            continue

        # Skip duplicated names from extraction conflicts if they have multiple underscores from my previous script (Optional heuristic)
        # Actually, let's keep it simple: import everything valid, but map it to the right folder.

        target_folder = TARGET_DIRS.get(asset_type, TARGET_DIRS["Shared"])
        
        # Specific mappings
        if asset_type == "Weapons":
            target_folder = TARGET_DIRS["Weapons"]
        elif asset_type == "Targets":
            target_folder = TARGET_DIRS["Targets"]
        elif asset_type == "Sounds":
            target_folder = TARGET_DIRS["Sounds"]
        
        target_path = target_folder / name
        
        # Etapas 3, 4, 5, 6 - Integration
        try:
            shutil.copy2(src_path, target_path)
            import_log += f"- [SUCCESS] Copied {name} to {target_folder.relative_to(PROJECT_ROOT)}\n"
            final_usage += f"- {target_folder.name}/{name}\n"
            
            # Map category name back to count key
            cat_key = asset_type if asset_type in counts else "Shared"
            if asset_type == "Sounds": cat_key = "Sounds"
            
            counts[cat_key] = counts.get(cat_key, 0) + 1
            
            asset["status"] = "integrated"
            asset["final_path"] = str(target_path)
        except Exception as e:
            import_log += f"- [ERROR] Failed to copy {name}: {e}\n"
            unused_assets += f"- [ERROR] {name}\n"
            counts["Unused"] += 1
            asset["status"] = "error"
            asset["reason"] = str(e)
            
        db_updated.append(asset)

    # Save deliverables (Etapa 7 & Entregables Finales)
    import_log += "\n## Integration Summary\n"
    final_usage += "\n## Category Counts\n"
    for k, v in counts.items():
        if k != "Unused":
            final_usage += f"- {k}: {v}\n"
            
    with open(REPORTS_DIR / "import_log.md", "w", encoding="utf-8") as f:
        f.write(import_log)
        
    with open(REPORTS_DIR / "final_asset_usage.md", "w", encoding="utf-8") as f:
        f.write(final_usage)
        
    with open(REPORTS_DIR / "unused_assets.md", "w", encoding="utf-8") as f:
        f.write(unused_assets)
        
    with open(PROJECT_ROOT / "asset_database_updated.json", "w", encoding="utf-8") as f:
        json.dump(db_updated, f, indent=2)

    print("Phase 2 Integration Complete!")

if __name__ == "__main__":
    run_phase_2()
