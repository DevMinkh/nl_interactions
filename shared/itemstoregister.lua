--[[ Add this items to your ox_inventory data/items.lua ]]--

	['wheelchair'] {
		label = 'Rollstuhl',
		weight = 6500,
		stack = false,
		close = true
	},
	
	['reakit'] {
		label = 'Defibrillator',
		weight = 775,
		stack = true, -- false if u want to reuse it (config.useRakit = false)
		close = true
	}