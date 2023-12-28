dofile("$SURVIVAL_DATA/Scripts/game/interactables/Crafter.lua")
dofile("$SURVIVAL_DATA/Scripts/game/interactables/HideoutTrader.lua")

local override_func = function( self )
	self.cl.guiInterface:clearGrid( "RecipeGrid" )
	for _, recipeSet in ipairs( self.crafter.recipeSets ) do
		local cur_recipe_files = g_craftingRecipes[recipeSet.name].path
		print( "CrafterI Adding", cur_recipe_files )

		if type(cur_recipe_files) == "table" then
			for k, recipe_path in pairs(cur_recipe_files) do
				self.cl.guiInterface:addGridItemsFromFile("RecipeGrid", recipe_path, { locked = recipeSet.locked })
			end
		else
			self.cl.guiInterface:addGridItemsFromFile("RecipeGrid", cur_recipe_files, { locked = recipeSet.locked })
		end
	end
end

Crafter.cl_updateRecipeGrid = override_func
Workbench.cl_updateRecipeGrid = override_func
Dispenser.cl_updateRecipeGrid = override_func
Craftbot.cl_updateRecipeGrid = override_func

local trader_override = function( self )
	self.cl.guiInterface:clearGrid( "TradeGrid" )

	print("HideoutI Add:", cmi_valid_crafting_recipes.hideout)

	for k, path in ipairs(cmi_valid_crafting_recipes.hideout) do
		self.cl.guiInterface:addGridItemsFromFile("TradeGrid", path)
	end
end

HideoutTrader.cl_updateTradeGrid = trader_override