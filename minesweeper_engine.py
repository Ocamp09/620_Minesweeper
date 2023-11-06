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

                    for x in range(-1, 2):
                        for y in range(-1, 2):
                            if 0 <= i + x < width and 0 <= j + y < height and self.mine_board[j + y][i + x] == "mine":
                                num_neighboring_mines += 1

                    self.mine_board[j][i] = num_neighboring_mines

    # Function used to display the current status of the game board in the terinal
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
    def reveal_cell(self, x, y):
        # if the cell revealed is a mine, then the game is lost
        if self.mine_board[y][x] == "mine":
            print("Game lost")
            # return True
        # if the current cell is already empty print a message
        elif self.game_board[y][x] != " ":
            print("Cannot play in an already revealed cell")
        # if the cell is not revealed and not a mine then update the cell from the mine board
        else:
            self.game_board[y][x] = self.mine_board[y][x]
            print("New board status")

        # if the game si won then print a message and stop the while loop
        if self.is_game_won():
            print("Game won")
            return True

        return False

    # function evaluates if all the cells in game board are either not empty, or not mines, signifying the game is over
    def is_game_won(self):
        for i in range(self.width):
            for j in range(self.height):
                # If there is an empty space that is not a mine, the game is not won
                if not self.mine_board[j][i] == "mine" and self.game_board[j][i] == " ":
                    return False

        return True


# run the clingo file to get the next best move


# Start the game
game = MinesweeperGame(10, 10, 10)
game_over = False

game_board_str = ""
game_board_str = game_board_str.join(map(str, game.game_board))

game_asp_file = "game_board_data.lp"
player_asp_file = "minesweeper_player.lp"

# write the game board to a file to be opened by the clingo
with open('game_board_data.lp', 'w') as file:
    file.write("board_size({0}, {1}).".format(game.width, game.height))
    # file.write(game_board_str)

# Create a subprocess object to run the ASP code
p = subprocess.Popen(["clingo", player_asp_file, game_asp_file], stdin=subprocess.PIPE, stdout=subprocess.PIPE)

# Receive the output from the ASP code and wait for the subprocess to finish
asp_response = p.stdout.read().decode("utf-8")
p.wait()

# get move from ASP
print(asp_response)

# some starting logic to get revealed cells??

# loop until game is over
# while not game_over:
#     # get game board for ASP
#
#     # send game board to ASP and get response in return
#
#     # add ASP response to reveal_cell
#     game_over = game.reveal_cell(random.randint(0, game.width - 1), random.randint(0, game.height - 1))
#
#     # display new board to see ASP order of actions
#     game.display_board()


