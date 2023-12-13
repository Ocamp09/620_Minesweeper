import subprocess
import random
import argparse


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
        
    # Function to display the complete board in terminal
    def display_mine_board(self):
        # Print each row of the board.
        for row in self.mine_board:
            print("-" * self.width * 2)
            print("|", end="")

            for cell in row:
                if cell == "mine":
                    print("*", end="|")
                else:
                    print(cell, end="|")
            print()

        print("-" * self.width * 2)
        
    def display_both_boards(self):
        # Print each row of the board.
        print("ASP Agent's Knowledge:", end="")
        print(" " * (self.width - 5), end="")
        print("Game Engine's Knowledge:")
        for i in range(0, len(self.game_board)):
            grow = self.game_board[i]
            mrow = self.mine_board[i]
            
            print("-" * (self.width * 2 + 1), " " * 4, "-" * (self.width * 2 + 1))
            print("|", end="")

            for cell in grow:
                if cell == "mine":
                    print("*", end="|")
                else:
                    print(cell, end="|")

            print(" " * 5, "|", end="")
            
            
            for mine in mrow:
                if mine == "mine":
                    print("*", end="|")
                else:
                    print(mine, end="|")
            print()

        print("-" * (self.width * 2 + 1), " " * 4, "-" * (self.width * 2 + 1))

    # method to reveal a cell in the game board, returning true kills the game while loop, false continues
    def reveal_cell(self, x, y, recursive=False):
        # if the cell revealed is a mine, then the game is lost
        if self.mine_board[y][x] == "mine":
            print("Game lost")
            return True
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

    # write the danger levels to an ASP file and run the agent ASP files
    def write_to_file(self):
        game_asp_file = "game_board_data.lp"

        # write the game_board board to a file to be opened by the clingo
        with open('game_board_data.lp', 'w') as file:
            file.write("board_size({0}, {1}).\n".format(self.width, self.height))

            # write the revealed cells danger numbers to the ASP file
            for col in range(self.height):
                for row in range(self.width):
                    if self.game_board[col][row] != " ":
                        file.write("danger_level({0},{1},{2}).\n".format(row + 1, col + 1, self.mine_board[col][row]))

        # Create a subprocess object to run the ASP code
        if args.player:
            p1 = subprocess.Popen(["clingo", "0", player_asp_file1, game_asp_file], stdin=subprocess.PIPE, stdout=subprocess.PIPE)
            # Receive the output from the ASP code and wait for the subprocess to finish
            asp_response = p1.stdout.read().decode("utf-8")
            p1.wait()
        else:
            p2 = subprocess.Popen(["clingo", "0", player_asp_file2, game_asp_file], stdin=subprocess.PIPE, stdout=subprocess.PIPE)
            asp_response = p2.stdout.read().decode("utf-8")
            p2.wait()

        return self.parse_asp(asp_response)

    # method to clean up the response text before splitting into array components
    def clean_resp(self, response):
        response = response.replace("\r\n", " ")
        while "  " in response:
            response = response.replace("  ", " ")
        return response

    # method to take the raw asp response and turn it into the next coordinates to play
    def parse_asp(self, response):
        print(response)
        response_arr = self.clean_resp(response).split(" ")
        
        
        if args.player:
            # negotiation process
            # 1) look for guaranteed safe moves from basic rules in player
            # 2) if the number of returned models is = 1, those moves are considered safe
            # 3) if a move shows up in all proposed answer sets, it is considered safe
            # 4) if the number of models is multiple, then any of those returned moves have no reason to believe they are unsafe
            # But it is still good to choose one which has more explanations in which it is considered safe.
            
            known_safe = []  # guaranteed safe moves
            maybe_safe = []  # these moves are not guaranteed
            # include sets for display and traversal for counting occurences
            known_safe_set = []
            maybe_safe_set = []
            model_count = int(response_arr[response_arr.index("Models") + 2])
            
            # Define a dictionary to keep track of counts of coords
            counts = {}
            
            for str in response_arr:
                if "safe_move" in str:
                    str = str.replace("safe_move(", "").replace(")", "")   # trim unnecessary bits
                    coords = str.split(",")   # get array from remaining string
                    coords = [int(coord) for coord in coords]   # convert to int data type
                    known_safe.append(coords)
                    if not coords in known_safe_set:
                        known_safe_set.append(coords)
                elif "maybe_safe" in str and model_count == 1:
                    str = str.replace("maybe_safe(", "").replace(")", "")   # trim unnecessary bits
                    coords = str.split(",")   # get array from remaining string
                    coords = [int(coord) for coord in coords]   # convert to int data type
                    known_safe.append(coords)
                    if not coords in known_safe_set:
                        known_safe_set.append(coords)
                elif "maybe_safe" in str:
                    str = str.replace("maybe_safe(", "").replace(")", "")   # trim unnecessary bits
                    coords = str.split(",")   # get array from remaining string
                    coords = [int(coord) for coord in coords]   # convert to int data type
                    maybe_safe.append(coords)
                    if not coords in maybe_safe_set:
                        maybe_safe_set.append(coords)

            # if a set of coords is in all returned answer sets, it must be guaranteed safe.
            i = 0
            while i < len(maybe_safe_set):
                item = maybe_safe_set[i]
                item_count = maybe_safe.count(item)
                if item_count == model_count:
                    known_safe_set.append(item)
                    maybe_safe_set.remove(item)                    
                else:
                    if item_count in counts:
                        tmp_list = counts[item_count]
                        tmp_list.append(item)
                        counts[item_count] = tmp_list
                    else:
                        tmp_list = []
                        tmp_list.append(item)
                        counts[item_count] = tmp_list
                    i = i + 1
            
            # prioritize the maybe_safe coords with higher number of occurences, Order the items in terms of counts
            sorted_counts_list = sorted(counts.keys(), reverse=True)
            sorted_maybe_safe = []
            for i in range(0, len(sorted_counts_list)):
                # get the map entry and add all items in the entry to the list...
                tmp_list = counts[sorted_counts_list[i]]
                for j in range(0, len(tmp_list)):
                    sorted_maybe_safe.append(tmp_list[j])
            maybe_safe_set = sorted_maybe_safe
            
            # Should never be unsatisfiable, assuming our encodings are correct.
            if "UNSATISFIABLE" in response and "UNSATISFIABLE" in response2:
                print("Agent could not deduce any possible safe moves.")

            if len(known_safe_set) != 0:
                x_cord = known_safe_set[0][0]
                y_cord = known_safe_set[0][1]
            else:  # Want to prioritize maybe_safe_set to take most likely safe moves
                x_cord = maybe_safe_set[0][0]
                y_cord = maybe_safe_set[0][1]
            
            # Print the known and maybe safe moves
            print("Known safe:")
            print(known_safe_set)
            print("Maybe safe:")
            print(maybe_safe_set)
            
            print("\nSelected Coordinates:")
            print(x_cord, ", ", y_cord, sep="")
        
        
        if args.nostep:
            print("")
        
        return x_cord - 1, y_cord - 1

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

parser = argparse.ArgumentParser(description='A script with a boolean command line flag.')
parser.add_argument('--nostep', action='store_true', help='Use nostep ASP implementation')
parser.add_argument('--player', action='store_true', help='Use player ASP implementation')
args = parser.parse_args()

if args.nostep:
    print("\nUsing nostep ASP solver...\n")
if args.player:
    print("\nUsing player ASP solver...\n")

# Give the ASP agent something to start with
game.first_move()

# Display both boards side by side
game.display_both_boards()
next_x, next_y = game.write_to_file()

# print(next_x, next_y)
game_over = game.reveal_cell(int(next_x), int(next_y))
game.display_both_boards()
# game.display_board()
# # temp variable to stop infinite loops, remove later
temp = 0
# loop until game is over
while not game_over:
    # send game board to ASP and get response in return
    next_cords = game.write_to_file()
    
    # add ASP response to reveal_cell
    game_over = game.reveal_cell(next_cords[0], next_cords[1])

    # display new board to see ASP order of actions
    game.display_both_boards()
    
    # increment temp
    temp = temp + 1
