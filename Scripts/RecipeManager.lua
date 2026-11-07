---@class RecipeManager : ScriptableObjectClass
---@field sv table
---@field cl table
dofile( "$SURVIVAL_DATA/Scripts/game/util/recipes.lua" )
RecipeManager = class( nil )

local CoreRecipes = {}
for _,recipe in ipairs( dofile( "$SURVIVAL_DATA/CraftingRecipes/craftbot/craftbot_core.json" ) ) do
	CoreRecipes[#CoreRecipes+1] = recipe.itemId
end

local DefaultUnlockedItems = {
	--dispenser
	ITEMS.obj_craftbot_craftbot1,
	ITEMS.obj_craftbot_refinery,
	ITEMS.obj_craftbot_resourcecontainer,
	ITEMS.obj_craftbot_cookbot,
	ITEMS.obj_craftbot_dressbot,

	--underground dispenser
	ITEMS.obj_interactive_prospector,
	ITEMS.obj_interactive_mineralcrusher,
	ITEMS.obj_interactive_gravelcollector,
	ITEMS.obj_interactive_sawtable1,

	--workbench
	ITEMS.obj_scrap_gasengine,
	ITEMS.obj_scrap_driverseat,
	ITEMS.obj_scrap_seat,
	ITEMS.obj_scrap_smallwheel,
	ITEMS.jnt_bearing,
	ITEMS.tool_connect,
	ITEMS.blk_cardboard,
	ITEMS.obj_interactive_switch,
	ITEMS.obj_craftbot_portablecraftbot,

	--craftbot
	ITEMS.tool_weld,
	ITEMS.tool_paint,
	ITEMS.obj_tool_bucket_empty,

	ITEMS.obj_interactive_radio,
	ITEMS.obj_interactive_button,
	ITEMS.obj_interactive_horn,
	
	ITEMS.obj_interactive_controller_01,

	ITEMS.obj_interactive_gasengine_01,
	ITEMS.jnt_suspensionoffroad_01,
	ITEMS.jnt_suspensionsport_01,

	ITEMS.obj_container_smallchest,
	ITEMS.obj_container_smallchest_pipe,
	
	ITEMS.obj_vehicle_smallwheel,
	ITEMS.obj_vehicle_bigwheel,

	ITEMS.obj_interactive_driverseat_01,
	ITEMS.obj_interactive_seat_01,

	ITEMS.obj_interactive_beacon,

	ITEMS.obj_pneumatic_pump,
	ITEMS.obj_pneumatic_pipe_03,
	ITEMS.obj_pneumatic_pipe_bend,
	ITEMS.obj_pneumatic_pipe_t,

	ITEMS.obj_light_headlight,
	ITEMS.obj_container_tinychest,
	
	ITEMS.obj_consumable_gas,
	ITEMS.obj_consumable_water,
	ITEMS.obj_consumable_chemical,
	ITEMS.obj_resource_crudeoil,
	ITEMS.obj_consumable_glue,
	ITEMS.obj_resource_ember,
	ITEMS.obj_consumable_soilbag,
	ITEMS.obj_consumable_tea,
	ITEMS.obj_consumable_inkammo,

	ITEMS.obj_interactive_textsign_small,
	ITEMS.obj_interactive_textsign_large,
	ITEMS.obj_interactive_textsign_extralarge,

	ITEMS.blk_wood1,
	ITEMS.blk_metal1,
	ITEMS.blk_crossnet,

	--added to first tier

	--added parts
	ITEMS.obj_small_long_pipe,
	ITEMS.obj_small_2way_pipe,
	ITEMS.obj_small_2wayb_pipe,
	ITEMS.obj_small_3way_pipe,
	ITEMS.obj_small_3wayb_pipe,
	ITEMS.obj_small_4way_pipe,
	ITEMS.obj_small_4wayb_pipe,
	ITEMS.obj_small_5way_pipe,
	ITEMS.obj_small_6way_pipe,

	--cookbot
	ITEMS.obj_consumable_carrotburger,
	ITEMS.obj_consumable_pizzaburger,
	ITEMS.obj_consumable_longsandwich,

	-- previously unlocked on craftbot upgrade
	ITEMS.blk_wood2,
	ITEMS.blk_metal2,
	ITEMS.blk_concrete1,
	ITEMS.blk_concrete2,
	ITEMS.blk_sand,
	ITEMS.blk_glass,

	ITEMS.wdg_scrapwood,
	ITEMS.wdg_wood1,
	ITEMS.wdg_wood2,
	ITEMS.wdg_scrapmetal,
	ITEMS.wdg_metal1,
	ITEMS.wdg_metal2,
	ITEMS.wdg_concrete1,
	ITEMS.wdg_concrete2,
	ITEMS.wdg_sand,
	ITEMS.wdg_scrapstone,
	ITEMS.wdg_glass,
	ITEMS.wdg_crossnet,
	ITEMS.wdg_cardboard,
	ITEMS.wdg_ice,
	ITEMS.wdg_dekotora,


	ITEMS.obj_industrial_windshieldlarge,
	ITEMS.obj_industrial_windshield
}

-- for unlocking recipes the first time you upgrade to a new level of crafter.
-- local CraftbotUpgradeRecipes = {
-- 	[tostring( ITEMS.obj_craftbot_craftbot2 )] = {
-- 	},
-- 	[tostring( ITEMS.obj_craftbot_craftbot3 )] = {
-- 	},
-- 	[tostring( ITEMS.obj_craftbot_craftbot4 )] = {
-- 	},
-- 	[tostring( ITEMS.obj_craftbot_craftbot5 )] = {
-- 	}
-- }

local DefaultListToMap = function( list )
	local result = {}
	for _, itemUuid in ipairs( list ) do
		result[tostring( itemUuid )] = true
	end
	return result
end
local DefaultUnlocked = DefaultListToMap( DefaultUnlockedItems )

-- Unlockable block UUIDs from craftbot_core.json (excluding default-unlocked) for the all-blocks-unlocked achievement
local UnlockableBlockUuids = {
	tostring( ITEMS.blk_wood3 ),
	tostring( ITEMS.blk_metal3 ),
	tostring( ITEMS.blk_concrete3 ),
	tostring( ITEMS.blk_plastic ),
	tostring( ITEMS.blk_glasstile ),
	tostring( ITEMS.blk_armoredglass ),
	tostring( ITEMS.blk_bubblewrap ),
	tostring( ITEMS.blk_restroom ),
	tostring( ITEMS.blk_tiles ),
	tostring( ITEMS.blk_bricks ),
	tostring( ITEMS.blk_lights ),
	tostring( ITEMS.blk_caution ),
	tostring( ITEMS.blk_crackedconcrete ),
	tostring( ITEMS.blk_concretetiles ),
	tostring( ITEMS.blk_metalbricks ),
	tostring( ITEMS.blk_beam ),
	tostring( ITEMS.blk_insulation ),
	tostring( ITEMS.blk_drywall ),
	tostring( ITEMS.blk_carpet ),
	tostring( ITEMS.blk_plasticwall ),
	tostring( ITEMS.blk_metalnet ),
	tostring( ITEMS.blk_tryponet ),
	tostring( ITEMS.blk_stripednet ),
	tostring( ITEMS.blk_squarenet ),
	tostring( ITEMS.blk_spaceshipmetal ),
	tostring( ITEMS.blk_spaceshipfloor ),
	tostring( ITEMS.blk_treadplate ),
	tostring( ITEMS.blk_warehousefloor ),
	tostring( ITEMS.blk_wornmetal ),
	tostring( ITEMS.blk_fancycarpet ),
}

function RecipeManager.server_onCreate( self )
	assert( g_recipeManager == nil )
	g_recipeManager = self
	self.sv = {}
	self.sv.saved = sm.storage.load( STORAGE_CHANNEL_RECIPEMANAGER ) or {}
	self.sv.saved.unlockedRecipes = self.sv.saved.unlockedRecipes or {}
	self.sv.saved.newUnlockedRecipes = self.sv.saved.newUnlockedRecipes or {} -- for each player keep track of new recipes the haven't seen in the craftbot
	self.sv.recipesToUnlock = {}
	self:sv_filterUnlocked()
	self:sv_clearNewUnlockedRecipesIfTooMany()
	self:sv_setClientData()
	self.sv.dirty = false
end

function RecipeManager.sv_setClientData( self )
	self.network:setClientData( { unlockedRecipes = self.sv.saved.unlockedRecipes,
		recipesToUnlock = self.sv.recipesToUnlock,
		newUnlockedRecipes = self.sv.saved.newUnlockedRecipes }, 1 )
end

function RecipeManager.sv_filterUnlocked( self )
	if g_unlockableCraftItems then
		for uuidStr,_ in pairs( g_unlockableCraftItems ) do
			local uid = sm.uuid.new( uuidStr )
			if not self.sv.saved.unlockedRecipes[uuidStr] and not isAnyOf( uid, DefaultUnlockedItems ) and not isAnyOf( uuidStr, CoreRecipes ) and sm.item.isPart( uid ) then
				self.sv.recipesToUnlock[#self.sv.recipesToUnlock+1] = uuidStr
			end
		end
	end
end

function RecipeManager.sv_clearNewUnlockedRecipesIfTooMany( self )
	-- Clear if too many recipes have not been seen by players, to avoid sync issue
	local recipeCount = 0
	for _, playerRecipes in pairs( self.sv.saved.newUnlockedRecipes ) do
		for _ in pairs( playerRecipes ) do
			recipeCount = recipeCount + 1
		end
	end
	if recipeCount > 500 then
		self.sv.saved.newUnlockedRecipes = {}
	end
end

function RecipeManager.client_onCreate( self )
	assert( g_recipeManagerClient == nil )
	g_recipeManagerClient = self
	self.cl = {}
	self.cl.unlockedRecipes = {}
	self.cl.recipesToUnlock = {}
end

function RecipeManager.client_onClientDataUpdate( self, data )
	self.cl.unlockedRecipes = data.unlockedRecipes
	self.cl.unlockedRecipesRevision = ( self.cl.unlockedRecipesRevision or 0 ) + 1
	self.cl.recipesToUnlock = data.recipesToUnlock

	self.cl.newUnlockedRecipes = data.newUnlockedRecipes[sm.localPlayer.getId()]

	if sm.game.getRecipesEnabled() then
		for _,uidString in pairs( self.cl.recipesToUnlock ) do
			sm.item.addTrackedItem( sm.uuid.new( uidString ), sm.item.trackingType.researchable )
		end
		
		for uidString,_ in pairs( self.cl.unlockedRecipes ) do
			sm.item.removeTrackedItem( sm.uuid.new( uidString ), sm.item.trackingType.researchable )
		end
	end
end

function RecipeManager.server_onFixedUpdate( self )
	if QuestManager.Sv_IsQuestComplete( "quest_warehouse_destruction" ) and not self:sv_isUnlocked( tostring( ITEMS.obj_interactive_plasmadrill_lvl1 ) ) then
		self:sv_unlockRecipe( tostring( ITEMS.obj_interactive_plasmadrill_lvl1 ) )
	end

	local seedTier = ProgressionManager.Sv_GetSeedTier()
	local growLabPoi = GROWLAB_POI_ORDER[seedTier - 1]
	if growLabPoi then
		local balloncrateReward = POI_TYPE_TO_GROWLAB_BALLOONCRATE_REWARD[growLabPoi]
		if balloncrateReward and not self:sv_isUnlocked( balloncrateReward ) then
			self:sv_unlockRecipe( balloncrateReward )
		end
	end

	if self.sv.dirty then
		sm.storage.save( STORAGE_CHANNEL_RECIPEMANAGER, self.sv.saved )
		self:sv_setClientData()
		self.sv.dirty = false
	end
end

function RecipeManager.Sv_UnlockRecipe( itemUuid, hideUnlock )
	g_recipeManager:sv_unlockRecipe( itemUuid, hideUnlock )
end

function RecipeManager.sv_unlockRecipe( self, itemUuid, hideUnlock )
	assert( type( itemUuid ) == "string" )
	if not self:sv_isUnlocked( itemUuid ) then
		self.sv.saved.unlockedRecipes[itemUuid] = true
		QuestManager.Sv_SendEvent( QuestEvent.RecipeUnlocked, { uuidString = itemUuid } )
		for i,uid in ipairs( self.sv.recipesToUnlock ) do
			if uid == itemUuid then
				table.remove( self.sv.recipesToUnlock, i )
				break
			end
		end
		self.sv.dirty = true
		if not hideUnlock then
			NotificationManager.Sv_SchematicUnlocked( sm.uuid.new( itemUuid ) )

			self:sv_clearNewUnlockedRecipesIfTooMany()
			-- Create entries for players as needed
			for _, player in pairs( sm.player.getAllPlayers() ) do
				if self.sv.saved.newUnlockedRecipes[player.id] == nil then
					self.sv.saved.newUnlockedRecipes[player.id] = {}
				end
			end
			for playerId, _ in pairs( self.sv.saved.newUnlockedRecipes ) do
				self.sv.saved.newUnlockedRecipes[playerId][itemUuid] = true
			end
		end

		-- Also unlock wedge from the sawtable if unlocking a block.
		if sm.item.isBlock( sm.uuid.new( itemUuid ) ) then
			local sawtableRecipes = g_craftingRecipeSets["sawtable"]
			if sawtableRecipes then
				local uuid = sm.uuid.new( itemUuid )
				for _, recipe in ipairs( sawtableRecipes.recipesByIndex ) do
					if recipe.ingredientList[1].itemId == uuid then
						self:sv_unlockRecipe( tostring( recipe.itemId ), true ) -- hide wedge unlock
					end
				end
			end

			local allBlocksUnlocked = true
			for _, blockUuid in ipairs( UnlockableBlockUuids ) do
				if not self:sv_isUnlocked( blockUuid ) then
					allBlocksUnlocked = false
					break
				end
			end
			if allBlocksUnlocked then
				sm.achievement.seti( "45252ec6-0918-4baa-8c3d-1870c4cac3be", 1 )
			end
		end


	else
		--print( "Tried to unlock known recipe:", itemUuid )
	end
end

-- function RecipeManager.Sv_UnlockCrafterUpgrades( crafterUuid )
-- 	g_recipeManager:sv_unlockCrafterUpgrades( crafterUuid )
-- end

-- function RecipeManager.sv_unlockCrafterUpgrades( self, crafterUuid )
-- 	for _, uid in ipairs( CraftbotUpgradeRecipes[crafterUuid] ) do
-- 		self:sv_unlockRecipe( uid, true )
-- 	end
-- end

function RecipeManager.Sv_IsUnlocked( itemId )
	if g_recipeManager then
		return g_recipeManager:sv_isUnlocked( itemId )
	else
		return nil
	end
end

local function IsCraftingRecipeCustom(itemId)
    for _, v in pairs(g_craftingRecipeSets) do
        if v.custom and v.recipes[itemId] ~= nil then
            return true
        end
    end

    return false
end

function RecipeManager.sv_isUnlocked( self, itemId )
	if not sm.game.getRecipesEnabled() then
		return true
	end
	assert( type( itemId ) == "string" )
	if DefaultUnlocked[itemId] then
		return true
	end

    if IsCraftingRecipeCustom(itemId) then
        return true
    end

    --if g_craftingRecipeSets[]
	return self.sv.saved.unlockedRecipes[itemId] == true
end

function RecipeManager.Sv_UnlockRandom()
	if g_recipeManager then
		g_recipeManager:sv_unlockRandom()
	end
end

function RecipeManager.sv_unlockRandom( self )
	if #self.sv.recipesToUnlock > 0 then
		local randomIndex = math.random( #self.sv.recipesToUnlock )
		self:sv_unlockRecipe( self.sv.recipesToUnlock[randomIndex] )
	end
end

function RecipeManager.Sv_UnlockAll()
	if g_recipeManager then
		g_recipeManager:sv_unlockAll()
	end
end

function RecipeManager.sv_unlockAll( self )
	for key, _ in pairs( g_unlockableCraftItems ) do
		self:sv_unlockRecipe( key, true )
	end
end

function RecipeManager.Cl_IsUnlocked( itemId )
	if g_recipeManagerClient then
		return g_recipeManagerClient:cl_isUnlocked( itemId )
	end
	return false
end

function RecipeManager.cl_isUnlocked( self, itemId )
	if not sm.game.getRecipesEnabled() then
		return true
	end
	assert( type( itemId ) == "string" )
	if DefaultUnlocked[itemId] then
		return true
	end

    if IsCraftingRecipeCustom(itemId) then
        return true
    end

	return self.cl.unlockedRecipes[itemId] == true
end

function RecipeManager.Cl_GetUnlockedRevision()
	if g_recipeManagerClient then
		return g_recipeManagerClient:cl_getUnlockedRevision()
	end
	return 0
end

function RecipeManager.cl_getUnlockedRevision( self )
	return self.cl.unlockedRecipesRevision or 0
end

function RecipeManager.Cl_GetUnlockedRecipes()
	if g_recipeManagerClient then
		return g_recipeManagerClient:cl_getUnlockedRecipes()
	end
	return {}
end

function RecipeManager.cl_getUnlockedRecipes( self )
	local result = shallowcopy( self.cl.unlockedRecipes )
	if not sm.game.getRecipesEnabled() then
		for _, setData in pairs( g_craftingRecipeSets ) do
			for uid,_ in pairs( setData.recipes ) do
				result[tostring( uid )] = true
			end
		end
		return result
	end
	for _, itemUuid in ipairs( DefaultUnlockedItems ) do
		result[tostring( itemUuid )] = true
	end
	return result
end

function RecipeManager.IsDisassemblableItem( itemId )
	if DefaultUnlocked[tostring( itemId )] or not sm.item.isPart( itemId ) or isAnyOf( tostring( itemId ), CoreRecipes ) then
		return false
	end
	return g_unlockableCraftItems[tostring( itemId )] == true
end

function RecipeManager.IsCraftableShape( itemId )
	local itemUuidString = tostring( itemId )
	return DefaultUnlocked[itemUuidString] == true or g_crafterItems[itemUuidString] == true or isAnyOf( itemUuidString, CoreRecipes )
end

function RecipeManager.Cl_CanUnlockRandom()
	if g_recipeManagerClient then
		return g_recipeManagerClient:cl_canUnlockRandom()
	end
	return false
end

function RecipeManager.cl_canUnlockRandom( self )
	if not sm.game.getRecipesEnabled() then
		return false
	end
	return not IsEmptyTable( self.cl.recipesToUnlock )
end

function RecipeManager.Cl_GetUnlockableAmount()
	if g_recipeManagerClient then
		return g_recipeManagerClient:cl_getUnlockableAmount()
	end
	return 0
end

function RecipeManager.cl_getUnlockableAmount( self )
	if not sm.game.getRecipesEnabled() then
		return 0
	end
	return #self.cl.recipesToUnlock
end

function RecipeManager.Cl_GetNewUnlockedRecipes()
	if g_recipeManagerClient then
		return g_recipeManagerClient:cl_getNewUnlockedRecipes()
	end
	return {}
end

function RecipeManager.cl_getNewUnlockedRecipes( self )
	if self.cl.newUnlockedRecipes == nil then
		 return {}
	end
	return self.cl.newUnlockedRecipes
end

function RecipeManager.Cl_SeenRecipe( itemId )
	if g_recipeManagerClient then
		sm.event.sendToScriptableObject( g_recipeManagerClient.scriptableObject, "cl_e_seenRecipe", itemId )
	end
end

function RecipeManager.cl_e_seenRecipe( self, itemId )
	self.network:sendToServer( "sv_n_seenRecipe", itemId )
end

function RecipeManager.sv_n_seenRecipe( self, itemId, player )
	local playerId = player.id
	if self.sv.saved.newUnlockedRecipes[playerId] then
		self.sv.saved.newUnlockedRecipes[playerId][itemId] = nil
		self.sv.dirty = true
	end
end