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
                     
% A wild cell is an unrevealed cell which is not a candidate (IE it is not
% adjacent to a revealed cell).
wild(X, Y) :- cell(X, Y),
              not candidate(X, Y),
              not revealed(X, Y).
                     
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
   
% ++=========================================================================++
% ||                             OUTPUT RULES                                ||
% ++=========================================================================++

% A "safe move" is one which is thought to not contain a mine.
safe_move(X, Y) :- -mined(X, Y).

% Helper flag. It signifies the use of unmined cells as "safe" moves. If at
% least one unmined cell exists, then only unmined cells will be used as "safe"
% moves.
using_unmined_cells :- -mined(_, _).

% If no unmined cells exist, then we say all wild cells are "safe" moves. We
% don't actually have enough information to predict whether each wild cell is
% mined or not. However, we know all the candidate cells are mined. So, a cell
% which may or may not be mined is a safer choice than one which is definitely
% mined.
safe_move(X, Y) :- wild(X, Y),
                   not using_unmined_cells.
       
                     
%#show revealed/2.
%#show candidate/2.
%#show -mined/2.
%#show mined/2.
#show safe_move/2.
#show using_unmined_cells/0.