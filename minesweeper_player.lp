creator(owen).
creator(karissa).
creator(blake).
creator(max).

% ===================================================================
% --------------------------------------------------------------
% Static Facts: Always true for the game of Minesweeper
% --------------------------------------------------------------
% ===================================================================

% Danger level = possible number of mines in region
range(0..8).
limit(X) :- X = 0..8.

% Generates the cells for each coordinate specified above
cell(X,Y) :- cells_x(X), cells_y(Y).

% Extracts x and y dimensions from the grid_size predicate (imported by engine)
cells_x(1..X) :- grid_size(X, _).
cells_y(1..Y) :- grid_size(Y, _).

% ===================================================================
% --------------------------------------------------------------
% Imported Facts: to be imported by a Python written file...
% --------------------------------------------------------------
% ===================================================================

% ==============================================================
% Configuration Facts: basic settings about the game board
% ==============================================================

% Number of cells for x (horizontal) and y (vertical)
% grid_size(7, 7).

% ==============================================================
% Game Board Facts: what is known about the state of the game
% ==============================================================

% danger_level(3, 3, 2).
% danger_level(3, 4, 2).
% danger_level(3, 5, 4).
% danger_level(4, 2, 1).
% danger_level(4, 3, 1).
% danger_level(4, 4, 0).
% danger_level(4, 5, 1).
% danger_level(5, 2, 1).
% danger_level(5, 3, 0).
% danger_level(5, 4, 0).
% danger_level(5, 5, 2).
% danger_level(6, 2, 1).
% danger_level(6, 3, 2).
% danger_level(6, 4, 1).
% danger_level(6, 5, 2).

% The ASP program can just re-evaluate which cells are safe and -safe each time...


% ==============================================================
% Axioms
% ==============================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% danger_level(X, Y, D) :- 
% X is x coordinate of cell, 
% Y is y coordinate of cell
% D is danger level of cell

% danger_level(X, Y, D) :- cell(X, Y), limit(D).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% known_mine_count(X, Y, M) 
% the number of known mines in the region around a given cell

fluent(defined, known_mine_count(X, Y, M)) :- cell(X, Y), range(M).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% discovered(X, Y) 
% whether a given cell has been discovered yet

fluent(inertial, discovered(X, Y)) :- cell(X, Y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% undiscovered_count(X, Y, U) 
% the number of undiscovered cells in the region around a given cell

fluent(defined, undiscovered_count(X, Y, U)) :- cell(X, Y), range(U).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% safe(X, Y)
% a cell which does not have a mine.

fluent(defined, safe(X, Y)) :- cell(X, Y).


% ==============================================================
% Positive definition of fluents
% ==============================================================

% Danger level is already input by the game engine

holds(known_mine_count(X, Y, M), I) :- cell(X, Y),
					range(M),
					M = #count { X1, Y1 : -holds(safe(X1, Y1), I), 
					in_region(X1, Y1, X, Y) },
					step(I).


holds(undiscovered_count(X, Y, U), I) :- cell(X, Y),
					range(U),
					U = #count { X1, Y1 : -holds(discovered(X1, Y1), I), 
					in_region(X1, Y1, X, Y) },
					step(I).

% ==============================================================
% Helper Predicates: for easier reuse of common concepts
% ==============================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define adjacent neighbor cells to be the top, bottom, left, and right of a cell.

adj_neighbor(X1, Y1, X2, Y2) :- cell(X1, Y1), 
								cell(X2, Y2), 
								X1 = X2,	
								Y1 = Y2 + 1.
adj_neighbor(X1, Y1, X2, Y2) :- cell(X1, Y1), 
								cell(X2, Y2), 
								X1 = X2,
								Y1 = Y2 - 1.
adj_neighbor(X1, Y1, X2, Y2) :- cell(X1, Y1), 
								cell(X2, Y2), 
								X1 = X2 + 1,	
								Y1 = Y2.
adj_neighbor(X1, Y1, X2, Y2) :- cell(X1, Y1), 
								cell(X2, Y2), 
								X1 = X2 - 1,	
								Y1 = Y2.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define diagonal neighbor cells to be the four corners surrounding a cell.

diag_neighbor(X1, Y1, X2, Y2) :- cell(X1, Y1), 
								cell(X2, Y2), 
								X1 = X2 + 1,	
								Y1 = Y2 + 1.
diag_neighbor(X1, Y1, X2, Y2) :- cell(X1, Y1), 
								cell(X2, Y2), 
								X1 = X2 + 1,	
								Y1 = Y2 - 1.
diag_neighbor(X1, Y1, X2, Y2) :- cell(X1, Y1), 
								cell(X2, Y2), 
								X1 = X2 - 1,	
								Y1 = Y2 + 1.
diag_neighbor(X1, Y1, X2, Y2) :- cell(X1, Y1), 
								cell(X2, Y2), 
								X1 = X2 - 1,	
								Y1 = Y2 - 1.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define whether a cell is in the same region as another cell

in_region(X1, Y1, X2, Y2) :- diag_neighbor(X1, Y1, X2, Y2).
in_region(X1, Y1, X2, Y2) :- adj_neighbor(X1, Y1, X2, Y2).
% Should cells be in their own regions too?  Depends how we plan to use this...

% ==============================================================
% Dynamic Causal Laws:
% ==============================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If we uncover a cell, the danger_level becomes known... 
% This is handled by the game engine...



% ==============================================================
% State Constraints:
% ==============================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If the danger_level of a cell is known, it must be discovered...
holds(discovered(X, Y), I) :- danger_level(X, Y, D), step(I).

