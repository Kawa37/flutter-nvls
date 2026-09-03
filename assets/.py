import os

dirs = os.listdir("assets/nvls/")

paths = []
for di in dirs:
    paths.append(di)

for i in paths:
    print(f"- assets/nvls/{i}/")
