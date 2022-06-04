dofile("$CONTENT_40639a2c-bb9f-4d4f-b88c-41bfe264ffa8/Scripts/ModDatabase.lua")
ModDatabase.loadShapesets()

local sv_mod_uuid_table = ModDatabase.getAllLoadedMods()

local function load_recipes_and_store_in_table(path, out_table)
	if sm.json.fileExists(path) then
		local success, json_data = pcall(sm.json.open, path)
		if success == true then
			print("Loading modded crafting recipes:", path)

			for k, mod_recipe in ipairs(json_data) do
				out_table[#out_table + 1] = mod_recipe
			end
		end
	end
end

local function load_modded_crafting_recipes(out_table)
	for k, mod_uuid in ipairs(sv_mod_uuid_table) do
		local mod_key = "$CONTENT_"..mod_uuid
		local full_path = mod_key.."/CraftingRecipes/craftbot.json"
		
		load_recipes_and_store_in_table(full_path, out_table)
	end
end

cmi_merged_recipes_file_path = "$CONTENT_DATA/Scripts/MergedRecipes.json"
function merge_custom_crafting_recipes()
	local merged_recipe_table = {}

	load_recipes_and_store_in_table("$SURVIVAL_DATA/CraftingRecipes/craftbot.json", merged_recipe_table)
	load_modded_crafting_recipes(merged_recipe_table)

	sm.json.save(merged_recipe_table, cmi_merged_recipes_file_path)
end