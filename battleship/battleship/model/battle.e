note
	description: "Summary description for {BATTLE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	BATTLE

create
	make

feature {NONE} -- Initialization
	make
			-- Initialization for `Current'.
		do
			new_game_started := false
			debug_mode := false
			current_difficulty := 0		-- not set. so it displays nothing
			current_board_size := easy_board_size
			create board.make_filled('_', 1, current_board_size * current_board_size)

			current_game := 0
			current_fire := 0
			current_bomb := 0
			current_score := 0
			current_ships := 0
			current_fire_limit := easy_fire_limit
			current_bomb_limit := easy_bomb_limit
			current_score_limit := easy_score_limit
			current_ships_limit := easy_ships_limit
			total_score_current := 0
			total_score_limit := 0
			row_chars := <<'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L'>>

			cmd_status_msg := "OK"
			game_msg := "Start a new game"

			create gen_ship.make_empty
			generated_ships := gen_ship.generate_ships (debug_mode, current_board_size, current_ships_limit)
			create generated_ships_index.make (0)

		end

	-- Reset variables for new_game and debug_test
	reset(debugMode: BOOLEAN; level: INTEGER_64)
		do
			-- reset all variables
			new_game_started := true
			debug_mode := debugMode
			current_difficulty := level
			current_game := current_game + 1 -- new(next) game

			cmd_status_msg := "OK"
			game_msg := "Fire Away!"

			if level ~ 13 then
				current_fire_limit := easy_fire_limit
				current_bomb_limit := easy_bomb_limit
				current_score_limit := easy_score_limit
				current_ships_limit := easy_ships_limit
				current_board_size := easy_board_size
			elseif level ~ 14 then
				current_fire_limit := medium_fire_limit
				current_bomb_limit := medium_bomb_limit
				current_score_limit := medium_score_limit
				current_ships_limit := medium_ships_limit
				current_board_size := medium_board_size
			elseif level ~ 15 then
				current_fire_limit := hard_fire_limit
				current_bomb_limit := hard_bomb_limit
				current_score_limit := hard_score_limit
				current_ships_limit := hard_ships_limit
				current_board_size := hard_board_size
			elseif level ~ 16 then
				current_fire_limit := advanced_fire_limit
				current_bomb_limit := advanced_bomb_limit
				current_score_limit := advanced_score_limit
				current_ships_limit := advanced_ships_limit
				current_board_size := advanced_board_size
			end

			-- clear board
			create board.make_filled('_', 1, current_board_size * current_board_size)

			-- generate ships (debug mode, board_size, # of ships)
			-- if direction is true, vertical
			generated_ships := gen_ship.generate_ships (debug_mode, current_board_size, current_ships_limit)
			generated_ships_index.wipe_out
			test_ships_generated

			-- Before reset variables, stack scores to total score
			total_score_limit := total_score_limit + current_score_limit
			total_score_current := total_score_current + current_score

			current_fire := 0
			current_bomb := 0
			current_score := 0
			current_ships := 0

		end

feature {NONE} -- Attributes
	gen_ship: GEN_SHIP		-- use to generate ships in random
	generated_ships: ARRAYED_LIST[TUPLE[size: INTEGER; row: INTEGER; col: INTEGER; dir: BOOLEAN]]
	generated_ships_index: ARRAYED_LIST[TUPLE[size: INTEGER; pos: ARRAY[INTEGER]; dir: BOOLEAN; alldown: BOOLEAN]]	-- oracle ships coord is not exactly matching.

	debug_mode: BOOLEAN
	current_difficulty: INTEGER_64	-- 13, 14, 15, 16 (easy, medium, hard, advanced)
	board: ARRAY[CHARACTER]
	total_score_current: INTEGER
	total_score_limit: INTEGER

	current_board_size: INTEGER
	current_game: INTEGER		-- indicates number of games currently running
	current_fire, current_bomb, current_score, current_ships: INTEGER
	current_fire_limit, current_bomb_limit, current_score_limit, current_ships_limit: INTEGER

	--easy_game_attributes: ARRAY[INTEGER]
	easy_board_size: INTEGER = 4		-- easy game attributes
	easy_fire_limit : INTEGER = 8
	easy_bomb_limit : INTEGER = 2
	easy_score_limit : INTEGER = 3
	easy_ships_limit : INTEGER = 2

	medium_board_size: INTEGER = 6	-- medium game attributes
	medium_fire_limit : INTEGER = 16
	medium_bomb_limit : INTEGER = 3
	medium_score_limit : INTEGER = 6
	medium_ships_limit : INTEGER = 3


	hard_board_size: INTEGER = 8		-- hard game attributes
	hard_fire_limit : INTEGER = 24
	hard_bomb_limit : INTEGER = 5
	hard_score_limit : INTEGER = 15
	hard_ships_limit : INTEGER = 5

	advanced_board_size: INTEGER = 12		-- advanced game attributes
	advanced_fire_limit : INTEGER = 40
	advanced_bomb_limit : INTEGER = 7
	advanced_score_limit : INTEGER = 28
	advanced_ships_limit : INTEGER = 7

	row_chars: ARRAY[CHARACTER]

feature {ETF_COMMAND}
	-- in the middle of game, new_game command doesn't work
	game_finished: BOOLEAN
		do

		end
	new_game_started: BOOLEAN		-- if new_game not started but command entered, error message display
	cmd_status_msg: STRING
	game_msg: STRING

feature {NONE} -- Utility
	-- convert ships generated coord to board index
	-- if debug mode, display 'v' and 'h' on board
	-- dir is true => Vertical
	convert_shipCoord_to_index (debugMode: BOOLEAN)
		local
			board_index: INTEGER
			i: INTEGER
			tempArray: ARRAY[INTEGER]
		do

			across
				generated_ships as ship
			loop
				-- init, clear temporary array
				create tempArray.make_empty

				from i := 1 until i > ship.item.size
				loop
					--print("%N["+ i.out +"]Displaying ship -> Size: " + ship.item.size.out + ", Pos: [" + ship.item.row.out + ", " + ship.item.col.out + "], Dir: " + ship.item.dir.out)

					if ship.item.dir then

						board_index := (current_board_size * (ship.item.row - 0)) + (ship.item.col + ((i - 1) * current_board_size))
						--print("%NBoard index is " + board_index.out)
						tempArray.force (board_index, i)	-- push index

						if debugMode then
							board.put ('v', board_index)	-- v MUST be in single quote.	
						end

					else

						board_index := (current_board_size * (ship.item.row - 1)) + (ship.item.col + (i - 0))
						--print("%NBoard index is " + board_index.out)
						tempArray.force (board_index, i)

						if debugMode then
							board.put ('h', board_index)	-- v MUST be in single quote.	
						end
					end

					i := i + 1

				end

				-- push gathered index. It'll be used as final track(mark) of ships
				generated_ships_index.extend ([ship.item.size, tempArray, ship.item.dir, false])


			end
		end

	convert_index_to_coord (index: INTEGER; board_size: INTEGER): TUPLE[row: INTEGER; col: INTEGER]
		local
			tempRow: DOUBLE
			tempCol: INTEGER
			tempResult: TUPLE[row: INTEGER; col: INTEGER]
		do
			create tempResult.default_create
			tempRow := (index.item / board_size)
			tempCol := (index.item \\ board_size)
			if tempCol ~ 0 then tempCol := board_size	end
			tempResult.row := tempRow.ceiling
			tempResult.col := tempCol
			Result := tempResult
		end
	convert_coord_to_index(row: INTEGER; col: INTEGER; board_size: INTEGER): INTEGER
	-- Warning: This is NOT 'random generated coord to index'
	-- 		it gives a slightly different coord.(row is shifted)
	-- This is used for fire, bomb and etc....
		do
			Result := ((row - 1) * board_size) + col
		end
	check_fire_caused_sink(ship_size: INTEGER): BOOLEAN
	-- Just check for specific size of ship and see if all X marks on it.
		local
			x_num: INTEGER
		do
			x_num := 0
			across generated_ships_index as ships
			loop
				if ships.item.size ~ ship_size then
					across ships.item.pos as index
					loop
						if board[index.item] ~ 'X' then
							x_num := x_num + 1
						end

					end
				end
			end

			Result := (x_num ~ ship_size) -- x mark number is matching with ship size?
		end


feature
	-- status display
	display_command_status(stateNum: INTEGER): STRING
		do
			create Result.make_empty
			Result.append ("  " + "state " + stateNum.out + " " + cmd_status_msg + " => " + game_msg + "%N")
		end

	-- board display.
	display_board_status: STRING
		local
			i,j,board_index: INTEGER
		do
			create Result.make_empty

			from i := 0 until i > current_board_size
			loop
				--print("%NBoard display process: i is " + i.out + " ----------")
				if i ~ 0 then		-- Very first col line (numbering on board)
					Result.append("  ")
					from j := 0 until j > current_board_size
					loop
						--print("%NBoard display process: j is " + j.out)
						if j ~ 0	 then
							Result.append(" ")
						else
							Result.append(j.out) -- display numbers
						end
						Result.append("  ") -- give space between col
						j := j + 1
					end
				else					-- rest of board
					Result.append("  ")
					from j := 0 until j > current_board_size
					loop
						--print("%NBoard display process: j is " + j.out)
						if j ~ 0	 then
							Result.append(row_chars[i].out) -- display alphabet
						else
							--calculate board index
							board_index := (current_board_size * (i - 1)) + j
							Result.append(board[board_index].out)
						end
						Result.append("  ")
						j := j + 1
					end
				end

				Result.append ("%N") -- next line
				i := i + 1

			end

		end

	-- Current game, number of shots, bombs, counted score and ships
	display_game_status: STRING
		local
			tempRow: DOUBLE
			tempCol: INTEGER
			i, posLimit: INTEGER
			tempTuple: TUPLE[row: INTEGER; col: INTEGER]
		do
			create Result.make_empty

			-- Current game
			Result.append ("  " + "Current Game")
			if debug_mode then Result.append (" (debug)") end
			Result.append (":" + current_game.out + "%N")

			-- Shots(fire), Bombs, Score, Ships
			Result.append ("  " + "Shots: " + current_fire.out + "/" + current_fire_limit.out + "%N")
			Result.append ("  " + "Bombs: " + current_bomb.out + "/" + current_bomb_limit.out + "%N")
			Result.append ("  " + "Score: " + current_score.out + "/" + current_score_limit.out)
			Result.append (" (" + total_score_current.out + "/" + total_score_limit.out + ")%N")
			Result.append ("  " + "Ships: " + current_ships.out + "/" + current_ships_limit.out + "%N")

			-- Display status of ships
			across
				generated_ships_index as ships
			loop

				Result.append("  " + "  " + ships.item.size.out + "x1: ")

				if debug_mode then
					-- For Debug mode, display each position(index)
					create tempTuple.default_create
					i := 1
					posLimit := ships.item.pos.count
					across ships.item.pos as index
					loop
						-- get row, col from index
						tempTuple := convert_index_to_coord(index.item, current_board_size)

						Result.append("[" + row_chars[tempTuple.row].out + ", " + tempTuple.col.out + "]->")
						Result.append(board[index.item].out) -- display whatever on board

						if i < posLimit then Result.append(";") end
						i := i + 1
					end

				else
					-- For new_game, display whether it's sunk or not.
					if ships.item.alldown then
						Result.append ("Sunk")
					else
						Result.append ("Not Sunk")
					end
				end

				Result.append ("%N")


			end

		end


	-- Display ALL
	display_game_board(stateNum: INTEGER): STRING
		do
			create Result.make_empty

			if current_difficulty >= 13 then

				Result.append (Current.display_command_status(stateNum))
				Result.append(Current.display_board_status) -- Board size is different from difficulties
				Result.append (Current.display_game_status)

			else -- at initial setting, difficulty is set to 0
				-- No command is entered (at the very beginning)
				cmd_status_msg := "OK"
				game_msg := "Start a new game"
				Result.append (Current.display_command_status(stateNum))

			end

		end

feature {NONE}
	-- game_started, game_ended
	-- it checks if game has a winner (player or computer)
	-- score and ships reached their limits, player wins. (game ended)
	-- fire and bombs reached limit but not score and ships, player loses. (game ended)
	game_ended: BOOLEAN
		do
			Result := player_wins OR player_loses OR (new_game_started ~ false)
		end
	player_wins: BOOLEAN
		do
			Result := (current_score >= current_score_limit AND current_ships >= current_ships_limit)
		end

	player_loses: BOOLEAN
		do
			Result := (player_wins ~ false) AND
					(current_fire >= current_fire_limit AND current_bomb >= current_bomb_limit)
		end

feature {NONE} -- all tests for myself.
	test_ships_generated	-- test random generation of ships
		do
			--just to display (testing)
			across
				generated_ships as ship
			loop
				print("%NShip Size: " + ship.item.size.out + ", Pos: [" + ship.item.row.out + ", " + ship.item.col.out + "], Dir: " + ship.item.dir.out)
			end
		end
	test_ships_index
		do
			-- Just to check board index gathered
			across generated_ships_index as ships
			loop
				print("%N---------------------")
				print("%NShip Size: " + ships.item.size.out)
				print("%NIndex Pos: ")
				across ships.item.pos as index
				loop print(index.item.out + " ") end
				print("%N Vertical? " + ships.item.dir.out)
				print(", All Down? " + ships.item.alldown.out)
			end
		end


feature {ETF_COMMAND} -- actual Commands are controlled here
	-- debug_test
	debug_test(level: INTEGER_64)
		do
			if not game_ended then
				-- Game not finished. Display message
				cmd_status_msg := "Game already started"
				game_msg := "Keep Firing!"
			else
				reset(true, level)
				-- If Debug mode, need to mark ship location
				convert_shipCoord_to_index(true)

				test_ships_index

			end
		end

	-- new_game
	-- check if game has ended
	new_game(level: INTEGER_64)
		do
			if not game_ended then
				-- Game not finished. Display message
				cmd_status_msg := "Game already started"
				game_msg := "Keep Firing!"
			else
				reset(false, level)
				convert_shipCoord_to_index(false)

				test_ships_index
			end

		end

	-- fire
	-- We have row and colums as integers. We can calculate where to mark on 'board'
	-- based on this. mode board limit * row + col
	fire(row: INTEGER_64; col: INTEGER_64)
		local
			fire_index: INTEGER
			match_found: BOOLEAN
			matched_ship_size: INTEGER
			caused_sink: BOOLEAN
		do

			fire_index := convert_coord_to_index(row.as_integer_32, col.as_integer_32, current_board_size)
			print("%NFire to pos: " + row.out + ", " + col.out + " => index: " + fire_index.out)

			-- Check for 'Already fired'
			if not (board[fire_index] ~ '_' or board[fire_index] ~ 'v' or board[fire_index] ~ 'h') then
				cmd_status_msg := "Already fired there"
				game_msg := "Keep Firing!"
			else

				cmd_status_msg := "OK"

				-- Check if that position is a matching position
				match_found := false
				across generated_ships_index as ships
				loop

					across ships.item.pos as index
					loop
						if index.item ~ fire_index then	-- if match is found,
							--print("%NFire Index match Found: " + index.item.out)
							match_found := true
							matched_ship_size := ships.item.size
						end
					end
				end

				-- Cases need to be consider:
				-- 	fire hit. But All ammos ran out and ship not sunk -> player loses
				--	fire not hit and All ammos ran out -> player loses
				if match_found then -- fire hits a ship.

					-- Mark on board (Important because it's used for checking sink or not and scoring)
					board.put ('X', fire_index.as_integer_32)

					-- check if it's sunk then decide what message to display
					caused_sink := check_fire_caused_sink(matched_ship_size)
					if caused_sink then

						game_msg := matched_ship_size.out + "x1 ship sunk!"

						-- Variable change for hit
						-- For size > 1 Ships, it must be sunk in order to get score
						current_score := current_score + matched_ship_size
						total_score_current := total_score_current + matched_ship_size
						current_ships := current_ships + 1

					else
						game_msg := "Hit!"
					end

				else				-- fire missed a ship
					board.put ('O', fire_index.as_integer_32)
					game_msg := "Miss!"
				end

				if player_wins then
					game_msg := game_msg + " You Win!"
					new_game_started := false
				elseif player_loses then
					game_msg := game_msg + " Game Over!"
					new_game_started := false
				else
					game_msg := game_msg + " Keep Firing!"
				end

				-- Variable change for Fire command in general
				current_fire := current_fire + 1

			end


		end


end
