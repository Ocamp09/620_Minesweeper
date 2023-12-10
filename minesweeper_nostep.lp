board_size(2,3).
danger_level(1,1,2).


% ++=========================================================================++
% ||                             BOARD RULES                                 ||
% ++=========================================================================++

% Cells range from 1..X and 1..Y, inclusive, of the board size.
cell(1..X, 1..Y) :- board_size(X, Y).

% A cell is adjacent to another cell if the absolute values of the differences
% between both their X and Y coordinates are less than or equal to one.
adj(X1, Y1, X2, Y2) :- cell(X1, Y1),
                       cell(X2, Y2),
                       DX = |X1 - X2|,
                       DY = |Y1 - Y2|,
                       DX <= 1,
                       DY <= 1,
                       DX + DY > 0.
                       
% ++=========================================================================++
% ||                           CANDIDATE RULES                               ||
% ++=========================================================================++

% A cell is revealed if it has a danger level. Revealed cells are immutable.
revealed(X, Y) :- danger_level(X, Y, _).

% A candidate is a an unrevealed cell which borders a revealed cell.
candidate(X1, Y1) :- cell(X1, Y1),
                     not revealed(X1, Y1),
                     adj(X1, Y1, X2, Y2),
                     revealed(X2, Y2).
                     
% ++=========================================================================++
% ||                           GENERATION RULES                              ||
% ++=========================================================================++
                     
% A candidate can be either mined or not mined (mined: verb; to have mine(s)).
mined(X, Y) | -mined(X, Y) :- candidate(X, Y).

% ++=========================================================================++
% ||                             SANITY RULES                                ||
% ++=========================================================================++

% It is impossible for the number of mined cells adjacent to a cell with a
% danger level to not equal the danger level of the cell.
:- MC = #count{ MCAX, MCAY : adj(MCAX, MCAY, X, Y), mined(MCAX, MCAY) },
   danger_level(X, Y, D),
   MC != D.
                     
%#show revealed/2.
%#show candidate/2.
#show -mined/2.
#show mined/2.