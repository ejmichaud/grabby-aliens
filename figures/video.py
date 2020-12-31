#!/usr/bin/env python
# coding: utf-8

import json

from tqdm.auto import tqdm

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.cm

from celluloid import Camera

plt.style.use('default')



N = 10000
D = 3
n = 10
s = 0.125
seed = 0




filename = f"N{N}D{D}n{n}s{s}rs{seed}-v1.json"
with open(f"../output/{filename}", "r") as f:
    C = json.loads(f.read())



origins_and_ts = [((GC['origin'], GC['t'])) for GC in C]




np.random.seed(0)
skip = 20


fig = plt.figure(figsize=(6, 6))
ax = fig.add_subplot(1, 1, 1, projection='3d')

camera = Camera(fig)

min_t = origins_and_ts[0][1]
max_t = 0.9
colors = [matplotlib.cm.rainbow(np.random.rand()) for _ in range(len(origins_and_ts))]

for t in tqdm(np.linspace(min_t, max_t, 15)):
    alive_GCs = list(filter(lambda n_and_oandt: n_and_oandt[1][1] < t, enumerate(origins_and_ts)))
    for i, (origin, t0) in alive_GCs[::skip]:
        x, y, z = origin
        r = (t - t0)*s
        u = np.linspace(0, 2 * np.pi, 100)
        v = np.linspace(0, np.pi, 100)
        X = r * np.outer(np.cos(u), np.sin(v)) + x
        Y = r * np.outer(np.sin(u), np.sin(v)) + y
        Z = r * np.outer(np.ones(np.size(u)), np.cos(v)) + z
        ax.plot_surface(X, Y, Z, color=colors[i], alpha=0.6)
    camera.snap()

animation = camera.animate(interval=300)
animation.save('3d-video.mp4')





