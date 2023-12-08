% ===================================================================
% --------------------------------------------------------------
% Title: Minesweeper player using Answer Set Prolog Encoding
% --------------------------------------------------------------
% ===================================================================


% ===================================================================
% Summary
% ===================================================================
% This ASP code contains an logic that will take input from a minesweeper game board and output the move to make for
% that turn. There is an associated python game engine that will decide whether or not the game is won or lost, or
% run clingo again if the game is not complete.

% ===================================================================
% Main Strategy: We're stuck in a minefield and want to live...
% ===================================================================
%"test out" several scenarios to find the safest solutions, given the danger levels in a certain vicinity and current known information?
% How does it choose where to "look"?
% How does it know the likelihood of success from its current options?
% Do we hard code a strategy or have it simulate possibilities from its current position?
% Simulating could lead to an exploding problem... (no pun intended)... factorial possibilities

% Moves are essentially prioritized as follows:
% 1) Click on a known "safe" cell -- as determined by logic rules...
% 2) Simulate possible theories for success, based on the next layer around revealed cells...
%    Then, remove the logically inconsistent theories...
% 3) Gamble...


% ===================================================================
% Methodology:
% ===================================================================
% This ASP program uses the dynamic domain methodology to come up with the safest move
% for the python engine to create


% ===================================================================
% Imported Facts: to be imported to clingo by a Python written file...
% ===================================================================
% board_size(X, Y) -- the size of the minesweeper board, X is the width, Y is the height
% danger_level(X, Y, N) -- a revealed cell on the game board at coordinates (X, Y) with N number of neighboring mines


% ===================================================================
% Output:
% ===================================================================
% The ASP code will output predicates representing a safe cell for the python engine to
% play, this predicate will be should_reveal(X, Y), X is the x-coordinate of the cell and Y is
% the y-coordinate of the cell


% ===================================================================
% Static Facts: Always true for the game of Minesweeper
% ===================================================================
% Extracts x and y dimensions from the board_size predicate (imported by engine)
cells_x(1..X) :- board_size(X, _).
cells_y(1..Y) :- board_size(_, Y).

% Generates the cells for each coordinate specified above
cell(X,Y) :- cells_x(X), cells_y(Y).

% Danger level = possible number of mines in region
range(0..8).
limit(X) :- X = 0..8.


% ==============================================================
% Axioms
% ==============================================================
%==========================
% known_mine_count(X, Y, M)
% the number of known mines in the region around a given cell.
fluent(defined, known_mine_count(X, Y, M)) :- cell(X, Y), range(M).

%==========================
% revealed(X, Y)
% whether a given cell has been revealed yet - either the danger level or as an inferred mine.
fluent(inertial, revealed(X, Y)) :- cell(X, Y).

%==========================
% unrevealed_count(X, Y, U) 
% the number of unrevealed cells in the region around a given cell.
fluent(defined, unrevealed_count(X, Y, U)) :- cell(X, Y), range(U).

%==========================
% safe(X, Y)
% a cell which does not have a mine.
fluent(defined, safe(X, Y)) :- cell(X, Y).

%==========================
% maybe_safe(X, Y)
% a cell which may not have a mine.
fluent(defined, maybe_safe(X, Y)) :- cell(X, Y).

%==========================
% border_cell(X, Y)
% a cell which has unrevealed cells in its region
fluent(defined, border_cell(X, Y)) :- cell(X, Y).


% ==============================================================
% Positive definition of fluents
% ==============================================================

% Danger level is already input by the game engine.
holds(known_mine_count(X, Y, M), I) :- cell(X, Y),
					range(M),
					M = #count { X1, Y1 : -holds(safe(X1, Y1), I), 
					in_region(X1, Y1, X, Y) },
					step(I).

holds(theory_mine_count(X, Y, M), I) :- cell(X, Y),
					range(M),
					M = #count { X1, Y1 : -holds(maybe_safe(X1, Y1), I), 
					in_region(X1, Y1, X, Y) },
					step(I).

holds(unrevealed_count(X, Y, U), I) :- cell(X, Y),
					range(U),
					U = #count { X1, Y1 : -holds(revealed(X1, Y1), I), 
					in_region(X1, Y1, X, Y) },
					step(I).

% ==============================================================
% Helper Predicates: for easier reuse of common concepts
% ==============================================================
%==========================
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

%==========================
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

%==========================
% Define whether a cell is in the same region as another cell.
in_region(X1, Y1, X2, Y2) :- diag_neighbor(X1, Y1, X2, Y2).
in_region(X1, Y1, X2, Y2) :- adj_neighbor(X1, Y1, X2, Y2).

%==========================
% A cell is considered a border cell if it is not revealed and
% if it has cells in its region which are revealed.
holds(border_cell(X, Y), 3) :- cell(X, Y),
					cell(X1, Y1),
					in_region(X1, Y1, X, Y),
					holds(revealed(X1, Y1), 3),
					not holds(revealed(X, Y), 3).

% ==============================================================
% Dynamic Causal Laws:
% ==============================================================

%==========================
% If we uncover a cell, the danger_level becomes known... 
% This is handled by the game engine...


% ==============================================================
% State Constraints:
% ==============================================================

%==========================
% If the danger_level of a cell is known, it must be revealed.
holds(revealed(X, Y), I) :- danger_level(X, Y, D), step(I).

% If a cell is not safe, it must be revealed...
holds(revealed(X, Y), I) :- -holds(safe(X, Y), I).

%==========================
% A given cell can only have one danger level.
:- danger_level(X, Y, D2), danger_level(X, Y, D1), 
	D1 != D2.
	
