function LoadCraftingRecipes( recipePaths )
	-- Preload all crafting recipes
	g_craftingRecipeSets = {}
	g_unlockableCraftItems = {}
	g_crafterItems = {}

	local refinedTreasures = {
		"obj_resource_refinedcoralium",
		"obj_resource_refinednimbolium",
		"obj_resource_refinedlemonium",
		"obj_resource_refinedsapphire",
		"obj_resource_refinedcrystal"
	}
	local function createSchematicBanList()
		local plasmadrill = tostring( ITEMS.obj_interactive_plasmadrill_lvl1 )
		local quests =sm.json.open( "$SURVIVAL_DATA/ScriptableObjects/scriptableObjectSets/sob_quests.sobset" ) 
		local traderTradegroups = sm.json.open("$SURVIVAL_DATA/ScriptJsonFiles/Trader/trader.tradegroup")
		
		local hideoutTrader = sm.json.open( "$SURVIVAL_DATA/CraftingRecipes/hideout.json" )
		local minehubTrader = sm.json.open( "$SURVIVAL_DATA/CraftingRecipes/mininghubTrader.json" )
		
		local schematicBanlist = {}



		schematicBanlist[plasmadrill] = true

		if traderTradegroups and traderTradegroups.questGroups then
			local questGroups = traderTradegroups.questGroups
			for _, questGroup in ipairs(questGroups) do
				if questGroup.rewards then
					for _, reward in pairs(questGroup.rewards) do
						if reward.unlockCraftBot then
							schematicBanlist[tostring(reward.item)] = true
						end
					end
				end
			end
		end
		if quests and quests.scriptableObjectList then
			for _, quest in ipairs(quests.scriptableObjectList) do
			if quest.data.rewards then
				
				for _, reward in pairs(quest.data.rewards) do
					if reward.type == "schematic" then
						schematicBanlist[tostring(ITEMS[reward.name])] = true
					end
				end
			end
			end
		end
		if POI_TYPE_TO_GROWLAB_BALLOONCRATE_REWARD then 
			for _ , strUuid in pairs(POI_TYPE_TO_GROWLAB_BALLOONCRATE_REWARD) do
				schematicBanlist[strUuid] = true
			end
		end

		for _, itemId in ipairs(refinedTreasures) do
			if ITEMS[itemId] then
				schematicBanlist[tostring(ITEMS[itemId])] = true
			end
		end
		if hideoutTrader then
			for _, recipe in pairs(hideoutTrader) do
				if recipe.schematic then
					schematicBanlist[recipe.itemId] = true
				end
			end
		end
		if minehubTrader then
			for _, recipe in pairs(minehubTrader) do
				if recipe.schematic then
					schematicBanlist[recipe.itemId] = true
				end
			end
		end

		return schematicBanlist
	end

    local function load_crafting_recipe_file(path, recipes, recipesByIndex)
        local json = sm.json.open(path)

        local isRecipeValid = function( recipe )
			local recipeItemUuid = sm.uuid.new( recipe.itemId )
			if not sm.shape.uuidExists( recipeItemUuid ) and not sm.tool.uuidExists( recipeItemUuid ) then
                return false
			end

			recipe.craftTime = math.ceil( recipe.craftTime ) -- Seconds
			for _,ingredient in ipairs( recipe.ingredientList ) do
				ingredient.itemId = sm.uuid.new( ingredient.itemId ) -- Prepare uuid
				if not sm.shape.uuidExists( ingredient.itemId ) and not sm.tool.uuidExists( recipeItemUuid ) then
                    return false
				end
			end

			return true
		end

        for _, recipe in ipairs( json ) do
			if isRecipeValid( recipe ) then
				recipes[recipe.itemId] = recipe
				table.insert( recipesByIndex, recipe )
			end
		end
    end

	local schematicBanlist = createSchematicBanList()

	for name, path in pairs( recipePaths ) do
		local recipes = {}
		local recipesByIndex = {}

        if type(path) == "table" then
            for _, cur_path in ipairs(path) do
                load_crafting_recipe_file(cur_path, recipes, recipesByIndex)
            end
        else
            load_crafting_recipe_file(path, recipes, recipesByIndex)
        end

		-- NOTE: Wardrobe is using 'recipes' by uuid, crafter is using 'recipesByIndex'
		g_craftingRecipeSets[name] = { path = path, recipes = recipes, recipesByIndex = recipesByIndex }

		if string.match( name, "^craftbot_" ) then
			for itemId, _ in pairs( recipes ) do
				if not schematicBanlist[itemId] then
					g_unlockableCraftItems[itemId] = true
				end
				if not refinedTreasures[itemId] then
					g_crafterItems[itemId] = true
				end
			end
		end

		if string.match( name, "sawtable" ) then
			for itemId, _ in pairs( recipes ) do
				if not schematicBanlist[itemId] then
					g_unlockableCraftItems[itemId] = true
				end
				if not refinedTreasures[itemId] then
					g_crafterItems[itemId] = true
				end
			end
		end
	end
end