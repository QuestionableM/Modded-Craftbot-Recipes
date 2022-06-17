dofile("$CONTENT_40639a2c-bb9f-4d4f-b88c-41bfe264ffa8/Scripts/ModDatabase.lua")

local function is_uuid_valid(uuid)
	local s_item = sm.item
	return s_item.isBlock(uuid) or s_item.isHarvestablePart(uuid) or s_item.isJoint(uuid) or s_item.isPart(uuid) or s_item.isTool(uuid)
end

local function is_recipe_file_valid(path, table)
	local success, json_data = pcall(sm.json.open, path)
	if success ~= true then
		return
	end

	local l_uuid_new = sm.uuid.new
	for k, mod_recipe in ipairs(json_data) do
		if mod_recipe.craftTime == nil then
			mod_recipe.craftTime = 27
		end

		local success, item_uuid = pcall(l_uuid_new, mod_recipe.itemId)
		if not (success == true and is_uuid_valid(item_uuid)) then
			sm.log.warning("Found an invalid recipe in: ", path, item_uuid)
			return
		end
	end

	print("Found a valid file:", path)
	table[#table + 1] = path
end

--this list contains the mods that already have crafting recipes, but they will most likely not be compatible with the custom game
local mod_exception_list =
{
	["df10d497-a28e-4413-a707-5a07813aec37"] = --wings mod
	{
		craftbot = "/Survival/CraftingRecipes/craftbot.json"
	}
}

cmi_valid_crafting_recipes =
{
	craftbot  = {},
	workbench = {},
	hideout   = {}
}

local cmi_recipe_cache_file = "$CONTENT_DATA/Scripts/CraftingRecipeCache.json"
function initialize_crafting_recipes()
	ModDatabase.loadDescriptions()

	--read the last timestamp or make it random if it doesn't exist
	local last_timestamp = math.random(0, 10000)
	local success, timestamp_json = pcall(sm.json.open, "$CONTENT_40639a2c-bb9f-4d4f-b88c-41bfe264ffa8/Scripts/data/last_update.json")
	if success then
		last_timestamp = timestamp_json.unix_timestamp
	end

	local has_file = sm.json.fileExists(cmi_recipe_cache_file)
	if has_file then
		local json_data = sm.json.open(cmi_recipe_cache_file)
		if json_data.time_stamp == last_timestamp then --means we can skip the whole search of new crafting recipe files

			local craftbot_valid_ref = cmi_valid_crafting_recipes.craftbot
			for k, v in ipairs(json_data.craftbot) do
				craftbot_valid_ref[#craftbot_valid_ref + 1] = v
			end

			local workbench_valid_ref = cmi_valid_crafting_recipes.workbench
			for k, v in ipairs(json_data.workbench) do
				workbench_valid_ref[#workbench_valid_ref + 1] = v
			end

			local hideout_valid_ref = cmi_valid_crafting_recipes.hideout
			for k, v in ipairs(json_data.hideout) do
				hideout_valid_ref[#hideout_valid_ref + 1] = v
			end

			return
		end
	end

	cmi_valid_crafting_recipes.craftbot[1]  = "$SURVIVAL_DATA/CraftingRecipes/craftbot.json"
	cmi_valid_crafting_recipes.workbench[1] = "$SURVIVAL_DATA/CraftingRecipes/workbench.json"
	cmi_valid_crafting_recipes.hideout[1]   = "$SURVIVAL_DATA/CraftingRecipes/hideout.json"
 
	for mod_uuid, v in pairs(ModDatabase.databases.descriptions) do
		local cur_exception = mod_exception_list[mod_uuid]
		local mod_key = "$CONTENT_"..mod_uuid

		if cur_exception == nil then
			local recipe_folder = mod_key.."/CraftingRecipes/"

			is_recipe_file_valid(recipe_folder.."craftbot.json", cmi_valid_crafting_recipes.craftbot)
			is_recipe_file_valid(recipe_folder.."workbench.json", cmi_valid_crafting_recipes.workbench)
			is_recipe_file_valid(recipe_folder.."hideout.json", cmi_valid_crafting_recipes.hideout)
		else
			if cur_exception.craftbot then
				is_recipe_file_valid(mod_key..cur_exception.craftbot, cmi_valid_crafting_recipes.craftbot)
			end

			if cur_exception.workbench then
				is_recipe_file_valid(mod_key..cur_exception.workbench, cmi_valid_crafting_recipes.workbench)
			end

			if cur_exception.hideout then
				is_recipe_file_valid(mod_key..cur_exception.hideout, cmi_valid_crafting_recipes.hideout)
			end
		end
	end

	local json_save_data =
	{
		time_stamp = last_timestamp,
		craftbot   = cmi_valid_crafting_recipes.craftbot,
		workbench  = cmi_valid_crafting_recipes.workbench,
		hideout    = cmi_valid_crafting_recipes.hideout
	}

	sm.json.save(json_save_data, cmi_recipe_cache_file)
end

initialize_crafting_recipes()