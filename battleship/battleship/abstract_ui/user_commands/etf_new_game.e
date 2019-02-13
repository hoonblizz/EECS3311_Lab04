note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_NEW_GAME
inherit
	ETF_NEW_GAME_INTERFACE
		redefine new_game end
create
	make
feature -- command
	new_game(level: INTEGER_64)
		require else
			new_game_precond(level)
    	do
			-- perform some update on the model state
			--print("%N[ETF_NEW_GAME] Cmd name: " + etf_cmd_name.out)
			--across etf_cmd_container.commands as cmd
			--loop
			--	print("%N[ETF_NEW_GAME] Cmd Array " + cmd.item.out)
				--cmd.item.etf_cmd_routine.apply
			--end

			print("%N[ETF_NEW_GAME] Level? " + level.out)
			model.battle.new_game (level)
			model.default_update
			etf_cmd_container.on_change.notify ([Current])

			print("%N[ETF_NEW_GAME] model: " + model.out)
    	end

end
