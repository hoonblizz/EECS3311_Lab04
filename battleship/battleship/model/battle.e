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

			current_game := 1
			current_fire := 0
			current_bomb := 0
			current_score := 0
			current_ships := 0
			current_fire_limit := easy_fire_limit
			current_bomb_limit := easy_bomb_limit
			current_score_limit := easy_score_limit
			current_ships_limit := easy_ships_limit
			row_chars := <<'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L'>>

			cmd_status_msg := "OK"
			game_msg := "Start a new game"

			create gen_ship.make_empty
			generated_ships := gen_ship.generate_ships (debug_mode, current_board_size, current_ships_limit)

		end

	-- Reset variables for new_game and debug_test
	reset(debugMode: BOOLEAN; level: INTEGER_64)
		do
			-- reset all variables
			new_game_started := true
			debug_mode := debugMode
			current_difficulty := level
			current_fire := 0
			current_bomb := 0
			current_score := 0
			current_ships := 0
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

			--just to display (testing)
			across
				generated_ships as ship
			loop
				print("%NShip Size: " + ship.item.size.out + ", Pos: [" + ship.item.row.out + ", " + ship.item.col.out + "], Dir: " + ship.item.dir.out)
			end




		end

feature {NONE} -- Attributes
	gen_ship: GEN_SHIP		-- use to generate ships in random
	generated_ships: ARRAYED_LIST[TUPLE[size: INTEGER; row: INTEGER; col: INTEGER; dir: BOOLEAN]]
	debug_mode: BOOLEAN
	current_difficulty: INTEGER_64	-- 13, 14, 15, 16 (easy, medium, hard, advanced)
	board: ARRAY[CHARACTER]

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

feature
	-- board display.
	display_board: STRING
		local
			i,j,board_index: INTEGER
		do
			create Result.make_empty
			print("%NEASY mode display")

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

	-- only for debug_test mode
	-- dir is true => Vertical
	display_ships_on_board
		local
			board_index: INTEGER
			i: INTEGER
		do
			across
				generated_ships as ship
			loop
				-- board position = board limit * row + col

				from i := 1 until i > ship.item.size
				loop
					print("%NDisplaying ship -> Size: " + ship.item.size.out + ", Pos: [" + ship.item.row.out + ", " + ship.item.col.out + "], Dir: " + ship.item.dir.out)

					if ship.item.dir then
						board_index := (current_board_size * (ship.item.row - 0)) + (ship.item.col + ((i - 1) * current_board_size))
						print("%NBoard index is " + board_index.out)
						board.put ('v', board_index)	-- v MUST be in single quote.
					else
						board_index := (current_board_size * (ship.item.row - 1)) + (ship.item.col + (i - 0))
						print("%NBoard index is " + board_index.out)
						board.put ('h', board_index)
					end

					i := i + 1

				end

			end
		end
	display_game_board(stateNum: INTEGER): STRING
		local
			--fire_limit, bomb_limit, score_limit, ships_limit: INTEGER
		do
			create Result.make_empty

			if current_difficulty >= 13 then

				Result.append ("  " + "state " + stateNum.out + " " + cmd_status_msg + " => " + game_msg + "%N")

				-- Board size is different from difficulties
				Result.append(Current.display_board)

				-- Rest of status display
				Result.append ("  " + "Current Game: " + current_game.out + "%N")
				Result.append ("  " + "Shots: " + current_fire.out + "/" + current_fire_limit.out + "%N")
				Result.append ("  " + "Bombs: " + current_bomb.out + "/" + current_bomb_limit.out + "%N")
				Result.append ("  " + "Score: " + current_score.out + "/" + current_score_limit.out + "%N")
				Result.append ("  " + "Ships: " + current_ships.out + "/" + current_ships_limit.out + "%N")

			else
				-- No command is entered (at the beginning)
				cmd_status_msg := "OK"
				game_msg := "Start a new game"
				Result.append ("  " + "state " + stateNum.out + " " + cmd_status_msg + " => " + game_msg + "%N")

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
				display_ships_on_board
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
			end

		end

	-- fire
	-- We have row and colums as integers. We can calculate where to mark on 'board'
	-- based on this. mode board limit * row + col
	fire(row: INTEGER_64; column: INTEGER_64)
		do

		end


end
