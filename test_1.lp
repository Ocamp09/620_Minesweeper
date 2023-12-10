% ===================================================================
% --------------------------------------------------------------
% Imported Facts: to be imported by a Python written file...
% --------------------------------------------------------------
% ===================================================================

% ==============================================================
% Configuration Facts: basic settings about the game board
% ==============================================================

% Number of cells for x (horizontal) and y (vertical)
board_size(3, 3).

% ==============================================================
% Game Board Facts: what is known about the state of the game
% ==============================================================

danger_level(0, 0, 0).
danger_level(1, 0, 0).
danger_level(2, 0, 0).
danger_level(0, 1, 1).
danger_level(1, 1, 2).
danger_level(2, 1, 1).
