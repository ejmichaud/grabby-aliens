import json

from tqdm.auto import tqdm

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.cm

plt.style.use('default')

# Make 1D plots
N = 10000000
D = 1
n = 10
s = 0.125
seed = 0

filename = f"N{N}D{D}n{n}s{s}rs{seed}-v1.json"
with open(f"../output/{filename}", "r") as f:
    C = json.loads(f.read())

C.sort(key=lambda GC: GC['origin'][0])
meeting_points = []
GCs_and_meeting_points = []
for i in range(len(C) - 1):
    x0, t0 = C[i]['origin'][0], C[i]['t']
    x1, t1 = C[i+1]['origin'][0], C[i+1]['t']
    x = ((s*(t1 - t0)) + (x0 + x1)) / 2
    t = t0 + (x - x0)*(1/s)
    GCs_and_meeting_points.append((x0, t0))
    GCs_and_meeting_points.append((x, t))
    meeting_points.append((x, t))
GCs_and_meeting_points.append((C[-1]['origin'][0], C[-1]['t']))

plt.figure(figsize=(6, 2.5))
ax = plt.subplot(1, 1, 1)

xs = [GC['origin'][0] for GC in C]
ts = [GC['t'] for GC in C]
plt.scatter(xs, ts, s=3.5, color='blue', label="GC origin")

plt.plot(*zip(*GCs_and_meeting_points), linewidth=0.85, color='purple', label="GC expansion boundary")
plt.xlabel("x", fontsize=11)
plt.xticks(fontsize=9)
plt.ylabel("t", fontsize=11)
plt.yticks(fontsize=9)
# plt.ylim(None, 0.47)

plt.grid(True)
ax.set_axisbelow(True)

plt.legend(prop={'size': 7})

plt.subplots_adjust(bottom=0.2)

plt.savefig("1d-plot.svg")
plt.savefig("1d-plot.pdf")
plt.savefig("1d-plot.png", dpi=400)