%==========================
% A given cell can only have one unrevealed_count at a given time step.
:- holds(unrevealed_count(X, Y, U1), I), 
	holds(unrevealed_count(X, Y, U2), I), 
	U1 != U2, step(I).
	
%==========================
% A given cell can only have one mine count at a given time step.
:- holds(known_mine_count(X, Y, U1), I), 
	holds(known_mine_count(X, Y, U2), I), 
	U1 != U2, step(I).


%==========================
% If the known mine count of a cell (number of unsafe cells in its region) 
% equals the danger level of that cell, all remaining cells are safe 
% (because a cell cannot have more unsafe cells than its danger level).
% We use specific time steps here, since this rule only applies before 
% the generator runs.
holds(safe(X2, Y2), 2) :- in_region(X2, Y2, X1, Y1),
				danger_level(X1, Y1, D),
				holds(known_mine_count(X1, Y1, M), 1),
				D = M,
				-holds(revealed(X2, Y2), 1).

%==========================
% If there is a cell whose danger level is equal to the sum of known mines 
% and unrevealed cells, then those unrevealed cells must be mines.
% We use specific time steps here, since this rule only applies before 
% the generator runs.
-holds(safe(X2, Y2), 1) :- in_region(X1, Y1, X2, Y2),
				danger_level(X1, Y1, D),
				holds(known_mine_count(X1, Y1, M), 0),
				holds(unrevealed_count(X1, Y1, U), 0),
				D = M + U,
				-holds(revealed(X2, Y2), 0).

%==========================
% If there is no reason to believe that any cell is safe, based on basic rules,
% A more complex generation is required in steps 3 and 4, in which mines will 
% be placed in step 3 in region of revealed cells and safe cells will be placed 
% similarly such that the danger levels on the borders will be satisfed by the 
% answer set(s).
run_generator :- not safe_move(_, _, 2).

%==========================
% Recursive case rule... try to define possible sets of 
% where the mines could be and where the safe cells could be

% Generate either a safe or unsafe label for each cell defined as a border cell
% as long as run_generator is needed.
holds(maybe_safe(X, Y), 3) | -holds(maybe_safe(X, Y), 3) :- run_generator,
				holds(border_cell(X, Y), 3).
				
% We want to make sure that we do not believe a cell is safe if it is likely to create problems for the danger levels of known/revealed cells


% :- not holds(maybe_safe(X, Y), 3), 
	% not -holds(maybe_safe(X, Y), 3), 
	% holds(border_cell(X, Y), 3).
				
% But we don't want to believe that a cell is safe if it is near a mine and no other information is given about it... so prioritize solutions where we don't assume safety about cells that do not have danger levels near them to indicate that?  
% Then it becomes an Optimization problem...

%==========================
% But all revealed cells / danger levels must be consistent at that time step 
% in order for a set to be included in the answer set...

% Need to tell it to believe or not believe that a cell may be safe...

% :- holds(revealed(X, Y), 3), 
	% holds(theory_mine_count(X, Y, M), 3),
	% danger_level(X, Y, D),
	% holds(border_cell(X1, Y1), 3),
	% D != M.

% 2 by 1 rule - if there is a 3 x 1 section and a 1 and a 2 next to each other, 
% the mine goes in the spot on the other side of the 2 than the 1.
% -holds(safe(X3, Y3), I1) :- limit()
				% holds(revealed(X1, Y1), I),
				% holds(revealed(X2, Y1), I),
				% holds(revealed(X3, Y1), I),
				% danger_level(X1, Y2, 1),
				% danger_level(X2, Y2, 2),
				% diag_neighbor(X1, Y1, X2, Y2),
				% diag_neighbor(X3, Y3, X2, Y2),
				% diag_neighbor(X1, Y3, X2, Y2),
				% diag_neighbor(X3, Y1, X2, Y2),
				% adj_neighbor(X1, Y1, X2, Y1),
				% adj_neighbor(X1, Y1, X1, Y2),
				% adj_neighbor(X3, Y1, X2, Y1),
				% adj_neighbor(X3, Y1, X3, Y2),
				% adj_neighbor(X1, Y3, X1, Y2),
				% adj_neighbor(X1, Y3, X2, Y3),
				% adj_neighbor(X3, Y3, X2, Y3),
				% adj_neighbor(X3, Y3, X3, Y2).

% But there needs to be another rule for when there is a 2 x 3 section up against a border...  if that 1 x 3 row or column is either revealed or out of bounds...
% -holds(safe(X2, Y1), 2) :- danger_level(X1, Y2, 2),
					% danger_level(X1, Y3, 1),
					% X1 = 0,
					% board_size(X, _),
					
% build a pattern repeater, to flip and rotate rules?

% ==============================================================
% Executability Conditions:
% ==============================================================
% Not applicable.


% ==============================================================
% Closed World Assumptions:
% ==============================================================
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
#const n=4. % change the number
step(0..n).
next(I, I1) :- step(I), step(I1), I1 = I+1.

safe_move(X, Y, I) :- holds(safe(X, Y), I).
-safe_move(X, Y, I) :- -holds(safe(X, Y), I).

s_border_cell(X, Y, I) :- holds(border_cell(X, Y), I).
s_maybe_safe(X, Y, I) :- holds(maybe_safe(X, Y), I).
s_maybe_not_safe(X, Y, I) :- -holds(maybe_safe(X, Y), I).

% ==============================================================
% Show Directives:
% ==============================================================

#show safe_move/3.
#show -safe_move/3.
#show run_generator/0.
#show s_maybe_safe/3.
#show s_maybe_not_safe/3.
% #show s_border_cell/3.