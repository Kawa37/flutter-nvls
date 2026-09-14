import os, json
from pathlib import Path

base = "d:/dev/Flutter/novels/assets/nvls/"
nvlsFs = os.listdir(base)

# with open("./assets/blocked-nvls.txt") as f:
#     blockedNvls = [line.strip() for line in f.read().split("\n") if line]
blockedNvls = []

data = []

co = 0
for nvl in nvlsFs:
    if nvl in blockedNvls:
        # print("blocked", nvl)
        co += 1
        continue

    nvlsChs = len(
        [
            chap
            for chap in os.listdir(f"{base}{nvl}")
            if chap.split(".")[0].isdigit() and chap.split(".")[1] == "txt"
        ]
    )
    readingKey = "".join([w[0] for w in nvl.split("_") if w]) + "_reading"
    title = " ".join([w.capitalize() for w in nvl.split("_") if w])
    description = ""
    if Path(f"{base}{nvl}/description.csv").exists():
        with open(f"{base}{nvl}/description.csv", "r") as f:
            description = f.read()

    data.append(
        {
            "id": nvl,
            "value": {
                "chapters": nvlsChs,
                "readingKey": readingKey,
                "title": title,
                "description": description,
            },
        }
    )

print(f"[*] {len(data)} Novels added")
print(f"[*] {co} Novels blocked")
with open("data.json", "w") as f:
    json.dump(data, f, indent=4)
