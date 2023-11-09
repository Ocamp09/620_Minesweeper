import subprocess
import random


# This class is a game engine for minesweeper that will be played by an ASP agent
class MinesweeperGame:
    # generate a game board from a given width, height, and number of mines. Mines are placed randomly, and there is a
    # board with the mines and the count of cells with neigboring mines, as well as a blank game board
    def __init__(self, width=5, height=5, num_mines=5):
        # set the height, width and number of mines for the game
        self.width = width
        self.height = height
        self.num_mines = num_mines

        # Create the game board with a board that holds the mines and neighboring mine counts, and a game board to be
        # utilized by the ASP agent
        self.mine_board = [[None for i in range(width)] for j in range(height)]
        self.game_board = [[" " for i in range(width)] for j in range(height)]

        mines_placed = 0
        # Place the mines randomly
        while mines_placed < num_mines:
            x = random.randint(0, width - 1)
            y = random.randint(0, height - 1)

            # if there is already a mine in that location try again
            if not self.mine_board[y][x] == "mine":
                self.mine_board[y][x] = "mine"
                mines_placed += 1

        # Calculate the number of neighboring mines for each cell
        for i in range(width):
            for j in range(height):
                if self.mine_board[j][i] != "mine":
                    num_neighboring_mines = 0
                    # view all neighboring cells and count the mines
                    for x in range(-1, 2):
                        for y in range(-1, 2):
                            # x and y coordinates of neighboring cells
                            x_cord = i + x
                            y_cord = j + y

                            # if the neighboring coordinates are within the game board
                            if 0 <= x_cord < self.width and 0 <= y_cord < self.height:
                                # if the neighboring cell is a mine add one to the count
                                if self.mine_board[y_cord][x_cord] == "mine":
                                    num_neighboring_mines += 1

                    # set the number of neighboring mines
                    self.mine_board[j][i] = num_neighboring_mines

    # Function used to display the current status of the game board in the terminal
    def display_board(self):
        # Print each row of the board.
        for row in self.game_board:
            print("-" * self.width * 2)
            print("|", end="")

            for cell in row:
                if cell == "mine":
                    print("*", end="|")
                else:
                    print(cell, end="|")
            print()

        print("-" * self.width * 2)

    # method to reveal a cell in the game board, returning true kills the game while loop, false continues
    def reveal_cell(self, x, y, recursive=False):
        # if the cell revealed is a mine, then the game is lost
        if self.mine_board[y][x] == "mine":
            print("Game lost")
            # return True
        # if the current cell is already empty print a message
        elif self.game_board[y][x] != " " and not recursive:
            print("Cannot play in an already revealed cell")
        # if the cell is not revealed and not a mine then update the cell from the mine board
        else:
            # reveal the selected cell
            self.game_board[y][x] = self.mine_board[y][x]

            # if the danger level of revealed cell is zero make recursive calls
            if self.game_board[y][x] == 0:
                # loop through neighboring cells
                for i in range(-1, 2):
                    for j in range(-1, 2):
                        # x and y coordinates of neighboring cells
                        x_cord = i + x
                        y_cord = j + y

                        # if the neighboring coordinates are within the game board
                        if 0 <= x_cord < self.width and 0 <= y_cord < self.height:
                            # if the cell is already revealed skip, else if the cell has no neighboring mines
                            # make the recursive call to reveal neighboring zero cells, else reveal the first layer
                            # touching the zero cells
                            if self.game_board[y_cord][x_cord] != " ":
                                continue
                            elif self.mine_board[y_cord][x_cord] == 0:
                                self.reveal_cell(x_cord, y_cord, True)
                            else:
                                self.game_board[y_cord][x_cord] = self.mine_board[y_cord][x_cord]

        # if the game is won then print a message and stop the while loop with a true return
        if self.is_game_won():
            print("Game won")
            return True

        return False

    # function evaluates if all the cells in game board are either not empty, or not mines, signifying the game is over
    def is_game_won(self):
        # loop through the game/mine board
        for row in range(self.width):
            for col in range(self.height):
                # If there is an empty space that is not a mine, the game is not won
                if not self.mine_board[col][row] == "mine" and self.game_board[col][row] == " ":
                    return False

        return True

    # write the danger levels to the asp file
    def write_to_file(self):
        game_asp_file = "game_board_data.lp"

        # write the game_board board to a file to be opened by the clingo
        with open('game_board_data.lp', 'w') as file:
            file.write("board_size({0}, {1}).\n".format(self.width, self.height))

            # write the revealed cells danger numbers to the asp file
            for col in range(self.height):
                for row in range(self.width):
                    if self.game_board[col][row] != " ":
                        file.write("danger_level({0},{1},{2}).\n".format(row, col, self.mine_board[col][row]))

        # Create a subprocess object to run the ASP code
        p = subprocess.Popen(["clingo", player_asp_file, game_asp_file], stdin=subprocess.PIPE, stdout=subprocess.PIPE)

        # Receive the output from the ASP code and wait for the subprocess to finish
        asp_response = p.stdout.read().decode("utf-8")
        p.wait()

        return self.parse_asp(asp_response)

    # method to take the raw asp response and turn it into the next coordinates to play
    def parse_asp(self, response):
        print(response)
        return response

    # function to reveal a random cell/cells to give the ASP code a starting point
    def first_move(self):
        # get random x and y coordinates
        rand_x = random.randint(0, game.width - 1)
        rand_y = random.randint(0, game.height - 1)

        # if the coordinates are mines then try again, else reveal the cell
        if self.game_board[rand_y][rand_x] == "mine":
            self.first_move()
        else:
            self.reveal_cell(rand_x, rand_y)


# Start the game
game = MinesweeperGame(5, 5, 3)
game_over = False

player_asp_file = "minesweeper_player.lp"

game.first_move()
print("Starting board: ")
game.display_board()
next_cords = game.write_to_file()

# # temp variable to stop infinite loops, remove later
# temp = 0
# # loop until game is over
# while temp <= 3 and not game_over:
#     # send game board to ASP and get response in return
#     next_cords = game.write_to_file()
#
#     # add ASP response to reveal_cell
#     # game_over = game.reveal_cell(random.randint(0, game.width - 1), random.randint(0, game.height - 1))
#
#     # display new board to see ASP order of actions
#     # game.display_board()
#     temp += 1
