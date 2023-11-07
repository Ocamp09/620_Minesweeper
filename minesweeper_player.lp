creator(owen).
creator(karissa).
creator(blake).
creator(max).

% ==============================================================
% Axioms
% ==============================================================
% Fluent?
% danger_level(X, Y, D) :- 
% X is x coordinate of cell, 
% Y is y coordinate of cell
% D is danger level of cell
danger_level(X, Y, D) :- num_x(X), num_y(Y), danger(D).

% safe means that the agent can "click" on the cell and it will not be a mine...
safe(X, Y) :- num_x(X), num_y(Y).


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

% Danger level
danger(0..8).

% Generates the cells for each coordinate specified above
cell(X,Y) :- num_x(X), num_y(Y).

% ==============================================================
% Game Board Facts: what is known about the state of the game
% ==============================================================

% What if the python program never specifies whether a cell is uncovered and only specifies whether the danger level is less than 9?  Covered cells can have danger level 9?  -1?



danger_level(3, 3, 2).
danger_level(3, 4, 2).
danger_level(3, 5, 4).
danger_level(4, 2, 1).
danger_level(4, 3, 1).
danger_level(4, 4, 0).
danger_level(4, 5, 1).
danger_level(5, 2, 1).
danger_level(5, 3, 0).
danger_level(5, 4, 0).
danger_level(5, 5, 2).
danger_level(6, 2, 1).
danger_level(6, 3, 2).
danger_level(6, 4, 1).
danger_level(6, 5, 2).


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
% Dynamic Causal Laws:
% ==============================================================

% If we uncover a cell, the danger_level becomes known...


% ==============================================================
% State Constraints:
% ==============================================================

% If we know the danger_level of a cell, it must be uncovered...

% If count flags in region of a cell equals the danger level of that cell, all remaining cells are safe...

% ==============================================================
% Executability Conditions:
% ==============================================================

% ?????



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



% If there is a cell with danger level 1 and only one undiscovered cell in region, with flag count in region = 0, then place flag in that undiscovered cell.

Moves to make are essentially prioritized as follows:
1) Click on a known "safe" cell -- as determined by logic rules...
2) Place a flag over a known mine
3) Gamble...