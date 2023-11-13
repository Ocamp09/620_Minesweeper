% ===================================================================
% --------------------------------------------------------------
% Imported Facts: to be imported by a Python written file...
% --------------------------------------------------------------
% ===================================================================

% ==============================================================
% Configuration Facts: basic settings about the game board
% ==============================================================

% Number of cells for x (horizontal) and y (vertical)
grid_size(3, 3).

% ==============================================================
% Game Board Facts: what is known about the state of the game
% ==============================================================

danger_level(2, 1, 2).
danger_level(1, 2, 1).
danger_level(2, 2, 2).
danger_level(3, 2, 1).
danger_level(1, 3, 0).
danger_level(2, 3, 0).
danger_level(3, 3, 0).