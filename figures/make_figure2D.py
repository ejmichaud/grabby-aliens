import json

from tqdm.auto import tqdm

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.cm

plt.style.use('default')

# Make 2D plots
N = 10000000
D = 2
n = 10
s = 0.125
seed = 0

filename = f"N{N}D{D}n{n}s{s}rs{seed}-v1.json"
with open(f"../output/{filename}", "r") as f:
    C = json.loads(f.read())

origins_and_ws = [((GC['origin'][0], GC['origin'][1], GC['t']), GC['w']) for GC in C]

resolution = 250
skip = 1

fig = plt.figure(figsize=(6, 6))
ax = fig.add_subplot(1, 1, 1, projection='3d')
# ax.scatter(*zip(*origins[::skip]), s=3)
for origin, w in tqdm(origins_and_ws[::skip]):
    x, y, t = origin
    h = np.linspace(0, w, resolution)
    theta = np.linspace(0, 2*np.pi, resolution)
    X = np.outer(s*np.cos(theta), h) + x
    Y = np.outer(s*np.sin(theta), h) + y
    Z = np.outer(np.ones(np.size(theta)), h) + t
    ax.plot_surface(X, Y, Z, color=matplotlib.cm.rainbow(np.random.rand()), alpha=0.4)
ax.view_init(elev=-20)

plt.savefig("2d-wide-plot.svg")
plt.savefig("2d-wide-plot.pdf")
plt.savefig("2d-wide-plot.png", dpi=400)




