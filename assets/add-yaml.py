from ruamel.yaml import YAML
from pathlib import Path

yaml = YAML()
yaml.preserve_quotes = True
yaml.indent(mapping=2, sequence=4, offset=2)

pubspec_path = Path("pubspec.yaml")

with pubspec_path.open("r") as f:
    data = yaml.load(f)

# Changed: instead of a hardcoded list, we now walk the folder tree
root_folder = Path("d:/dev/Flutter/novels/assets/nvls")

# Added: recursively find every directory under root_folder (including itself)
# that directly contains at least one file — Flutter needs each such
# directory listed separately, since folder entries aren't recursive
discovered_assets = []
for dir_path in sorted(p for p in root_folder.rglob("*") if p.is_dir()):
    if any(f.is_file() for f in dir_path.iterdir()):
        # Added: convert to posix-style path with trailing slash,
        # e.g. "assets/nvls/nvl/" — Flutter/YAML expects forward slashes
        discovered_assets.append(dir_path.as_posix() + "/")

# Added: also include the root folder itself if it has files directly in it
if any(f.is_file() for f in root_folder.iterdir()):
    discovered_assets.insert(0, root_folder.as_posix() + "/")

flutter_section = data.setdefault("flutter", {})
assets_list = flutter_section.setdefault("assets", [])

for asset in discovered_assets:
    if asset not in assets_list:
        assets_list.append(asset)

with pubspec_path.open("w") as f:
    yaml.dump(data, f)

print(f"Added {len(discovered_assets)} folder(s) under {root_folder}:")
for a in discovered_assets:
    print(f"  - {a}")
