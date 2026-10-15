# Steiner Tree Heuristic in OCaml

An OCaml implementation of a randomized heuristic for constructing a short
Steiner tree from a set of two-dimensional points.

This project was developed individually as part of a functional programming
course. The file [`display.ml`](./display.ml) was provided with the assignment;
the graph representation, input handling, optimization algorithm, and program
integration were implemented for this project.

## Project overview

Given a collection of points, the program:

1. Builds an initial connected graph by randomly linking the input points.
2. Repeatedly applies randomized local transformations to the graph.
3. Keeps a transformation only when it decreases the total edge length.
4. Displays the input points and the resulting solution in an OCaml Graphics
   window.

The heuristic can introduce **relay points** (Steiner points) at the barycenter
of three selected vertices. It can then move or remove relay points while
searching for a shorter solution. Because the search is randomized, two runs
may produce different trees.

This is a heuristic approach rather than an exact solver: it aims to find a
short solution efficiently, but it does not guarantee the mathematically
optimal Steiner tree.

## Features

- Functor-based graph implementation parameterized by a node type.
- Immutable graph operations backed by OCaml `Map` and `Set` modules.
- Euclidean edge weights.
- Operations for adding and removing nodes and directed edges.
- Randomized construction of an initial connected graph.
- Randomized local search using three transformations:
  - create a relay point,
  - move an existing relay point,
  - delete a relay point and reconnect its neighbors.
- Progress display during the optimization process.
- Automatic scaling of the final drawing to the graphics window.

## Repository structure

| File | Purpose |
| --- | --- |
| [`graph.ml`](./graph.ml) | Node implementation, graph data structure, and Steiner-tree heuristic |
| [`graph.mli`](./graph.mli) | Public signatures and contracts for the graph module |
| [`read.ml`](./read.ml) | Reads the number of points and their coordinates |
| [`main.ml`](./main.ml) | Program entry point and optimization configuration |
| [`display.ml`](./display.ml) | Graphical rendering module provided with the assignment |
| [`input`](./input) | Example input data |
| [`Makefile`](./Makefile) | Compilation and execution targets |
| [`manuel_utilisation.md`](./manuel_utilisation.md) | Original usage notes |
| [`Rapport.pdf`](./Rapport.pdf) | Project report |

## Requirements

- OCaml
- `ocamlfind`
- The OCaml `graphics` package
- A graphical environment supported by OCaml Graphics
- GNU Make and standard Unix command-line tools for the `make exec` target

On Windows, the project can be run through WSL or an environment such as
MSYS2 that provides the required Unix tools and graphical support.

## Build and run

Compile the project:

```bash
make
```

Compile and run it with the example input:

```bash
make exec
```

The program prints the optimization progress in the terminal and opens a
graphics window when the computation is complete. Press a key in the graphics
window to close it.

Remove generated compilation files and the executable:

```bash
make clean
```

## Input format

The `make exec` target derives the number of points from the number of lines in
the [`input`](./input) file. Each line must contain the Cartesian coordinates
of one point:

```text
x1 y1
x2 y2
x3 y3
```

For example:

```text
100.0 120.0
350.0 180.0
220.0 420.0
```

The input file must end with a newline. When invoking the compiled executable
directly, its standard input must contain the number of points on the first
line, followed by the coordinates:

```text
3
100.0 120.0
350.0 180.0
220.0 420.0
```

## Tuning the search

The number of iterations is configured in [`main.ml`](./main.ml):

```ocaml
let number_of_iterations = 100000
```

Increasing this value generally gives the heuristic more opportunities to
improve the solution, at the cost of a longer execution time. Since the
algorithm uses OCaml's pseudo-random generator, the result is not necessarily
identical between executions.

## Implementation notes

The graph is represented as a pair containing:

- the total weight of all stored edges;
- a map from each node to its set of successors.

The `Graph.Make` functor makes the graph reusable with any node type satisfying
the `MyNodeType` signature. In this project, a node stores its coordinates and
a Boolean identifying whether it is a relay point. Edge weights are Euclidean
distances.

The local search starts from a randomly generated connected graph. At each
iteration it selects one of the available transformations and compares the new
total weight with the current one. Only improving transformations are kept.
This simple acceptance rule makes the implementation easy to follow while
leaving room for future improvements such as simulated annealing or more
advanced neighborhood exploration.

## Possible improvements

- Add deterministic random seeds for reproducible experiments.
- Report the final total length and the number of relay points.
- Add automated tests for graph invariants and transformation operations.
- Compare the heuristic with exact solutions on small point sets.
- Replace the current local-search acceptance rule with simulated annealing
  or another metaheuristic.

## Academic context

This repository is intended to showcase a complete functional-programming
project: abstract data types, functors, persistent data structures,
randomized algorithms, and graphical output are combined in a single OCaml
application.