% If a cell is not safe, it must be discovered...
holds(discovered(X, Y), I) :- -holds(safe(X, Y), I).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A given cell can only have one danger level
:- danger_level(X, Y, D2), danger_level(X, Y, D1), 
	D1 != D2.
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A given cell can only have one undiscovered_count at a given time step
:- holds(undiscovered_count(X, Y, U1), I), 
	holds(undiscovered_count(X, Y, U2), I), 
	U1 != U2, step(I).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A given cell can only hvae one mine count at a given time step
:- holds(known_mine_count(X, Y, U1), I), 
	holds(known_mine_count(X, Y, U2), I), 
	U1 != U2, step(I).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Unfinished
%%%%%%%%%%%%%%%%%%
% If count -safe in region of a cell equals the danger level of that cell, all remaining cells are safe...

% holds(safe(X2, Y2), I1) :- in_region(X2, Y2, X1, Y1),
				% danger_level(X1, Y1, D),
				% holds(known_mine_count(X1, Y1, M), I),
				% D = M,
				% -holds(discovered(X2, Y2), I),
				% step(I1).

% safe(X1, Y1) :- in_region(X1, Y1, X2, Y2), 
				% danger_level(X2, Y2, D),
				% S = #count { X3, Y3 : -holds(safe(X3, Y3)), in_region(X3, Y3, X2, Y2) },
				% S == D,
				% X3 != X1, X3 != X2,
				% Y3 != Y1, Y3 != Y2,
				% cell(X3, Y3).

% safe(X2, Y2) :- danger_level(X1, Y1, D),
				% known_mine_count(X1, Y1, M),
				% in_region(X2, Y2, X1, Y1),
				% M = D.

% -safe(3, 2).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Unfinished
%%%%%%%%%%%%%%%%%%
% If there is a diag_neighbor cell with a danger level not satisfied by all surrounding cells, and count undiscovered cells is not sufficient wiggle room, then cell is not safe

% Starting with one case, where corner cell is known mine
% Corner Rule
-holds(safe(X2, Y2), I1) :- diag_neighbor(X1, Y1, X2, Y2),
				danger_level(X1, Y1, D),
				D == 1,
				holds(known_mine_count(X1, Y1, M), I),
				M == 0,
				holds(undiscovered_count(X1, Y1, U), I),
				U == 1,
				-holds(discovered(X2, Y2), I),
				next(I, I1).

% -safe(X2, Y2) :- in_region(X2, Y2, X1, Y1),
					% danger_level(X1, Y1, D),
					% known_mine_count(X1, Y1, M),
					% undiscovered_count(X1, Y1, U),
					% D - M = U.


% ==============================================================
% Executability Conditions:
% ==============================================================

% ?????



% ==============================================================
% Closed World Assumptions: if we haven't said it already...
% ==============================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initial situation: what holds at time step 0
% CWA for time step 0

-holds(F, 0) :- fluent(inertial, F), not holds(F, 0).


% ==============================================================
% GENERAL INERTIA AXIOMS FOR INERTIAL FLUENTS:
% ==============================================================

holds(F,I1) :- fluent(inertial,F),
				holds(F,I),
				not -holds(F,I1),
				I < n,
				next(I, I1).
-holds(F,I1) :- fluent(inertial,F),
				-holds(F,I),
				not holds(F,I1),
				I < n,
				next(I, I1).


% ==============================================================
% Step Info:
% ==============================================================

#const n=2. % change the number
step(0..n).
next(I, I1) :- step(I), step(I1), I1 = I+1.


% ==============================================================
% Main Strategy: We're stuck in a minefield and want to live...
% ==============================================================

% Main strategy: "test out" several scenarios to find the safest solutions, given the danger levels in a certain vicinity and current known information?
% How does it choose where to "look"?
% How does it know the likelihood of success from its current options?
% Do we hard code a strategy or have it simulate possibilities from its current position?
% Simulating could lead to an exploding problem... (no pun intended)... factorial possibilities

% Do we want to pass the safety states back and forth between the game engine and the ASP program, to speed up the processing?  Or does the danger level accomplish that?  Maybe just the -safe cells?

% Send only the known danger levels, since ASP can infer the safety of the cells from that...

% If there is a cell with danger level 1 and only one undiscovered cell in region, with flag count (-safe(X, Y)) in region(X, Y) = 0, then place flag in that undiscovered cell.

% Moves are essentially prioritized as follows:
% 1) Click on a known "safe" cell -- as determined by logic rules...
% Nope >> 2) Place a flag over a known mine -- Mark a cell as -safe
% 3) Gamble...


% ==============================================================
% Show Directives:
% ==============================================================

#show danger_level/3.
% #show discovered/2.
% #show -discovered/2.

% #show in_region/4.


s_safe(X, Y, I) :- holds(safe(X, Y), I).
-s_safe(X, Y, I) :- -holds(safe(X, Y), I).

#show s_safe/3.
#show -s_safe/3.

% #show -safe/2.
% #show safe/2.


s_discovered(X, Y, I) :- holds(discovered(X, Y), I).
s_undiscovered_count(X, Y, M, I) :- holds(undiscovered_count(X, Y, M), I), 
								I = 2,
								X >= 3, X <= 4,
								Y >= 2, Y <= 3.
s_known_mine_count(X, Y, M, I) :- holds(known_mine_count(X, Y, M), I), 
								I = 1,
								X >= 3, X <= 4,
								Y >= 2, Y <= 3.

#show s_undiscovered_count/4.
#show s_known_mine_count/4.
#show s_discovered/3.