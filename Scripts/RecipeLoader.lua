dofile("$CONTENT_40639a2c-bb9f-4d4f-b88c-41bfe264ffa8/Scripts/ModDatabase.lua")

if not cmi_hideout_trader_storage then
	cmi_hideout_trader_storage = {}
end

if not cmi_crafter_object_storage then
	cmi_crafter_object_storage = {}
end

local _sm_shape_uuidExists = sm.shape.uuidExists
local _sm_tool_uuidExists  = sm.tool.uuidExists
local function is_uuid_valid(uuid)
	return _sm_shape_uuidExists(uuid) or _sm_tool_uuidExists(uuid)
end

local _sm_json_open   = sm.json.open
local _sm_uuid_new    = sm.uuid.new
local _sm_log_warning = sm.log.warning
local function is_recipe_file_valid(path, table, uuid_check)
	local success, json_data = pcall(_sm_json_open, path)
	if success ~= true then
		return
	end

	if uuid_check == true then
		for k, mod_recipe in ipairs(json_data) do
			if mod_recipe.craftTime == nil then
				mod_recipe.craftTime = 27
			end

			local success, item_uuid = pcall(_sm_uuid_new, mod_recipe.itemId)
			if not (success == true and is_uuid_valid(item_uuid)) then
				_sm_log_warning("Found an invalid recipe in: ", path, item_uuid)
				return
			end
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

local function sort_valid_recipe_files(out_table_ref, input_table)
	for k, v in ipairs(input_table) do
		is_recipe_file_valid(v, out_table_ref, true)
	end
end

local function clean_valid_recipes()
	cmi_valid_crafting_recipes.craftbot  = {}
	cmi_valid_crafting_recipes.workbench = {}
	cmi_valid_crafting_recipes.hideout   = {}
end

local _sm_exists = sm.exists
local _sm_event_sendToInteractable = sm.event.sendToInteractable
local function cmi_update_crafters(crafter_array, callback)
	for k, inter in pairs(crafter_array) do
		if inter and _sm_exists(inter) then
			_sm_event_sendToInteractable(inter, callback)
		end
	end
end

function cmi_update_all_crafters()
	cmi_update_crafters(cmi_hideout_trader_storage, "cl_updateTradeGrid")
	cmi_update_crafters(cmi_crafter_object_storage, "cl_updateRecipeGrid")
end

local function cmi_sort_mods(tbl)
    local keyList = {}
    for k, v in pairs(tbl) do
        table.insert(keyList, k)
    end

    table.sort(keyList, function(a, b)
        return tbl[a] < tbl[b]
    end)

    return keyList
end

local function cmi_get_all_loaded_mods()
	-- Unload everything in case the function is called again
	ModDatabase.unloadDescriptions()
	ModDatabase.unloadShapesets()
	ModDatabase.unloadToolsets()

	ModDatabase.loadDescriptions()
	ModDatabase.loadShapesets()
	ModDatabase.loadToolsets()

	local v_loadedMods = {}
	local v_modDbDescs = ModDatabase.databases.descriptions

	for localId, _ in pairs(ModDatabase.databases.shapesets) do
		if ModDatabase.isModLoaded(localId) then
			v_loadedMods[localId] = v_modDbDescs[localId].fileId
		end
	end

	-- Add tool mods into the list of loaded mods
	for localId, _ in pairs(ModDatabase.databases.toolsets) do
		if v_loadedMods[localId] == nil and ModDatabase.isModLoaded(localId) then
			v_loadedMods[localId] = v_modDbDescs[localId].fileId
		end
	end

	-- Exclude custom games from the list
	for localId, _ in pairs(v_loadedMods) do
		if v_modDbDescs[localId].type == "Custom Game" then
			v_loadedMods[localId] = nil
		end
	end

	return v_loadedMods
end

function initialize_crafting_recipes()
	local v_craftbotRecipes  = { "$SURVIVAL_DATA/CraftingRecipes/craftbot.json" }
	local v_workbenchRecipes = { "$SURVIVAL_DATA/CraftingRecipes/workbench.json" }
	local v_hideoutRecipes   = { "$SURVIVAL_DATA/CraftingRecipes/hideout.json" }

	local _json_fileExists = sm.json.fileExists

	local v_loadedMods = cmi_sort_mods(cmi_get_all_loaded_mods())
	for _, localId in ipairs(v_loadedMods) do
		local v_modKey = "$CONTENT_"..localId

		local success, fileExists = pcall(_json_fileExists, v_modKey)
		if success == true and fileExists == true then
			local v_curException = mod_exception_list[localId]

			if v_curException == nil then
				local v_recipe_folder = v_modKey.."/CraftingRecipes/"

				is_recipe_file_valid(v_recipe_folder.."craftbot.json" , v_craftbotRecipes )
				is_recipe_file_valid(v_recipe_folder.."workbench.json", v_workbenchRecipes)
				is_recipe_file_valid(v_recipe_folder.."hideout.json"  , v_hideoutRecipes  )
			else
				local v_excCraftbot  = v_curException.craftbot
				local v_excWorkbench = v_curException.workbench
				local v_excHideout   = v_curException.hideout

				if v_excCraftbot then
					is_recipe_file_valid(v_modKey..v_excCraftbot, v_craftbotRecipes)
				end

				if v_excWorkbench then
					is_recipe_file_valid(v_modKey..v_excWorkbench, v_workbenchRecipes)
				end

				if v_excHideout then
					is_recipe_file_valid(v_modKey..v_excHideout, v_hideoutRecipes)
				end
			end
		end
	end

	--clean before setting new data
	clean_valid_recipes()

	--set new data
	sort_valid_recipe_files(cmi_valid_crafting_recipes.craftbot , v_craftbotRecipes )
	sort_valid_recipe_files(cmi_valid_crafting_recipes.workbench, v_workbenchRecipes)
	sort_valid_recipe_files(cmi_valid_crafting_recipes.hideout  , v_hideoutRecipes  )
end