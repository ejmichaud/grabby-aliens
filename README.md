# grabby-aliens
Simulations for Robin Hanson's mathematical model of aggressive alien expansion

So far, I've managed to replicate his basic simulations from his blog post: https://www.overcomingbias.com/2020/12/how-far-aggressive-aliens-part-2.html

Check out the `replicating-hansons-sims.ipynb` notebook to see how I replicated his figure! This was a fun and fairly straightforward exercise. 

To run a simulation, simply run the `sim.jl` script with the relevant arguments:
```
$ julia sim.jl --help
usage: sim.jl [-N N] [-D D] [-n N] [-s SPEED] [--dir DIR] [-q] [-h]

Run simulation and write list of civs (with origin position and origin
time) to a .json file.

optional arguments:
  -N N               the number of samples to use. (type: Int64,
                     default: 4000)
  -D D               the effective dimension of space (type: Int64,
                     default: 3)
  -n N               the number of hard try-try steps (type: Int64,
                     default: 10)
  -s, --speed SPEED  the speed of expanding GCs (in units of c) (type:
                     Float64, default: 0.125)
  --dir DIR          directory to save output (json) to (default:
                     "/Users/Eric/Desktop/CS_Research/grabby-aliens")
  -q, --quiet        don't display progress to stdout, only create
                     file
  -h, --help         show this help message and exit
```

