creator(owen).
creator(karissa).
creator(blake).
creator(max).

% ===================================================================
% --------------------------------------------------------------
% Facts: to be imported by a Python written file...
% --------------------------------------------------------------
% ===================================================================

% ==============================================================
% Configuration Facts: basic settings about the game board
% ==============================================================

% Number of cells for x (horizontal) and y (vertical)
num_x(1..7).
num_y(1..7).

cell(X,Y) :- num_x(X), num_y(Y).

% ==============================================================
% Game Board Facts: what is known about the state of the game
% ==============================================================



% ==============================================================
% Helper Predicates: for easier reuse of common concepts
% ==============================================================

% Define adjacent neighbor cells to be the top, bottom, left, and right of a cell.

adj_neighbor(cell(C1X, C1Y), cell(C2X, C2Y)) :- C1X = C2X,	C1Y = C2Y + 1.
adj_neighbor(cell(C1X, C1Y), cell(C2X, C2Y)) :- C1X = C2X,	C1Y = C2Y - 1.
adj_neighbor(cell(C1X, C1Y), cell(C2X, C2Y)) :- C1X = C2X + 1,	C1Y = C2Y.
adj_neighbor(cell(C1X, C1Y), cell(C2X, C2Y)) :- C1X = C2X - 1,	C1Y = C2Y.


% Define diagonal neighbor cells to be the four corners surrounding a cell.

diag_neighbor(cell(C1X, C1Y), cell(C2X, C2Y)) :- C1X = C2X + 1,	C1Y = C2Y + 1.
diag_neighbor(cell(C1X, C1Y), cell(C2X, C2Y)) :- C1X = C2X + 1,	C1Y = C2Y - 1.
diag_neighbor(cell(C1X, C1Y), cell(C2X, C2Y)) :- C1X = C2X - 1,	C1Y = C2Y + 1.
diag_neighbor(cell(C1X, C1Y), cell(C2X, C2Y)) :- C1X = C2X - 1,	C1Y = C2Y - 1.


% ==============================================================
% Closed World Assumptions: if we haven't said it already...
% ==============================================================

% CWA: Any cell not defined as uncovered is -uncovered

-uncovered(cell(X, Y)) :- not uncovered(cell(X, Y)).

% Any cell which has a danger level 0 or greater is uncovered



% ==============================================================
% Main Strategy: We're stuck in a minefield and want to live...
% ==============================================================

% Main strategy: "test out" several scenarios to find the safest solutions, given the danger levels in a certain vicinity and current known information?
% How does it choose where to "look"?
% How does it know the likelihood of success from its current options?
% Do we hard code a strategy or have it simulate possibilities from its current position?
% Simulating could lead to an exploding problem... (no pun intended)... factorial possibilities



