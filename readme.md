# Solitaire Solver

It's not really a solitaire solver but more of an experiment to see now
big the game trees get and a basis for adding heuristics for determining the
best moves. It tries every move and if there are no more moves for a given game
position, it backtracks until it can find a position where there are moves to try.
It's also very, very slow.

The GCD code needs to be ripped out and rewritten. GCD should be integrated within
the solver not used to queue up individual games. As it is, it (counterintuitively)
gets slower the more cores a CPU has.

Currently it bails after 2,500 moves.