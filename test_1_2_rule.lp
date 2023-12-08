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

% There will need to be a test for 2 x 3 grids for the same rule as well

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
danger_level(6, 2, 2).
danger_level(6, 3, 2).
danger_level(6, 4, 1).
danger_level(6, 5, 2).