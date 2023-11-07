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
% danger_level(X, Y, D) :- num_x(X), num_y(Y), danger(D).

% safe means that the agent can "click" on the cell and it will not be a mine...
safe(X, Y) :- num_x(X), num_y(Y).

% ===================================================================
% --------------------------------------------------------------
% Static Facts: Always true for the game of Minesweeper
% --------------------------------------------------------------
% ===================================================================

% Danger level
danger(0..8).

% Generates the cells for each coordinate specified above
cell(X,Y) :- num_x(X), num_y(Y).

% ===================================================================
% --------------------------------------------------------------
% Imported Facts: to be imported by a Python written file...
% --------------------------------------------------------------
% ===================================================================

% ==============================================================
% Configuration Facts: basic settings about the game board
% ==============================================================

% Number of cells for x (horizontal) and y (vertical)
num_x(1..7).
num_y(1..7).

% ==============================================================
% Game Board Facts: what is known about the state of the game
% ==============================================================

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

% The ASP program can just re-evaluate which cells are safe and -safe each time...

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
% If the danger_level of a cell is known, it must be uncovered...
uncovered(X, Y) :- danger_level(X, Y, D).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A given cell can only have one danger level
:- danger_level(X, Y, D2), danger_level(X, Y, D1), 
	D1 != D2, danger(D1), danger(D2).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If count flags in region of a cell equals the danger level of that cell, all remaining cells are safe...

% ==============================================================
% Executability Conditions:
% ==============================================================

% ?????



% ==============================================================
% Closed World Assumptions: if we haven't said it already...
% ==============================================================

% CWA: Any cell not defined as uncovered is -uncovered

-uncovered(X, Y) :- not uncovered(X, Y), num_x(X), num_y(Y).

% ??? Any cell which has a danger level other than 9 is uncovered?  Keep???

% danger_level(X, Y, 9) :- not danger_level(X, Y, D), num_x(X), num_y(Y), danger(D).


% ==============================================================
% Main Strategy: We're stuck in a minefield and want to live...
% ==============================================================

% Main strategy: "test out" several scenarios to find the safest solutions, given the danger levels in a certain vicinity and current known information?
% How does it choose where to "look"?
% How does it know the likelihood of success from its current options?
% Do we hard code a strategy or have it simulate possibilities from its current position?
% Simulating could lead to an exploding problem... (no pun intended)... factorial possibilities

% Do we want to pass the safety states back and forth between the game engine and the ASP program, to speed up the processing?  Or does the danger level accomplish that?  Maybe just the -safe cells?



% If there is a cell with danger level 1 and only one undiscovered cell in region, with flag count (-safe(X, Y)) in region(X, Y) = 0, then place flag in that undiscovered cell.

% Moves to make are essentially prioritized as follows:
% 1) Click on a known "safe" cell -- as determined by logic rules...
% 2) Place a flag over a known mine -- Mark a cell as -safe
% 3) Gamble...


% ==============================================================
% Show Directives:
% ==============================================================

#show danger_level/3.
#show uncovered/2.

% #show in_region/4.
