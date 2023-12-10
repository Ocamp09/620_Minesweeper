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

danger_level(2, 2, 8).

board_size(3, 3).




% === Board Rules =============================================================

% Generates the cells for each coordinate specified above
cell(1..X, 1..Y) :- board_size(X, Y).

% Two cells are adjacent if they are no more than 1 up and 1 to the side apart
adj(X1, Y1, X2, Y2) :- cell(X1, Y1),
                       cell(X2, Y2),
                       |X1 - X2| = DX,
                       |Y1 - Y2| = DY,
                       DX <= 1,
                       DY <= 1,
                       DX + DY != 0.
                       
                       
                       
% === Safety Rules ============================================================

% [Helper] A cell is touched if it is known or believed to be something
touched(X, Y) :- believed_mined(X, Y).
touched(X, Y) :- believed_safe(X, Y).
touched(X, Y) :- known_mined(X, Y).
touched(X, Y) :- known_safe(X, Y).

% [Helper] A cell is "safe" if it is believed or known to be safe
safe(X, Y) :- believed_safe(X, Y).
safe(X, Y) :- known_safe(X, Y).

% [Helper] A cell is "mined" if it is believed or known to have a mine
mined(X, Y) :- believed_mined(X, Y).
mined(X, Y) :- known_mined(X, Y).

% A cell is known to be safe if it has a danger level 
% (the cell has been revealed, and it is not a mine)
known_safe(X, Y) :-  danger_level(X, Y, _).



% === Minesweeper Logic =======================================================

% Rule 1: If the number of untouched cells around a cell with a danger level
%         is equal to the danger level of the cell minus the number of adjacent
%         mined cells, then those untouched cells are believed to be mined.
believed_mined(XA, YA) :- danger_level(X, Y, D),
                          not touched(XA, YA),
                          adj(X, Y, XA, YA),
                          cell(XA, YA),
                          UC = #count{ XUC, YUC : adj(X, Y, XUC, YUC), cell(XUC, YUC), not touched(XUC, YUC) },
                          MC = #count{ XMC, YMC : adj(X, Y, XMC, YMC), mined(XMC, YMC) },
                          UC = D - MC.




% ==============================================================
% Show Directives:
% ==============================================================

%#show safe_move/3.
%#show -safe_move/3.