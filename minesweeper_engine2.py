import subprocess
import random


# This class is a game engine for minesweeper that will be played by an ASP agent
class MinesweeperGame:
    # generate a game board from a given width, height, and number of mines. 
    # Mines are placed randomly, and there is a board with the mines and 
    # the count of cells with neigboring mines, as well as a blank game board
    def __init__(self, width=5, height=5, num_mines=5):
        # set the height, width and number of mines for the game
        self.width = width
        self.height = height
        self.num_mines = num_mines

        # Create the game board with a board that holds the mines and neighboring mine counts, 
        # and a game board to be utilized by the ASP agent
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
                            # make the recursive call to reveal neighboring zero cells, else reveal the first 
                            # layer touching the zero cells
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

    # function evaluates if all the cells in game board are either not empty 
    # or not mines, signifying the game is over
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
                        file.write("danger_level({0},{1},{2}).\n".format(row + 1, col + 1, self.mine_board[col][row]))

        # Create a subprocess object to run the ASP code
        p1 = subprocess.Popen(["clingo", "0", player_asp_file1, game_asp_file], stdin=subprocess.PIPE, stdout=subprocess.PIPE)
        p2 = subprocess.Popen(["clingo", "0", player_asp_file2, game_asp_file], stdin=subprocess.PIPE, stdout=subprocess.PIPE)

        # Receive the output from the ASP code and wait for the subprocess to finish
        asp_response1 = p1.stdout.read().decode("utf-8")
        asp_response2 = p2.stdout.read().decode("utf-8")

        p1.wait()
        p2.wait()

        return self.parse_asp(asp_response1, asp_response2)

    # method to take the raw asp response and turn it into the next coordinates to play
    def parse_asp(self, response, response2):
        print(response2)
        response_arr = response.replace("\r\n", " ").split(" ")
        response2_arr = response2.replace("\r\n", " ").split(" ")
        print("Response 1:")
        print(response_arr)
        print("Response 2:")
        print(response2_arr)
        
        # negotiation process
        # 1) look for guaranteed safe moves from basic rules in player
        # 2) if the number of returned models is = 1 from nostep, all of those moves are guaranteed safe
        # 3) if the number of returned models is = 1 from player, those moves are considered safe (but redundant)
        # 4) if the number of models is multiple, then any of those returned moves have no reason to believe they are unsafe
        
        # get the safe_moves as an array and the maybe_safe as an array
        known_safe = []  # from player version basic rules, guaranteed safety
        likely_safe = []  # from nostep version, more expansive, probably safe, known safe if only one model returned
        likely_safe2 = []  # from player version, probably safe, known safe if only one model returned
        
        for str in response_arr:
            if "safe_move" in str :
                known_safe.append(str)
                # add pairs of coordinates so can be integrated with other files 
        
        print("Known safe:")
        print(known_safe)
        
        # If number of models returned for the files is 1, they can be considered safe moves as well
        
        
        
        # Should never be unsatisfiable, assuming our encodings are correct.
        if "UNSATISFIABLE" in response and "UNSATISFIABLE" in response2:
            print("Error with game board")

        # if no move was returned just do a random move
        # if "safe_move" not in response_arr[7]:
            # x_cord = random.randint(0, self.width - 1)
            # y_cord = random.randint(0, self.height - 1)
            # return x_cord, y_cord

        # get a list of moves returned
        moves_arr = []
        for arr in response_arr:
            if "safe_move" in arr:
                moves_arr.append(arr[arr.find("s"):arr.find(")") + 1:])

        moves2_arr = []
        for arr in response2_arr:
            if "maybe_safe" in arr:
                moves2_arr.append(arr[arr.find("m"):arr.find(")") + 1:])

        # print("move", moves_arr)
        print("move2", moves2_arr)

        move_dict = {}
        for move in moves_arr:
            if move not in move_dict:
                move_dict[move] = 1
                continue
            elif move in move_dict:
                move_dict[move] += 1

        # print(move_dict)

        # if the 7th index has "safe_move" then assign the move
        move = moves_arr[0]
        # narrow down just the coordinates
        coord_start = move.find("(") + 1
        coord_end = move.find(")")
        coord_arr = move[coord_start:coord_end:].split(",")

        # pull the x and y coordinates from array and return
        x_cord = coord_arr[0]
        y_cord = coord_arr[1]
        return x_cord, y_cord

    # function to reveal a random cell/cells to give the ASP code a starting point
    def first_move(self):
        empty_cell = False
        for row in range(self.width):
            if empty_cell:
                break
            for col in range(self.height):
                if empty_cell:
                    break
                elif self.mine_board[row][col] == 0:
                    empty_cell = True
                    self.reveal_cell(col, row)


        # make a new game
        # if not empty_cell:


# Start the game
game = MinesweeperGame(10, 10, 20)
game_over = False

player_asp_file1 = "minesweeper_player.lp"
player_asp_file2 = "minesweeper_nostep.lp"

game.first_move()
print("Starting board: ")
game.display_board()
next_x, next_y = game.write_to_file()
print(next_x, next_y)
# game_over = game.reveal_cell(int(next_x), int(next_y))
# game.display_board()
# # temp variable to stop infinite loops, remove later
# temp = 0
# # loop until game is over
#while temp <= 3 and not game_over:
# while not game_over:
#     # send game board to ASP and get response in return
#     next_cords = game.write_to_file()

    # add ASP response to reveal_cell
    # game_over = game.reveal_cell(random.randint(0, game.width - 1), random.randint(0, game.height - 1))

    # display new board to see ASP order of actions
    # game.display_board()
#     temp += 1