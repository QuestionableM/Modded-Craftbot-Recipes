-- Crafter.lua --

dofile "$SURVIVAL_DATA/Scripts/game/survival_items.lua"
dofile "$SURVIVAL_DATA/Scripts/game/survival_survivalobjects.lua"
dofile ( "$SURVIVAL_DATA/Scripts/game/survival_collections.lua" )
dofile "$SURVIVAL_DATA/Scripts/game/util/pipes.lua"
dofile( "$SURVIVAL_DATA/Scripts/game/managers/RecipeManager.lua" )
dofile( "$SURVIVAL_DATA/Scripts/game/managers/TutorialManager.lua" )
dofile( "$SURVIVAL_DATA/Scripts/game/managers/DialogManager.lua" )
dofile( "$SURVIVAL_DATA/Scripts/game/managers/QuestManager.lua" )

Crafter = class( nil )
Crafter.colorNormal = sm.color.new( 0x84ff32ff )
Crafter.colorHighlight = sm.color.new( 0xa7ff4fff )

local MultiComponentKit = sm.uuid.new("b41de15e-a136-425a-a730-889b58cf4466")

local CraftbotRecipeSets = {
	{ name = "craftbot_core" },
	{ name = "craftbot_manmade" },
	{ name = "craftbot_small_pipes" },
	{ name = "craftbot_pipes" },
	{ name = "craftbot_generatorpipes" },
	{ name = "craftbot_building" },
	{ name = "craftbot_industrial" },
	{ name = "craftbot_beams" },
	{ name = "craftbot_plants" },
	{ name = "craftbot_decor" },
	{ name = "craftbot_other" },
	{ name = "craftbot_lights" },
	{ name = "craftbot_treasures" },
	{ name = "craftbot_rewards" },
	{ name = "craftbot_custom" }
}

function IsSawTable( shapeUuid )
	return shapeUuid == ITEMS.obj_interactive_sawtable1 or
		   shapeUuid == ITEMS.obj_interactive_sawtable2 or
		   shapeUuid == ITEMS.obj_interactive_sawtable3 or
		   shapeUuid == ITEMS.obj_interactive_sawtable4 or
		   shapeUuid == ITEMS.obj_interactive_sawtable5
end

function IsCraftBot( shapeUuid )
	return shapeUuid == ITEMS.obj_craftbot_craftbot1 or
		   shapeUuid == ITEMS.obj_craftbot_craftbot2 or
		   shapeUuid == ITEMS.obj_craftbot_craftbot3 or
		   shapeUuid == ITEMS.obj_craftbot_craftbot4 or
		   shapeUuid == ITEMS.obj_craftbot_craftbot5
end

function IsParallelCrafter( shapeUuid )
	return IsSawTable( shapeUuid ) or IsCraftBot( shapeUuid )
end

local crafters = {
	-- Workbench
	[tostring( ITEMS.obj_survivalobject_workbench )] = {
		needsPower = true,
		lookAtSettings = { lookAtRange = 3.5, headUpOffset = -0.2, headForwardOffset = -1.5, headLerpSpeed = 1.0 / 15.0 },
		slots = 1,
		speed = 1,
		recipeSets = {
			{ name = "workbench" }
		},
		subTitle = "",
		createGuiFunction = sm.gui.createWorkbenchGui
	},
	-- Portable Crafter
	[tostring( ITEMS.obj_craftbot_portablecraftbot )] = {
		needsPower = false,
		lookAtSettings = { lookAtRange = 5.0, headUpOffset = 0.3, headForwardOffset = -2.0, headLerpSpeed = 1.0 / 15.0 },
		inactiveDistance = 6.0,
		slots = 1,
		speed = 1,
		recipeSets = {
			{ name = "portablecrafter" }
		},
		subTitle = "",
		createGuiFunction = sm.gui.createPortableCrafterGui
	},
	-- Dispenser
	[tostring( ITEMS.obj_survivalobject_dispenserbot )] = {
		needsPower = true,
		lookAtSettings = { lookAtRange = 6.0, headUpOffset = 0.0, headForwardOffset = -2.0, headLerpSpeed = 1.0 / 20.0 },
		slots = 1,
		speed = 1,
		recipeSets = {
			{ name = "dispenser" }
		},
		subTitle = "",
		createGuiFunction = sm.gui.createMechanicStationGui,
		spawnRotation = sm.quat.rotZ90()
	},
	-- Mininghub Dispenser
	[tostring( ITEMS.obj_survivalobject_mininghub_dispenserbot )] = {
		needsActivation = true,
		lookAtSettings = { lookAtRange = 5.0, headUpOffset = 0.5, headForwardOffset = -2.0, headLerpSpeed = 1.0 / 20.0 },
		needsPower = false,
		slots = 1,
		speed = 1,
		recipeSets = {
			{ name = "mininghubDispenser" }
		},
		subTitle = "",
		createGuiFunction = sm.gui.createMininghubDispenserGui,
		spawnRotation = sm.quat.rotZ180()
	},
	-- Cookbot
	[tostring( ITEMS.obj_craftbot_cookbot )] = {
		needsPower = false,
		lookAtSettings = { lookAtRange = 5.0, headUpOffset = -0.3, headForwardOffset = -1.0, headLerpSpeed = 1.0 / 15.0 },
		slots = 1,
		speed = 1,
		recipeSets = {
			{ name = "cookbot" }
		},
		subTitle = ""
	},
	-- Craftbot 1
	[tostring( ITEMS.obj_craftbot_craftbot1 )] = {
		needsPower = false,
		lookAtSettings = { lookAtRange = 5.5, headUpOffset = 0.8, headForwardOffset = -2.0, headLerpSpeed = 1.0 / 15.0 },
		slots = 2,
		speed = 1,
		upgrade = tostring( ITEMS.obj_craftbot_craftbot2 ),
		upgradeCost = 5,
		recipeSets = CraftbotRecipeSets,
		subTitle = "#{LEVEL} 1",
		createGuiFunction = sm.gui.createCraftBotGui
	},
	-- Craftbot 2
	[tostring( ITEMS.obj_craftbot_craftbot2 )] = {
		needsPower = false,
		lookAtSettings = { lookAtRange = 5.5, headUpOffset = 0.8, headForwardOffset = -2.0, headLerpSpeed = 1.0 / 15.0 },
		slots = 4,
		speed = 1,
		upgrade = tostring( ITEMS.obj_craftbot_craftbot3 ),
		upgradeCost = 5,
		recipeSets = CraftbotRecipeSets,
		subTitle = "#{LEVEL} 2",
		createGuiFunction = sm.gui.createCraftBotGui
	},
	-- Craftbot 3
	[tostring( ITEMS.obj_craftbot_craftbot3 )] = {
		needsPower = false,
		lookAtSettings = { lookAtRange = 5.5, headUpOffset = 0.8, headForwardOffset = -2.0, headLerpSpeed = 1.0 / 15.0 },
		slots = 6,
		speed = 1,
		upgrade = tostring( ITEMS.obj_craftbot_craftbot4 ),
		upgradeCost = 5,
		recipeSets = CraftbotRecipeSets,
		subTitle = "#{LEVEL} 3",
		createGuiFunction = sm.gui.createCraftBotGui
	},
	-- Craftbot 4
	[tostring( ITEMS.obj_craftbot_craftbot4 )] = {
		needsPower = false,
		lookAtSettings = { lookAtRange = 5.5, headUpOffset = 0.8, headForwardOffset = -2.0, headLerpSpeed = 1.0 / 15.0 },
		slots = 8,
		speed = 1,
		upgrade = tostring( ITEMS.obj_craftbot_craftbot5 ),
		upgradeCostMultiComponent = false,
		upgradeCost = 20,
		recipeSets = CraftbotRecipeSets,
		subTitle = "#{LEVEL} 4",
		createGuiFunction = sm.gui.createCraftBotGui
	},
	-- Craftbot 5
	[tostring( ITEMS.obj_craftbot_craftbot5 )] = {
		needsPower = false,
		lookAtSettings = { lookAtRange = 5.5, headUpOffset = 0.8, headForwardOffset = -2.0, headLerpSpeed = 1.0 / 15.0 },
		slots = 8,
		speed = 2,
		recipeSets = CraftbotRecipeSets,
		subTitle = "#{LEVEL} 5",
		createGuiFunction = sm.gui.createCraftBotGui
	},
	-- Sawtable
	[tostring( ITEMS.obj_interactive_sawtable1 )] = {
		needsPower = false,
		slots = 2,
		speed = 1,
		upgrade = tostring( ITEMS.obj_interactive_sawtable2 ),
		upgradeCostMultiComponent = true,
		upgradeCost = 1,
		recipeSets = {
			{ name = "sawtable" }
		},
		subTitle = "#{LEVEL} 1",
		createGuiFunction = sm.gui.createSawbotGui
	},
	[tostring( ITEMS.obj_interactive_sawtable2 )] = {
		needsPower = false,
		slots = 4,
		speed = 1,
		upgrade = tostring( ITEMS.obj_interactive_sawtable3 ),
		upgradeCostMultiComponent = true,
		upgradeCost = 1,
		recipeSets = {
			{ name = "sawtable" }
		},
		subTitle = "#{LEVEL} 2",
		createGuiFunction = sm.gui.createSawbotGui
	},
	[tostring( ITEMS.obj_interactive_sawtable3 )] = {
		needsPower = false,
		slots = 6,
		speed = 1,
		upgrade = tostring( ITEMS.obj_interactive_sawtable4 ),
		upgradeCostMultiComponent = true,
		upgradeCost = 1,
		recipeSets = {
			{ name = "sawtable" }
		},
		subTitle = "#{LEVEL} 3",
		createGuiFunction = sm.gui.createSawbotGui
	},
	[tostring( ITEMS.obj_interactive_sawtable4 )] = {
		needsPower = false,
		slots = 8,
		speed = 1,
		upgrade = tostring( ITEMS.obj_interactive_sawtable5 ),
		upgradeCostMultiComponent = true,
		upgradeCost = 1,
		recipeSets = {
			{ name = "sawtable" }
		},
		subTitle = "#{LEVEL} 4",
		createGuiFunction = sm.gui.createSawbotGui
	},
	[tostring( ITEMS.obj_interactive_sawtable5 )] = {
		needsPower = false,
		slots = 8,
		speed = 2,
		recipeSets = {
			{ name = "sawtable" }
		},
		subTitle = "#{LEVEL} 5",
		createGuiFunction = sm.gui.createSawbotGui
	},

}

local function sv_awardBlockCraftAchievement( recipe, crafts )
	if crafts > 0 and sm.item.isBlock( sm.uuid.new( recipe.itemId ) ) then
		sm.achievement.addi( "e5d918b7-8a8b-459b-b988-9f483a54b527", recipe.quantity * crafts )
	end
end

function Crafter.cl_checkActivation( self)
	if self.crafter.needsActivation then
		if self.shape:getShapeUuid() == ITEMS.obj_survivalobject_mininghub_dispenserbot and not self.cl.mininghubLocked then
			return true
		end
	end
	return false
end

function Crafter.sv_checkActivation( self)
	if self.crafter.needsActivation then
		if self.shape:getShapeUuid() == ITEMS.obj_survivalobject_mininghub_dispenserbot and not self.sv.mininghubLocked then
			return true
		end
	end
	return false
end

local effectRenderables = {
	[tostring( ITEMS.obj_consumable_carrotburger )] = { char_cookbot_food_03, char_cookbot_food_04 },
	[tostring( ITEMS.obj_consumable_pizzaburger )] = { char_cookbot_food_01, char_cookbot_food_02 },
	[tostring( ITEMS.obj_consumable_longsandwich )] = { char_cookbot_food_02, char_cookbot_food_03 }
}

function Crafter.server_onCreate( self )
	self:sv_init()
end

function Crafter.server_onUnload( self )
	self.sv.saved.craftArray = self.sv.craftArray
	self.sv.saved.destructionTick = sm.game.getCurrentTick()
	self.storage:save( self.sv.saved )
end

function Crafter.server_onRefresh( self )
	self.crafter = nil
	self.network:setClientData( { craftArray = self.sv.craftArray, time = sm.game.getCurrentTick() }, 1 )
	self:sv_init()
end

function Crafter.server_canErase( self )
	return #self.sv.craftArray == 0
end

function Crafter.client_onCreate( self )
	self:cl_init()
end

function Crafter.client_onDestroy( self )
	if self.cl.pipeEffectPlayer then
		self.cl.pipeEffectPlayer:onDestroy()
	end
	if self.cl.guiInterface and self.cl.guiInterface:isActive() then
		self.cl.guiInterface:close()
	end
	
	for _,effect in pairs( self.cl.mainEffects ) do
		effect:destroy()
	end

	for _,effect in pairs( self.cl.secondaryEffects ) do
		effect:destroy()
	end

	for _,effect in pairs( self.cl.tertiaryEffects ) do
		effect:destroy()
	end

	for _,effect in pairs( self.cl.quaternaryEffects ) do
		effect:destroy()
	end

	-- Destroy sawtable-specific effects
	if self.cl.materialSawEffects then
		for key, value in pairs(self.cl.materialSawEffects) do
			value.loopEffect:stopImmediate()
			value.loopEffect:destroy()
			for _,effect in pairs(value.bursts) do
				effect:stopImmediate()
				effect:destroy()
			end
		end
		self.cl.sawLoopEffect:stopImmediate()
		self.cl.sawLoopEffect:destroy()
	end
end

function Crafter.client_onRefresh( self )
	self.crafter = nil
	self:cl_disableAllAnimations()
	self:cl_init()
end

function Crafter.client_canErase( self )
	if #self.cl.craftArray > 0 then
		NotificationManager.Cl_AddGenericNotification( "#{INFO_BUSY}", BUSY_NOTIFICATION_DURATION )
		return false
	end
	return true
end

-- Server Init

function Crafter.sv_init( self )
	self.crafter = crafters[tostring( self.shape:getShapeUuid() )]
	self.sv = {}
	self.sv.clientDataDirty = true
	self.sv.storageDataDirty = true
	self.sv.craftArray = {}
	if self.shape:getShapeUuid() == ITEMS.obj_survivalobject_mininghub_dispenserbot and g_tileStorageManager then
		self.sv.tileStorageKey = TileStorageManager.Sv_GetTileStorageKeyFromObject( self.interactable )
	end
	self.sv.saved = self.storage:load()
	if self.sv.saved then
		-- handle old save data from before parallel crafting was made
		for _, val in ipairs( self.sv.saved.craftArray ) do
			if val.count == nil or val.batched == nil then
				val.batched = false
				if val.loop then
					sm.pipeGraph.setAutomatedTask( self.shape, val.recipe, IsParallelCrafter( self.shape:getShapeUuid() ) )
				end
				val.count = 1
			end
		end
	end

	--if self.params then print( self.params ) end
	self.sv.mininghubLocked = true

	if self.sv.saved == nil then
		self.sv.saved = {}
		self.sv.saved.spawner = self.params and self.params.spawner or nil
		self:sv_updateStorage()
	else
		self.network:setClientData( nil, 2 )
	end
	if self.shape:getShapeUuid() == ITEMS.obj_survivalobject_mininghub_dispenserbot and g_tileStorageManager then
		if TileStorageManager.Sv_SyncedGetValueInSubTable( self.sv.tileStorageKey, TILESTORAGE_FLAGS_TABLE, "minehub:dispenser.activated" ) then
			self.sv.mininghubLocked = false
			self:sv_updateStorage()
		end
	end
	if self.sv.saved.craftArray then
		self.sv.craftArray = self.sv.saved.craftArray
	end
	self.network:setClientData( self.sv.mininghubLocked, 3 )
	if self.sv.saved.destructionTick then
		local missedTicks = sm.game.getCurrentTick() - self.sv.saved.destructionTick
		self.sv.saved.destructionTick = nil
		for _,craftData in ipairs( self.sv.craftArray ) do
			local recipe = craftData.recipe
			local bulkCraftTime = math.ceil( recipe.craftTime / self.crafter.speed ) * 40 * craftData.count
			local ticksLeft = bulkCraftTime - craftData.time - 1
			self.sv.clientDataDirty = true
			if ticksLeft > 0 then
				craftData.time = craftData.time + math.min( missedTicks, ticksLeft )
			end
		end
	end
end

function Crafter.sv_markClientDataDirty( self )
	self.sv.clientDataDirty = true
end

function Crafter.sv_sendClientData( self )
	if self.sv.clientDataDirty then
		self.network:setClientData( { craftArray = self.sv.craftArray }, 1 )
		self.sv.clientDataDirty = false
	end
end

function Crafter.sv_markStorageDirty( self )
	self.sv.storageDataDirty = true
end

function Crafter.sv_updateStorage( self )
	if self.sv.storageDataDirty then
		self.sv.saved.craftArray = self.sv.craftArray
		self.storage:save( self.sv.saved )
		self.sv.storageDataDirty = false
	end
end

-- Client Init

function Crafter.cl_init( self )
	local shapeUuid = self.shape:getShapeUuid()
	if self.crafter == nil then
		self.crafter = crafters[tostring( shapeUuid )]
	end
	self.cl = {}
	self.cl.craftArray = {}
	self.cl.uvFrame = 0
	self.cl.animState = nil
	self.cl.animName = nil
	self.cl.animDuration = 1
	self.cl.animTime = 0

	self.cl.upDownControl = 0.5
	self.cl.leftRightControl = 0.5
	if self.crafter.lookAtSettings then
		if self.interactable:hasAnim( "aimbend_updown" ) then
			self.interactable:setAnimEnabled( "aimbend_updown", true )
		end
		if self.interactable:hasAnim( "aimbend_leftright" ) then
			self.interactable:setAnimEnabled( "aimbend_leftright", true )
		end
	end

	self.cl.currentMainEffect = nil
	self.cl.currentSecondaryEffect = nil
	self.cl.currentTertiaryEffect = nil
	self.cl.currentQuaternaryEffect = nil

	self.cl.mainEffects = {}
	self.cl.secondaryEffects = {}
	self.cl.tertiaryEffects = {}
	self.cl.quaternaryEffects = {}

	-- print( self.crafter.subTitle )
	-- print( "craft_start", self.interactable:getAnimDuration( "craft_start" ) )
	-- if self.interactable:hasAnim( "craft_loop" ) then
	-- 	print( "craft_loop", self.interactable:getAnimDuration( "craft_loop" ) )
	-- else
	-- 	print( "craft_loop01", self.interactable:getAnimDuration( "craft_loop01" ) )
	-- 	print( "craft_loop02", self.interactable:getAnimDuration( "craft_loop02" ) )
	-- 	print( "craft_loop03", self.interactable:getAnimDuration( "craft_loop03" ) )
	-- end
	-- print( "craft_finish", self.interactable:getAnimDuration( "craft_finish" ) )

	if IsCraftBot( shapeUuid ) then
		self.cl.mainEffects["unfold"] = sm.effect.createEffect( "Craftbot - Unpack", self.interactable )
		self.cl.mainEffects["idle"] = sm.effect.createEffect( "Craftbot - Idle", self.interactable )
		self.cl.mainEffects["idlespecial01"] = sm.effect.createEffect( "Craftbot - IdleSpecial01", self.interactable )
		self.cl.mainEffects["idlespecial02"] = sm.effect.createEffect( "Craftbot - IdleSpecial02", self.interactable )
		self.cl.mainEffects["craft_start"] = sm.effect.createEffect( "Craftbot - Start", self.interactable )
		self.cl.mainEffects["craft_loop01"] = sm.effect.createEffect( "Craftbot - Work01", self.interactable )
		self.cl.mainEffects["craft_loop02"] = sm.effect.createEffect( "Craftbot - Work02", self.interactable )
		self.cl.mainEffects["craft_loop03"] = sm.effect.createEffect( "Craftbot - Work03", self.interactable )
		self.cl.mainEffects["craft_finish"] = sm.effect.createEffect( "Craftbot - Finish", self.interactable )

		self.cl.secondaryEffects["craft_loop01"] = sm.effect.createEffect( "Craftbot - Work", self.interactable )
		self.cl.secondaryEffects["craft_loop02"] = self.cl.secondaryEffects["craft_loop01"]
		self.cl.secondaryEffects["craft_loop03"] = self.cl.secondaryEffects["craft_loop01"]

		self.cl.tertiaryEffects["craft_loop02"] = sm.effect.createEffect( "Craftbot - Work02Torch", self.interactable, "l_arm03_jnt" )

	elseif shapeUuid == ITEMS.obj_craftbot_cookbot then

		self.cl.mainEffects["unfold"] = sm.effect.createEffect( "Cookbot - Unpack", self.interactable )
		self.cl.mainEffects["idlespecial01"] = sm.effect.createEffect( "Cookbot - IdleSpecial01", self.interactable )
		self.cl.mainEffects["idlespecial02"] = sm.effect.createEffect( "Cookbot - IdleSpecial02", self.interactable )
		self.cl.mainEffects["craft_start"] = sm.effect.createEffect( "Cookbot - Start", self.interactable )
		self.cl.mainEffects["craft_loop01"] = sm.effect.createEffect( "Cookbot - Work01", self.interactable )
		self.cl.mainEffects["craft_loop02"] = sm.effect.createEffect( "Cookbot - Work02", self.interactable )
		self.cl.mainEffects["craft_loop03"] = sm.effect.createEffect( "Cookbot - Work03", self.interactable )
		self.cl.mainEffects["craft_finish"] = sm.effect.createEffect( "Cookbot - Finish", self.interactable )

		self.cl.secondaryEffects["craft_loop01"] = sm.effect.createEffect( "Cookbot - Work", self.interactable )
		self.cl.secondaryEffects["craft_loop02"] = self.cl.secondaryEffects["craft_loop01"]
		self.cl.secondaryEffects["craft_loop03"] = sm.effect.createEffect( "Cookbot - Work03Salt", self.interactable, "shaker_jnt" )

		self.cl.tertiaryEffects["craft_start"] = sm.effect.createEffect( "ShapeRenderable", self.interactable, "food01_jnt" )
		self.cl.tertiaryEffects["craft_loop01"] = sm.effect.createEffect( "ShapeRenderable", self.interactable, "food01_jnt" )
		self.cl.tertiaryEffects["craft_loop02"] = sm.effect.createEffect( "ShapeRenderable", self.interactable, "food01_jnt" )
		self.cl.tertiaryEffects["craft_loop03"] = sm.effect.createEffect( "ShapeRenderable", self.interactable, "food01_jnt" )
		self.cl.tertiaryEffects["craft_finish"] = sm.effect.createEffect( "ShapeRenderable", self.interactable, "food01_jnt" )

		self.cl.quaternaryEffects["craft_start"] = sm.effect.createEffect( "ShapeRenderable", self.interactable, "food02_jnt" )
		self.cl.quaternaryEffects["craft_loop01"] = sm.effect.createEffect( "ShapeRenderable", self.interactable, "food02_jnt" )
		self.cl.quaternaryEffects["craft_loop02"] = sm.effect.createEffect( "ShapeRenderable", self.interactable, "food02_jnt" )
		self.cl.quaternaryEffects["craft_loop03"] = sm.effect.createEffect( "ShapeRenderable", self.interactable, "food02_jnt" )
		self.cl.quaternaryEffects["craft_finish"] = sm.effect.createEffect( "ShapeRenderable", self.interactable, "food02_jnt" )


	elseif shapeUuid == ITEMS.obj_survivalobject_workbench  then
		
		self.cl.mainEffects["craft_finish"] = sm.effect.createEffect( "Workbench - Finish", self.interactable )
		self.cl.mainEffects["idle"] = sm.effect.createEffect( "Workbench - Idle", self.interactable )
		self.cl.usesBreakSustain = true
		self.cl.stopFinishEffect = true

	elseif shapeUuid == ITEMS.obj_craftbot_portablecraftbot then

		self.cl.mainEffects["unfold"] = sm.effect.createEffect( "Babycraftbot - Unpack", self.interactable )
		self.cl.mainEffects["idle"] = sm.effect.createEffect( "Babycraftbot - Idle", self.interactable )
		self.cl.mainEffects["idlespecial01"] = sm.effect.createEffect( "Babycraftbot - Idle_special01", self.interactable )
		self.cl.mainEffects["idlespecial02"] = sm.effect.createEffect( "Babycraftbot - Idle_special02", self.interactable )
		
		self.cl.mainEffects["craft_start"] = sm.effect.createEffect( "Babycraftbot - Start", self.interactable )
		self.cl.mainEffects["craft_loop01"] = sm.effect.createEffect( "Babycraftbot - Craft_loop", self.interactable, "root_jnt" )
		self.cl.mainEffects["craft_loop02"] = sm.effect.createEffect( "Babycraftbot - craft_loop_special01", self.interactable, "root_jnt" )
		self.cl.mainEffects["craft_loop03"] = sm.effect.createEffect( "Babycraftbot - craft_loop_special02", self.interactable, "root_jnt" )
		self.cl.mainEffects["craft_finish"] = sm.effect.createEffect( "Babycraftbot - Craft_finish", self.interactable, "root_jnt" )

		self.cl.secondaryEffects["craft_loop02"] = sm.effect.createEffect( "Babycraftbot - Craft_loop_special02_smoketrail", self.interactable, "root_jnt" )
		self.cl.secondaryEffects["craft_finish"] = sm.effect.createEffect( "Babycraftbot - Craftingdone", self.interactable, "root_jnt" )

		self.cl.mainEffects["fold_idle"] = sm.effect.createEffect( "Babycraftbot - Fold_idle", self.interactable )
		self.cl.mainEffects["fold_idlespecial01"] = sm.effect.createEffect( "Babycraftbot - Fold_idle_special01", self.interactable )

	elseif shapeUuid == ITEMS.obj_survivalobject_dispenserbot or shapeUuid == ITEMS.obj_survivalobject_mininghub_dispenserbot then

		self.cl.mainEffects["craft_loop"] = sm.effect.createEffect( "Dispenserbot - Work01", self.interactable )
		self.cl.mainEffects["idle"] = sm.effect.createEffect( "Workbench - Idle", self.interactable )
		self.cl.usesBreakSustain = true
	elseif IsSawTable( shapeUuid ) then
		self.cl.mainEffects["unfold"] = sm.effect.createEffect( "Sawtable - UnfoldSound", self.interactable )
		self.cl.secondaryEffects["unfold"] = sm.effect.createEffect( "Sawtable - Start", self.interactable, "root_jnt" )

		self.cl.mainEffects["idle"] = sm.effect.createEffect( "Sawtable - IdleSound", self.interactable )
		self.cl.mainEffects["idlespecial01"] = sm.effect.createEffect( "Sawtable - IdleSpecialSound1", self.interactable )
		self.cl.mainEffects["idlespecial02"] = sm.effect.createEffect( "Sawtable - IdleSpecialSound2", self.interactable )
		self.cl.mainEffects["craft_start"] = sm.effect.createEffect( "Sawtable - StartSound", self.interactable )
		self.cl.mainEffects["craft_loop01"] = sm.effect.createEffect( "Sawtable - LoopSound1", self.interactable )
		self.cl.mainEffects["craft_loop02"] = sm.effect.createEffect( "Sawtable - LoopSound2", self.interactable )
		self.cl.mainEffects["craft_loop03"] = sm.effect.createEffect( "Sawtable - LoopSound3", self.interactable )

		self.cl.sawLoopEffect = sm.effect.createEffect( "Sawtable - Sawloop", self.interactable, "largeguard_jnt" )

		self.cl.materialSawEffects = {
			["Wood"] = {
				bursts = {
					sm.effect.createEffect( "Sawtable - Wood burst01", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Wood burst02", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Wood burst03", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Wood burst04", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - allmaterial burst05", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Finish", self.interactable, "root_jnt" )
				},
				loopEffect = sm.effect.createEffect( "Sawtable - Wood Loop", self.interactable, "root_jnt" ),
			},
			["Rock"] = {
				bursts = {
					sm.effect.createEffect( "Sawtable - Stone burst01", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Stone burst02", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Stone burst03", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Stone burst04", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - allmaterial burst05", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Finish", self.interactable, "root_jnt" )
				},
				loopEffect = sm.effect.createEffect( "Sawtable - Stone Loop", self.interactable, "root_jnt" ),
			},
			["Metal"] = {
				bursts = {
					sm.effect.createEffect( "Sawtable - Metal burst01", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Metal burst02", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Metal burst03", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Metal burst04", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Metal burst05", self.interactable, "root_jnt" ),
					--sm.effect.createEffect( "Sawtable - Finish", self.interactable, "root_jnt" ) -- this should be blue sparks
				},
				loopEffect = sm.effect.createEffect( "Sawtable - Metal Loop", self.interactable, "root_jnt" ),
			},
			["Sand"] = {
				bursts = {
					sm.effect.createEffect( "Sawtable - Sand burst01", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Sand burst02", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Sand burst03", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Sand burst04", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - allmaterial burst05", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Finish", self.interactable, "root_jnt" )
				},
				loopEffect = sm.effect.createEffect( "Sawtable - Sand Loop", self.interactable, "root_jnt" ),
			},
			["Plastic"] = {
				bursts = {
					sm.effect.createEffect( "Sawtable - Plastic burst01", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Plastic burst02", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Plastic burst03", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Plastic burst04", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - allmaterial burst05", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Finish", self.interactable, "root_jnt" )
				},
				loopEffect = sm.effect.createEffect( "Sawtable - Plastic Loop", self.interactable, "root_jnt" ),
			},
			["Bubblewrap"] = {
				bursts = {
					sm.effect.createEffect( "Sawtable - Bubblewrap burst01", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Bubblewrap burst02", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Bubblewrap burst03", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Bubblewrap burst04", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - allmaterial burst05", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Finish", self.interactable, "root_jnt" )
				},
				loopEffect = sm.effect.createEffect( "Sawtable - Bubblewrap Loop", self.interactable, "root_jnt" ),
			},
			["Ice"] = {
				bursts = {
					sm.effect.createEffect( "Sawtable - Ice burst01", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Ice burst02", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Ice burst03", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Ice burst04", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - allmaterial burst05", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Finish", self.interactable, "root_jnt" )
				},
				loopEffect = sm.effect.createEffect( "Sawtable - Ice Loop", self.interactable, "root_jnt" ),
			},
			["Glass"] = {
				bursts = {
					sm.effect.createEffect( "Sawtable - Glass burst01", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Glass burst02", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Glass burst03", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Glass burst04", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - allmaterial burst05", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Finish", self.interactable, "root_jnt" )
				},
				loopEffect = sm.effect.createEffect( "Sawtable - Glass Loop", self.interactable, "root_jnt" ),
			},
			["Scrapmetal"] = {
				bursts = {
					sm.effect.createEffect( "Sawtable - Scrapmetal burst01", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Scrapmetal burst02", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Scrapmetal burst03", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Scrapmetal burst04", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - allmaterial burst05", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Finish", self.interactable, "root_jnt" )
				},
				loopEffect = sm.effect.createEffect( "Sawtable - Scrapmetal Loop", self.interactable, "root_jnt" ),
			},
			["Carpet"] = {
				bursts = {
					sm.effect.createEffect( "Sawtable - Carpet burst01", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Carpet burst02", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Carpet burst03", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Carpet burst04", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - allmaterial burst05", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Finish", self.interactable, "root_jnt" )
				},
				loopEffect = sm.effect.createEffect( "Sawtable - Carpet Loop", self.interactable, "root_jnt" ),
			},
			["Default"] = {
				bursts = {
					sm.effect.createEffect( "Sawtable - Default burst01", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Default burst02", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Default burst03", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Default burst04", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - allmaterial burst05", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Finish", self.interactable, "root_jnt" )
				},
				loopEffect = sm.effect.createEffect( "Sawtable - Default Loop", self.interactable, "root_jnt" ),
			},
			["Cardboard"] = {
				bursts = {
					sm.effect.createEffect( "Sawtable - Cardboard burst01", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Cardboard burst02", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Cardboard burst03", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Cardboard burst04", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - allmaterial burst05", self.interactable, "root_jnt" ),
					sm.effect.createEffect( "Sawtable - Finish", self.interactable, "root_jnt" )
				},
				loopEffect = sm.effect.createEffect( "Sawtable - Cardboard Loop", self.interactable, "root_jnt" ),
			}
		}

		-- Animation time marks for burst effects
		self.cl.animationTimeMarks = {}
		self.cl.animationTimeMarks["craft_loop01"] = { { timeStamp = 0.4, index = 1 } }
		self.cl.animationTimeMarks["craft_loop02"] = { { timeStamp = 0.2, index = 5 }, { timeStamp = 1.35, index = 5 }, { timeStamp = 2.65, index = 5 }, { timeStamp = 3.35, index = 4 }, { timeStamp = 4.1, index = 3 }, { timeStamp = 5.45, index = 3 }, { timeStamp = 6.55, index = 3 }, { timeStamp = 7.35, index = 4 } }
		self.cl.animationTimeMarks["craft_loop03"] = { { timeStamp = 0.05, index = 4 }, { timeStamp = 0.6, index = 3 }, { timeStamp = 1.15, index = 4 }, { timeStamp = 1.8, index = 3 }, { timeStamp = 2.35, index = 4 }, { timeStamp = 3.0, index = 3 }, }
		self.cl.animationTimeMarks["craft_finish"] = { { timeStamp = 0.0, index = 6 } }
		
		self.cl.lastBurstTimeStamp = -1.0
		self.cl.currentMaterial = nil

		self.cl.currentBurstList = self.cl.materialSawEffects["Default"].bursts
	end	
	
	if g_recipeManagerClient then
		self:cl_setupUI()
	end

	self.cl.pipeEffectPlayer = PipeEffectPlayer()
	self.cl.pipeEffectPlayer:onCreate()
end

function Crafter.cl_setupUI( self )
	self.cl.guiInterface = self.crafter.createGuiFunction()
	self.cl.guiInterface:setButtonCallback( "Upgrade", "cl_onUpgrade" )
	self.cl.guiInterface:setGridButtonCallback( "Craft", "cl_onCraft" )
	self.cl.guiInterface:setGridButtonCallback( "Repeat", "cl_onRepeat" )
	self.cl.guiInterface:setGridButtonCallback( "Collect", "cl_onCollect" )

	self.cl.guiInterface:setGridItemClickedCallback( "RecipeGrid", "cl_onRecipeGridItemClickedNew" )

	self:cl_updateRecipeGrid()
	self.cl.setupUIComplete = true
end

function Crafter.cl_updateRecipeGrid( self )
	self.cl.guiInterface:clearGrid( "RecipeGrid" )
	local unlockedRecipes = RecipeManager.Cl_GetUnlockedRecipes()

	if g_craftingRecipeSets then
		for _, recipeSet in ipairs( self.crafter.recipeSets ) do
			local cur_recipe_files = g_craftingRecipeSets[recipeSet.name].path

			if type(cur_recipe_files) == "table" then
				for _, recipe_path in pairs(cur_recipe_files) do
					self.cl.guiInterface:addGridItemsFromFile( "RecipeGrid", recipe_path, { speed = self.crafter.speed or 1 } )
				end
			else
				self.cl.guiInterface:addGridItemsFromFile( "RecipeGrid", cur_recipe_files, { unlockedRecipes = unlockedRecipes, speed = self.crafter.speed or 1, newRecipes = RecipeManager.Cl_GetNewUnlockedRecipes() } )
			end
		end
	end

	self.cl.unlockedRecipesRevision = RecipeManager.Cl_GetUnlockedRevision()
end

function Crafter.client_onClientDataUpdate( self, data, channel )
	if channel == 1 then
		self.cl.craftArray = data.craftArray
		-- Experimental needs testing
		for _, val in ipairs( self.cl.craftArray ) do
			if val.time == -1 and val.startTick and val.count > 0 then
				local estimate = max( sm.game.getServerTick() - val.startTick, 0 ) -- Estimate how long time has passed since server started crafing and client recieved craft
				val.time = estimate
			end
		end
	elseif channel == 2 then
		self.cl.skipUnfold = true
	elseif channel == 3 then
		self.cl.mininghubLocked = data
	end
end

-- Internal util

function Crafter.getParent( self )
	if self.crafter.needsPower then
		return self.interactable:getSingleParent()
	end
	return nil
end

function Crafter.getRecipeByUuid( self, stringUuid )
	local recipe = nil
	for _, recipeSet in ipairs( self.crafter.recipeSets ) do
		if g_craftingRecipeSets[recipeSet.name].recipes[stringUuid] ~= nil then
			recipe = g_craftingRecipeSets[recipeSet.name].recipes[stringUuid]
			break
		end
	end
	return recipe
end

function Crafter.getRecipeByIndex( self, index )

	-- Convert one dimensional index to recipeSet and recipeIndex
	local recipeName = 0
	local recipeIndex = 0
	local offset = 0
	for _, recipeSet in ipairs( self.crafter.recipeSets ) do
		assert( g_craftingRecipeSets[recipeSet.name].recipesByIndex )
		local recipeCount = #g_craftingRecipeSets[recipeSet.name].recipesByIndex

		if index <= offset + recipeCount then
			recipeIndex = index - offset
			recipeName = recipeSet.name
			break
		end
		offset = offset + recipeCount
	end
 
	local recipe = g_craftingRecipeSets[recipeName].recipesByIndex[recipeIndex]
	if recipe then
		return recipe
	end

	return nil
end

-- Server

function Crafter.server_onFixedUpdate( self )
	if self.shape:getShapeUuid() == ITEMS.obj_survivalobject_mininghub_dispenserbot and self.sv.mininghubLocked and g_tileStorageManager then
		if TileStorageManager.Sv_SyncedGetValueInSubTable( self.sv.tileStorageKey, TILESTORAGE_FLAGS_TABLE, "minehub:dispenser.activated" ) then
			self.sv.mininghubLocked = false
			self:sv_updateStorage()
			self.network:setClientData( self.sv.mininghubLocked, 3 )
		end
	end

	local parent = self:getParent()
	if not ( self.crafter.needsPower or self.crafter.needsActivation )
		or ( self.crafter.needsPower and ( parent == nil or parent.active ) )
		or ( self.crafter.needsActivation and self:sv_checkActivation() ) then
		
		local inputContainers = {}
		for idx, val in ipairs( self.sv.craftArray ) do
			if val.loop then
				inputContainers = sm.pipeGraph.getInputContainers( self.shape )
				break
			end
		end
		local hasOutputContainers = #sm.pipeGraph.getOutputContainers( self.shape ) > 0
		local hasInputContainers = #inputContainers > 0

		for idx, val in ipairs( self.sv.craftArray ) do
			if val then
				local recipe = val.recipe
				if val.loop and ( not hasOutputContainers or not hasInputContainers ) then
					val.loop = false
					sm.pipeGraph.removeAutomatedTask( self.shape, sm.uuid.new( val.recipe.itemId ) )
					if val.count < 1 then
						-- Cancel a repeating craft that is only waiting for input materials.
						table.remove( self.sv.craftArray, idx )
					end
					self:sv_markStorageDirty()
					self:sv_markClientDataDirty()
				end
				
				-- if there is no container to collect to this craft is batched.
				local containerObj = self:sv_getContainerShapeForRecipe( recipe )
				local batched = containerObj == nil
				if val.batched ~= batched then
					val.batched = batched
					self:sv_markClientDataDirty()
				end
				
				local craftTime = math.ceil( recipe.craftTime / self.crafter.speed ) * 40
				-- if it is batched the time will be longer
				if val.batched and val.count > 0 then
					craftTime = craftTime * val.count
				end

				-- try consume resources if looping
				if val.loop and val.count < 1 then
					sm.container.beginTransaction()
					local containerArray = {}
					local transactionAborted = false

					for _, ingredient in ipairs( recipe.ingredientList ) do
						local consumeCount = ingredient.quantity
						for _, container in ipairs( inputContainers ) do
							if consumeCount > 0 then
								local target = nil
								if type( container ) == "Shape" then
									target = GetPipeGraphObjectContainer( container )
									table.insert( containerArray, { targetContainer = container, itemId = ingredient.itemId } )
								else
									target = container
								end
								consumeCount = consumeCount - sm.container.spend( target, ingredient.itemId, consumeCount, false )
							else
								break
							end
						end

						if consumeCount > 0 then
							sm.container.abortTransaction()
							transactionAborted = true
							break
						end
					end

					if not transactionAborted then
						if sm.container.endTransaction() then
							val.count = 1
							if #containerArray > 0 then
								self.network:sendToClients( "cl_n_onCraftFromChest", containerArray )
							end
						end
					end
				end
				
				if val.count > 0 then
					if val.time == -1 then
						val.startTick = sm.game.getServerTick()
						self:sv_markClientDataDirty()
					end
					
					if val.time < craftTime then
						val.time = val.time + 1
						if val.time >= craftTime then
							--reached finished, save and sync
							self:sv_markStorageDirty()
							self:sv_markClientDataDirty()
						end
					end
				end

				local hasSpawner = self.sv.saved and self.sv.saved.spawner
				if self.shape:getShapeUuid() == ITEMS.obj_survivalobject_mininghub_dispenserbot and (not hasSpawner) and g_tileStorageManager then
					local spawner = TileStorageManager.Sv_GetValueInSubTable( self.sv.tileStorageKey, NON_PLAYER_CRAFTER_TABLE, "spawner" )
					if spawner ~= nil then
						self.sv.saved.spawner = spawner
						hasSpawner = true
					end
				end


				if hasSpawner then
					if val.time + 10 == craftTime then
						self.sv.saved.spawner.active = true
					end
				end

				if val.time >= craftTime then
					-- craft is finished
					if hasSpawner then
						if not self:sv_spawn() then
							return
						end
					end

					if containerObj and not val.batched then
						sm.container.beginTransaction()
						sm.container.collect( containerObj:getInteractable():getContainer(), sm.uuid.new( recipe.itemId ), recipe.quantity )
						if recipe.extras then
							for _,extra in ipairs( recipe.extras ) do
								sm.container.collect( containerObj:getInteractable():getContainer(), sm.uuid.new( extra.itemId ), extra.quantity )
							end
						end
						if sm.container.endTransaction() then
							-- if available space in destination, reduce the craft stack size and start again.
							sv_awardBlockCraftAchievement( recipe, val.count )
							val.count = val.count - 1
							val.time = val.time - craftTime
							if val.count <= 0 then
								if val.loop and #inputContainers > 0 and val.count < 1 then
									val.time = -1
								else
									table.remove( self.sv.craftArray, idx )
								end
							end
							self:sv_markStorageDirty()
							self:sv_markClientDataDirty()
							self.network:sendToClients( "cl_n_onCollectToChest", { targetContainer = containerObj, itemId = sm.uuid.new( recipe.itemId ) } )
						else
							print( "Container full" )
						end
					end
				end

				--craft from all slots
				if not IsParallelCrafter( self.shape:getShapeUuid() ) then
					break
				end
			end
		end
	end

	self:sv_sendClientData()
	self:sv_updateStorage()
end

--Client

local UV_OFFLINE = 0
local UV_READY = 1
local UV_FULL = 2
local UV_HEART = 3
local UV_WORKING_START = 4
local UV_WORKING_COUNT = 4
local UV_JAMMED_START = 8
local UV_JAMMED_COUNT = 4

function Crafter.client_onFixedUpdate( self )
	if not self.cl.setupUIComplete then
		if g_recipeManagerClient then
			self:cl_setupUI()
		end
	end

	for idx, val in ipairs( self.cl.craftArray ) do
		if val then
			local recipe = val.recipe
			local recipeCraftTime = math.ceil( recipe.craftTime / self.crafter.speed ) * 40
			if val.batched and val.count > 0 then
				recipeCraftTime = recipeCraftTime * val.count
			end

			if val.time < recipeCraftTime and val.count > 0 then
				val.time = val.time + 1

				if not IsParallelCrafter( self.shape:getShapeUuid() ) then
					break
				end
			end
		end
	end
end



function Crafter.cl_checkSawBursts( self )
    if IsSawTable( self.shape:getShapeUuid() ) then
        local currentAnim = self.cl.currentAnimation or self.cl.animName
        if self.cl.animationTimeMarks[currentAnim] ~= nil then
            for _,collection in ipairs( self.cl.animationTimeMarks[currentAnim] ) do
                if collection ~= nil then
                    if self.cl.animTime >= collection.timeStamp and collection.timeStamp > self.cl.lastBurstTimeStamp then
                        self.cl.lastBurstTimeStamp = self.cl.animTime
                        if self.cl.currentBurstList and self.cl.currentBurstList[collection.index] then
                            self.cl.currentBurstList[collection.index]:start()
                        end
                        break
                    end
                end
            end
        end
    end
end

function Crafter.cl_stopSawLoopEffects( self )
    if IsSawTable( self.shape:getShapeUuid() ) then
		if self.cl.sawLoopEffect and not self.cl.sawLoopEffect:isBreakSustaining() then
			self.cl.sawLoopEffect:stopBreakSustain()
		end
		for key, value in pairs( self.cl.materialSawEffects ) do
			value.loopEffect:stop()
		end
        self.cl.currentMaterial = nil
    end
end

function Crafter.client_onUpdate( self, deltaTime )
	local selfShapeUuid = self.shape:getShapeUuid()
	if ( IsCraftBot( selfShapeUuid ) or IsSawTable( selfShapeUuid ) ) and self.cl.unlockedRecipesRevision ~= RecipeManager.Cl_GetUnlockedRevision() then
		self:cl_updateRecipeGrid()
	end
    
    -- Handle sawtable-specific updates
    if IsSawTable( selfShapeUuid ) then
        if self.cl.animName and not (self.cl.animName == "craft_loop01" or self.cl.animName == "craft_loop02" or self.cl.animName == "craft_loop03" or self.cl.animName == "craft_start" ) then
            self:cl_stopSawLoopEffects()
        end

        if self.cl.animName and (self.cl.animName == "craft_loop01" or self.cl.animName == "craft_loop02" or self.cl.animName == "craft_loop03" or self.cl.animName == "craft_finish" ) then
            -- Get the current recipe being crafted
            if #self.cl.craftArray > 0 then
                local craftData = self.cl.craftArray[1]
				-- select craftdata of ongoing craft with least remaining time
				local minRemainingTime = math.huge
				for _, data in ipairs(self.cl.craftArray) do
					if data and data.recipe then
						local remaining = ( data.recipe.craftTime * 40 ) - data.time
						if remaining > 0 and remaining < minRemainingTime then
							minRemainingTime = remaining
							craftData = data
						end
					end
				end

                if craftData and craftData.recipe and self.cl.animName ~= "craft_finish" then
                    local inputItemUuid = sm.uuid.new(craftData.recipe.ingredientList[1].itemId)
                    local material = sm.item.getMaterial(inputItemUuid)
					if self.cl.materialSawEffects[material] == nil then
						material = "Default"
					end

                    if material ~= self.cl.currentMaterial then
						for key, value in pairs( self.cl.materialSawEffects ) do
							if value.loopEffect:isPlaying() then
								value.loopEffect:stop()
							end
						end

						if self.cl.sawLoopEffect and not self.cl.sawLoopEffect:isPlaying() then
							self.cl.sawLoopEffect:start()
						end

						self.cl.materialSawEffects[material].loopEffect:start()
                        self.cl.currentBurstList = self.cl.materialSawEffects[material].bursts
                        self.cl.currentMaterial = material
                    end
                    
                    -- Check for burst effects based on animation progress
                    self.cl.currentAnimation = self.cl.animName
                    self:cl_checkSawBursts()
                end
            end
        end
    end

	local prevAnimState = self.cl.animState

	local craftTimeRemaining = 0

	local parent = self:getParent()
	if not ( self.crafter.needsPower or self.crafter.needsActivation )
		or ( self.crafter.needsPower and ( parent == nil or parent.active ) )
		or ( self.crafter.needsActivation and self:cl_checkActivation() )  then
		local guiActive = false
		if self.cl.guiInterface then
			guiActive = self.cl.guiInterface:isActive()
		end
		
		local hasItems = false
		local isCrafting = false
		local reactToInactive = false

		if guiActive then
			self:cl_drawProcess()
		end

		for idx = 1, self.crafter.slots do
			local val = self.cl.craftArray[idx]
			if val then
				hasItems = true
				local recipe = val.recipe
				local recipeCraftTime = math.ceil( recipe.craftTime / self.crafter.speed ) * 40
				if val.batched and val.count > 0 then
					recipeCraftTime = recipeCraftTime * val.count
				end
				if val.time >= 0 and val.time < recipeCraftTime and val.count > 0 then
					isCrafting = true
					local remaining = ( recipeCraftTime - val.time ) / 40
					if remaining > craftTimeRemaining then
						craftTimeRemaining = remaining
					end
				end
			end
		end

		if self.crafter.inactiveDistance then
			-- Check if no player is nearby
			local playersInRange = GetPlayersInRange(self.shape.worldPosition, self.crafter.inactiveDistance, self.shape.body:getWorld() )
			reactToInactive = #playersInRange == 0
		end

		if isCrafting then
			self.cl.animState = "craft"
			self.cl.uvFrame = self.cl.uvFrame + deltaTime * 8
			self.cl.uvFrame = self.cl.uvFrame % UV_WORKING_COUNT
			self.interactable:setUvFrameIndex( math.floor( self.cl.uvFrame ) + UV_WORKING_START )
		elseif hasItems then
			self.cl.animState = "idle"
			self.interactable:setUvFrameIndex( UV_FULL )
		elseif reactToInactive then
			self.cl.animState = "inactive"
			self.interactable:setUvFrameIndex( UV_READY )
		else
			self.cl.animState = "idle"
			self.interactable:setUvFrameIndex( UV_READY )
		end
	else
		self.cl.animState = "offline"
		self.interactable:setUvFrameIndex( UV_OFFLINE )
	end

	self.cl.animTime = self.cl.animTime + deltaTime
	local animDone = false
	if self.cl.animTime > self.cl.animDuration then
		self.cl.animTime = math.fmod( self.cl.animTime, self.cl.animDuration )
		--print( "ANIMATION DONE:", self.cl.animName )
		animDone = true
	end

	local craftbotParameter = 1

	if self.cl.animState ~= prevAnimState then
		--print( "NEW ANIMATION STATE:", self.cl.animState )
	end

	local prevAnimName = self.cl.animName

	if self.cl.animState == "offline" then
		assert( self.crafter.needsPower or self.crafter.needsActivation )
		self.cl.animName = "offline"

	elseif self.cl.animState == "inactive" then
		if not isAnyOf( self.cl.animName, { "fold_in", "fold_idle", "fold_out", "fold_idlespecial01" } ) then
			self.cl.animName = "fold_in"
		else
			if animDone then
				local rand = math.random( 1, 4 )
				if rand == 1 then
					self.cl.animName = "fold_idlespecial01"
				else
					self.cl.animName = "fold_idle"
				end
			end
		end
	elseif self.cl.animState == "idle" then
		if self.cl.animName == "offline" or self.cl.animName == nil then
			if self.crafter.needsPower or self.crafter.needsActivation then
				self.cl.animName = "turnon"
			elseif self.cl.skipUnfold then
				self.cl.animName = "idle"
			else
				self.cl.animName = "unfold"
			end
			animDone = true
		elseif isAnyOf( self.cl.animName, { "fold_in", "fold_idle", "fold_idlespecial01" } ) then
			self.cl.animName = "fold_out"
			animDone = true
		elseif self.cl.animName == "turnon" or self.cl.animName == "unfold" or self.cl.animName == "craft_finish" then
			if animDone then
				self.cl.animName = "idle"
			end
		elseif self.cl.animName == "idle" then
			if animDone then
				local rand = math.random( 1, 5 )
				if rand == 1 then
					self.cl.animName = "idlespecial01"
				elseif rand == 2 then
					self.cl.animName = "idlespecial02"
				else
					self.cl.animName = "idle"
				end
			end
		elseif self.cl.animName == "idlespecial01" or self.cl.animName == "idlespecial02" then
			if animDone then
				self.cl.animName = "idle"
			end
		else
			--assert( self.cl.animName == "craft_finish" )
			if animDone then
				self.cl.animName = "idle"
			end
		end

	elseif self.cl.animState == "craft" then
		if isAnyOf( self.cl.animName, { "idle", "idlespecial01", "idlespecial02", "turnon", "unfold", "fold_in", "fold_idle", "fold_idlespecial01" } ) or self.cl.animName == nil then
			self.cl.animName = "craft_start"
			animDone = true
			
			if IsSawTable( selfShapeUuid ) and self.cl.sawLoopEffect and not self.cl.sawLoopEffect:isPlaying() then
				self.cl.sawLoopEffect:start()
			end
		elseif self.cl.animName == "craft_start" then
			if animDone then
				if self.interactable:hasAnim( "craft_loop" ) then
					self.cl.animName = "craft_loop"
				else
					self.cl.animName = "craft_loop01"
				end
			end
		elseif self.cl.animName == "craft_loop" then
			if animDone then
				if craftTimeRemaining <= 2 then
					self.cl.animName = "craft_finish"
				else
					--keep looping
				end
			end
		elseif self.cl.animName == "craft_loop01" or self.cl.animName == "craft_loop02" or self.cl.animName == "craft_loop03" then
			if animDone then
				if craftTimeRemaining <= 2 then
					self.cl.animName = "craft_finish"

					if IsSawTable( selfShapeUuid ) and self.cl.mainEffects["craft_finish"] then
						self.cl.mainEffects["craft_finish"]:start()
						self:cl_stopSawLoopEffects()
					end
				else
					local rand = math.random( 1, 4 )
					if rand == 1 and craftTimeRemaining >= self.interactable:getAnimDuration( "craft_loop02" ) then
						self.cl.animName = "craft_loop02"
						craftbotParameter = 2
					elseif rand == 2 and craftTimeRemaining >= self.interactable:getAnimDuration( "craft_loop03" ) then
						self.cl.animName = "craft_loop03"
						craftbotParameter = 3
					else
						self.cl.animName = "craft_loop01"
						craftbotParameter = 1
					end
					if IsSawTable( selfShapeUuid ) then
						self.cl.lastBurstTimeStamp = -1.0
					end
				end
			end
		elseif self.cl.animName == "craft_finish" then
			if animDone then
				self.cl.animName = "craft_start"
				if IsSawTable( selfShapeUuid ) then
					self:cl_stopSawLoopEffects()
				end
			end
		end
	end

	if self.cl.animName ~= prevAnimName then
		--print( "NEW ANIMATION:", self.cl.animName )

		if prevAnimName then
			self.interactable:setAnimEnabled( prevAnimName, false )
			self.interactable:setAnimProgress( prevAnimName, 0 )
		end

		self.cl.animDuration = self.interactable:getAnimDuration( self.cl.animName )
		self.cl.animTime = 0

		--print( "DURATION:", self.cl.animDuration )

		self.interactable:setAnimEnabled( self.cl.animName, true )
	end

	if animDone then

		local mainEffect = self.cl.mainEffects[self.cl.animName]
		local secondaryEffect = self.cl.secondaryEffects[self.cl.animName]
		local tertiaryEffect = self.cl.tertiaryEffects[self.cl.animName]
		local quaternaryEffect = self.cl.quaternaryEffects[self.cl.animName]

		if mainEffect ~= self.cl.currentMainEffect then

			if self.cl.currentMainEffect then
				if self.cl.usesBreakSustain and not ( self.cl.currentMainEffect == self.cl.mainEffects["craft_finish"] and self.cl.stopFinishEffect ) then
					self.cl.currentMainEffect:stopBreakSustain()
				else
					self.cl.currentMainEffect:stop()
				end
			end
			self.cl.currentMainEffect = mainEffect
		end

		if secondaryEffect ~= self.cl.currentSecondaryEffect then

			if self.cl.currentSecondaryEffect then
				self.cl.currentSecondaryEffect:stop()
			end

			self.cl.currentSecondaryEffect = secondaryEffect
		end

		if tertiaryEffect ~= self.cl.currentTertiaryEffect then

			if self.cl.currentTertiaryEffect then
				self.cl.currentTertiaryEffect:stop()
			end

			self.cl.currentTertiaryEffect = tertiaryEffect
		end

		if quaternaryEffect ~= self.cl.currentQuaternaryEffect then

			if self.cl.currentQuaternaryEffect then
				self.cl.currentQuaternaryEffect:stop()
			end

			self.cl.currentQuaternaryEffect = quaternaryEffect
		end

		if self.cl.currentMainEffect then
			self.cl.currentMainEffect:setParameter( "craftbot", craftbotParameter )

			if not self.cl.currentMainEffect:isPlaying() or self.cl.currentMainEffect:isBreakSustaining() then
				self.cl.currentMainEffect:start()
	
			else
				self.cl.currentMainEffect:stop()
				self.cl.currentMainEffect:start()
			end
		end

		if self.cl.currentSecondaryEffect then
			self.cl.currentSecondaryEffect:setParameter( "craftbot", craftbotParameter )

			if not self.cl.currentSecondaryEffect:isPlaying() then
				self.cl.currentSecondaryEffect:start()
			end
		end

		if self.cl.currentTertiaryEffect then
			self.cl.currentTertiaryEffect:setParameter( "craftbot", craftbotParameter )

			if self.shape:getShapeUuid() == ITEMS.obj_craftbot_cookbot then
				local val = self.cl.craftArray and self.cl.craftArray[1] or nil
				if val then
					local cookbotRenderables = effectRenderables[val.recipe.itemId]
					if cookbotRenderables and cookbotRenderables[1] then
						self.cl.currentTertiaryEffect:setParameter( "uuid", cookbotRenderables[1] )
						self.cl.currentTertiaryEffect:setScale( sm.vec3.new( 0.25, 0.25, 0.25 ) )
					end
				end
			end

			if not self.cl.currentTertiaryEffect:isPlaying() then
				self.cl.currentTertiaryEffect:start()
			end
		end

		if self.cl.currentQuaternaryEffect then
			self.cl.currentQuaternaryEffect:setParameter( "craftbot", craftbotParameter )

			if self.shape:getShapeUuid() == ITEMS.obj_craftbot_cookbot then
				local val = self.cl.craftArray and self.cl.craftArray[1] or nil
				if val then
					local cookbotRenderables = effectRenderables[val.recipe.itemId]
					if cookbotRenderables and cookbotRenderables[2] then
						self.cl.currentQuaternaryEffect:setParameter( "uuid", cookbotRenderables[2] )
						self.cl.currentQuaternaryEffect:setScale( sm.vec3.new( 0.25, 0.25, 0.25 ) )
					end
				end
			end

			if not self.cl.currentQuaternaryEffect:isPlaying() then
				self.cl.currentQuaternaryEffect:start()
			end
		end
	end
	assert(self.cl.animName)
	self.interactable:setAnimProgress( self.cl.animName, self.cl.animTime / self.cl.animDuration )

	-- Pipe visualization

	if self.cl.pipeEffectPlayer then
		self.cl.pipeEffectPlayer:update( deltaTime )
	end

	-- Look at animations
	if self.crafter.lookAtSettings then
		local stationUp = self.shape:getAt()
		local stationRight = -self.shape:getRight()
		local stationForward = self.shape:getUp()
		local upDownControl = 0.5
		local leftRightControl = 0.5
		if self.cl.animName == "idle" then
			local closestPlayer = GetClosestPlayer( self.shape.worldPosition, self.crafter.lookAtSettings.lookAtRange, self.shape.body:getWorld() )
			if closestPlayer then
				local lookAtPosition = closestPlayer.character.worldPosition
				local toPlayerDir = ( lookAtPosition - self.shape.worldPosition ):safeNormalize( stationForward )
				if stationForward:dot( toPlayerDir ) > 0 then
					local lookFromPosition = self.shape.worldPosition + self.shape:getAt() * self.crafter.lookAtSettings.headUpOffset + self.shape:getUp() * self.crafter.lookAtSettings.headForwardOffset
					local lookDirection = ( lookAtPosition - lookFromPosition ):safeNormalize( stationForward )

					-- Project look direction onto the stations's up-forward plane and right-forward plane
					local upProjection = lookDirection:dot( stationUp )
					local rightProjection = lookDirection:dot( stationRight )

					-- Map the projections to the control values assuming the valid range is non-negative
					upDownControl = clamp( 1.0 - ( ( upProjection + 1 ) / 2 ), 0, 1 )
					leftRightControl = clamp( ( rightProjection + 1 ) / 2, 0, 1 )
				end
			end
		end
		self.cl.upDownControl = magicInterpolation( self.cl.upDownControl, upDownControl, deltaTime, self.crafter.lookAtSettings.headLerpSpeed )
		self.cl.leftRightControl = magicInterpolation( self.cl.leftRightControl, leftRightControl, deltaTime, self.crafter.lookAtSettings.headLerpSpeed )
		self.interactable:setAnimProgress( "aimbend_updown", self.cl.upDownControl )
		self.interactable:setAnimProgress( "aimbend_leftright", self.cl.leftRightControl )
	end
end

function Crafter.cl_disableAllAnimations( self )
	if self.interactable:hasAnim( "turnon" ) then
		self.interactable:setAnimEnabled( "turnon", false )
	else
		self.interactable:setAnimEnabled( "unfold", false )
	end
	self.interactable:setAnimEnabled( "idle", false )
	self.interactable:setAnimEnabled( "idlespecial01", false )
	self.interactable:setAnimEnabled( "idlespecial02", false )
	self.interactable:setAnimEnabled( "craft_start", false )
	if self.interactable:hasAnim( "craft_loop" ) then
		self.interactable:setAnimEnabled( "craft_loop", false )
	else
		self.interactable:setAnimEnabled( "craft_loop01", false )
		self.interactable:setAnimEnabled( "craft_loop02", false )
		self.interactable:setAnimEnabled( "craft_loop03", false )
	end
	self.interactable:setAnimEnabled( "craft_finish", false )
	self.interactable:setAnimEnabled( "aimbend_updown", false )
	self.interactable:setAnimEnabled( "aimbend_leftright", false )
	self.interactable:setAnimEnabled( "offline", false )
end

function Crafter.client_canInteract( self )
	if not g_craftingRecipeSets then
		return false
	end
	if self.shape:getShapeUuid() == ITEMS.obj_survivalobject_mininghub_dispenserbot then
		if self.cl.mininghubLocked then
			return false
		end
	end
	local parent = self:getParent()
	if not ( self.crafter.needsPower or self.crafter.needsActivation )
		or ( self.crafter.needsPower and ( parent == nil or parent.active ) )
		or ( self.crafter.needsActivation and self:cl_checkActivation() ) then
		local language = sm.gui.getCurrentLanguage()
		local keyBindingText =  sm.gui.getKeyBinding( "Use", true )
		local title = sm.shape.getShapeTitle( self.shape.uuid )
		if language == "German" or language == "Japanese" or language == "Korean" then
			sm.gui.setInteractionText( "", keyBindingText, "".."#FFFFC0"..title.." #FFFFFF".."#{INTERACTION_USE}" )
		else
			sm.gui.setInteractionText( "", keyBindingText, "#{INTERACTION_USE} ".."#FFFFC0"..title )
		end
	else
		sm.gui.setInteractionText( "#{INFO_REQUIRES_POWER}" )
		return false
	end
	return true
end

function Crafter.cl_setGuiContainers( self )
	if IsCraftBot( self.shape:getShapeUuid() ) or IsSawTable( self.shape:getShapeUuid() ) then
		local containers = {}
		local inputContainers = sm.pipeGraph.getInputContainers( self.shape )
		for _, val in ipairs( inputContainers ) do
			table.insert( containers, GetPipeGraphObjectContainer( val ) )
		end
		table.insert( containers, sm.localPlayer.getPlayer():getInventory() )
		self.cl.guiInterface:setContainers( "", containers )
	else
		self.cl.guiInterface:setContainer( "", sm.localPlayer.getPlayer():getInventory() )
	end
end

function Crafter.client_onInteract( self, character, state )
	if state == true then
		local parent = self:getParent()
		if not ( self.crafter.needsPower or self.crafter.needsActivation )
			or ( self.crafter.needsPower and ( parent == nil or parent.active ) )
			or ( self.crafter.needsActivation and self:cl_checkActivation() )  then
			self:cl_setGuiContainers()
			if self.interactable.shape.uuid ~= ITEMS.obj_survivalobject_dispenserbot and self.interactable.shape.uuid ~= ITEMS.obj_survivalobject_mininghub_dispenserbot then
				for idx = 1, self.crafter.slots do
					local val = self.cl.craftArray[idx]
					if val then
						local recipe = val.recipe
						local craftTime = math.ceil( recipe.craftTime / self.crafter.speed ) * 40
						if val.batched and val.count > 0 then
							craftTime = craftTime * val.count
						end

						local remainingTicks = craftTime - clamp( val.time, 0, craftTime )
						if not val.batched then
							remainingTicks = max( remainingTicks, 1 ) -- avoid showing collect button
						end

						local gridItem = {}
						gridItem.itemId = recipe.itemId
						gridItem.craftTime = craftTime
						gridItem.remainingTicks = remainingTicks
						gridItem.locked = false
						gridItem.repeating = val.loop
						gridItem.recipeQuantity = recipe.quantity
						gridItem.count = max( 1, val.count )
						self.cl.guiInterface:setGridItem( "ProcessGrid", idx - 1, gridItem )

					else
						local gridItem = {}
						gridItem.itemId = "00000000-0000-0000-0000-000000000000"
						gridItem.craftTime = 0
						gridItem.remainingTicks = 0
						gridItem.locked = false
						gridItem.repeating = false
						gridItem.recipeQuantity = 0
						gridItem.count = 0
						self.cl.guiInterface:setGridItem( "ProcessGrid", idx - 1, gridItem )
					end
				end

				if self.crafter.slots < 8 then
					local shapeUuid = self.shape:getShapeUuid()

					local gridItem = {}
					gridItem.locked = true

					if shapeUuid == ITEMS.obj_craftbot_craftbot1 then

						gridItem.unlockLevel = 2

						self.cl.guiInterface:setGridItem( "ProcessGrid", 2, gridItem )
						self.cl.guiInterface:setGridItem( "ProcessGrid", 3, gridItem )

						gridItem.unlockLevel = 3

						self.cl.guiInterface:setGridItem( "ProcessGrid", 4, gridItem )
						self.cl.guiInterface:setGridItem( "ProcessGrid", 5, gridItem )

						gridItem.unlockLevel = 4

						self.cl.guiInterface:setGridItem( "ProcessGrid", 6, gridItem )
						self.cl.guiInterface:setGridItem( "ProcessGrid", 7, gridItem )

					elseif shapeUuid == ITEMS.obj_craftbot_craftbot2 then

						gridItem.unlockLevel = 3

						self.cl.guiInterface:setGridItem( "ProcessGrid", 4, gridItem )
						self.cl.guiInterface:setGridItem( "ProcessGrid", 5, gridItem )

						gridItem.unlockLevel = 4

						self.cl.guiInterface:setGridItem( "ProcessGrid", 6, gridItem )
						self.cl.guiInterface:setGridItem( "ProcessGrid", 7, gridItem )

					elseif shapeUuid == ITEMS.obj_craftbot_craftbot3 then
						
						gridItem.unlockLevel = 4

						self.cl.guiInterface:setGridItem( "ProcessGrid", 6, gridItem )
						self.cl.guiInterface:setGridItem( "ProcessGrid", 7, gridItem )

					end
				end
			end

			self.cl.guiInterface:setText( "SubTitle", self.crafter.subTitle )
			self.cl.guiInterface:open()

			local pipeConnection = #sm.pipeGraph.getOutputContainers( self.shape ) > 0

			self.cl.guiInterface:setVisible( "PipeConnection", pipeConnection )

			self:cl_refreshUpgradeButton()

			if sm.game.getEnableUpgrade() and self.crafter.upgrade then
				local nextLevel = crafters[ self.crafter.upgrade ]
				local upgradeInfo = {}
				local nextLevelSlots = nextLevel.slots - self.crafter.slots
				if nextLevelSlots > 0 then
					upgradeInfo["Slots"] = nextLevelSlots
				end
				local nextLevelSpeed = nextLevel.speed - self.crafter.speed
				if nextLevelSpeed > 0 then
					upgradeInfo["Speed"] = nextLevelSpeed
				end
				self.cl.guiInterface:setData( "UpgradeInfo", upgradeInfo )
			end
		end
	end
end

function Crafter.cl_refreshUpgradeButton( self )
	local bShouldBeVisible = sm.game.getEnableUpgrade() and self.crafter.upgradeCost ~= nil
	if bShouldBeVisible then
		local upgradeItemId = self.crafter.upgradeCostMultiComponent and MultiComponentKit or ITEMS.obj_consumable_component
		local available = sm.container.totalQuantity( sm.localPlayer.getPlayer():getInventory(), upgradeItemId )
		if available ~= self.cl.lastUpgradeAvailable then
			local upgradeData = {
				cost = self.crafter.upgradeCost,
				available = available,
				multiComponent = self.crafter.upgradeCostMultiComponent == true
			}
			self.cl.guiInterface:setData( "Upgrade", upgradeData )
			self.cl.lastUpgradeAvailable = available
		end
	end
	if bShouldBeVisible ~= self.cl.lastUpgradeVisible then
		self.cl.guiInterface:setVisible( "Upgrade", bShouldBeVisible )
		self.cl.lastUpgradeVisible = bShouldBeVisible
	end
end

function Crafter.cl_drawProcess( self )
	self:cl_refreshUpgradeButton()

	for idx = 1, self.crafter.slots do
		local val = self.cl.craftArray[idx]
		if val then
			local recipe = val.recipe

			local craftTime = math.ceil( recipe.craftTime / self.crafter.speed ) * 40
			if val.batched and val.count > 0 then
				craftTime = craftTime * val.count
			end
			
			local remainingTicks = craftTime - clamp( val.time, 0, craftTime )
			if not val.batched then
				remainingTicks = max( remainingTicks, 1 ) -- avoid showing collect button
			end

			if self.interactable.shape.uuid ~= ITEMS.obj_survivalobject_dispenserbot and self.interactable.shape.uuid ~= ITEMS.obj_survivalobject_mininghub_dispenserbot then
				local gridItem = {}
				gridItem.itemId = recipe.itemId
				gridItem.craftTime = craftTime
				gridItem.remainingTicks = remainingTicks
				gridItem.locked = false
				gridItem.repeating = val.loop
				gridItem.recipeQuantity = recipe.quantity
				gridItem.count = max( 1, val.count )
				self.cl.guiInterface:setGridItem( "ProcessGrid", idx - 1, gridItem )
			end
		else
			if self.interactable.shape.uuid ~= ITEMS.obj_survivalobject_dispenserbot and self.interactable.shape.uuid ~= ITEMS.obj_survivalobject_mininghub_dispenserbot then
				local gridItem = {}
				gridItem.itemId = "00000000-0000-0000-0000-000000000000"
				gridItem.craftTime = 0
				gridItem.remainingTicks = 0
				gridItem.locked = false
				gridItem.repeating = false
				gridItem.recipeQuantity = 0
				gridItem.count = 0
				self.cl.guiInterface:setGridItem( "ProcessGrid", idx - 1, gridItem )
			end
		end
	end
end

-- Gui callbacks

function Crafter.cl_onRecipeGridItemClickedNew( self, gridName, index, data )
	RecipeManager.Cl_SeenRecipe( data.itemId )
end

function Crafter.cl_onCraft( self, buttonName, index, data )
	local recipe = self:getRecipeByUuid( data.itemId )
	if recipe ~= nil and RecipeManager.Cl_IsUnlocked( recipe.itemId ) then
		self.network:sendToServer( "sv_n_craft", { itemId = data.itemId } )
	else
		print( "Recipe is locked" )
	end
end

function Crafter.sv_n_craft( self, params, player )
	local recipe = self:getRecipeByUuid( params.itemId )
	if recipe ~= nil and RecipeManager.Sv_IsUnlocked( recipe.itemId ) then
		self:sv_craft( { recipe = recipe }, player )
	else
		print( "Recipe is locked" )
	end
end

function Crafter.sv_n_craftIndex( self, params, player )
	local recipe = self:getRecipeByIndex( params.index )
	if recipe ~= nil and RecipeManager.Cl_IsUnlocked( recipe.itemId ) then
		self:sv_craft( { recipe = recipe }, player )
	else
		print( "Recipe is locked index" )
	end
end

function Crafter.sv_craft( self, params, player )
	local recipe = params.recipe

	if #self.sv.craftArray >= self.crafter.slots then
		print( "Craft queue full" )
		return
	end

	-- Charge container
	sm.container.beginTransaction()

	local containerArray = {}
	local inputContainers = sm.pipeGraph.getInputContainers( self.shape )
	if player then
		inputContainers[#inputContainers+1] = player:getInventory()
	end

	for _, ingredient in ipairs( recipe.ingredientList ) do
		local consumeCount = ingredient.quantity

		for _, container in ipairs( inputContainers ) do
			if consumeCount > 0 then
				local target = nil
				if type( container ) == "Shape" then
					target = GetPipeGraphObjectContainer( container )
					table.insert( containerArray, { targetContainer = container, itemId = ingredient.itemId } )
				else
					target = container
				end
				consumeCount = consumeCount - sm.container.spend( target, ingredient.itemId, consumeCount, false )
			else
				break
			end
		end

		if consumeCount > 0 then
			print("Could not consume enough of ", ingredient.itemId, " Needed ", consumeCount, " more")
			sm.container.abortTransaction()
			return
		end
	end


	if sm.container.endTransaction() then -- Can afford
		local containerObj = self:sv_getContainerShapeForRecipe( recipe )
		table.insert( self.sv.craftArray,
			{
				recipe = recipe,
				time = -1,
				loop = params.loop or false,
				count = 1,
				batched = containerObj == nil
			} )

		self:sv_markStorageDirty()
		self:sv_markClientDataDirty()

		if #containerArray > 0 then
			self.network:sendToClients( "cl_n_onCraftFromChest", containerArray )
		end
		if self.shape:getShapeUuid() == ITEMS.obj_survivalobject_dispenserbot then
			QuestManager.Sv_SendEvent(  QuestEvent.DispenserCraftStarted )
		end
	else
		print( "Can't afford to craft" )
	end
end

function Crafter.sv_getContainerShapeForRecipe( self, recipe )
	local items = { sm.uuid.new( recipe.itemId )  }
	local quantities = { recipe.quantity }
	if recipe.extras then
		for _, extra in ipairs( recipe.extras ) do
			items[#items+1] = sm.uuid.new(extra.itemId)
			quantities[#quantities+1] = extra.quantity
		end
	end
	return sm.pipeGraph.getContainerShapeToCollectTo( self.shape, items, quantities )
end

function Crafter.cl_n_onCraftFromChest( self, params )
	for _, tbl in ipairs( params ) do
		local shapeList = {}
		local containerPath = sm.pipeGraph.getContainerPath( self.shape, tbl.targetContainer, sm.pipeGraph.direction.incoming )
		for _, shape in reverse_ipairs( containerPath ) do
			table.insert( shapeList, shape )
		end

		table.insert( shapeList, self.shape )
		self.cl.pipeEffectPlayer:pushShapeEffectTask( shapeList, tbl.itemId )
	end
end

function Crafter.cl_n_onCollectToChest( self, params )

	local containerPath = sm.pipeGraph.getContainerPath( self.shape, params.targetContainer, sm.pipeGraph.direction.outgoing )
	table.insert( containerPath, 1, self.shape)

	self.cl.pipeEffectPlayer:pushShapeEffectTask( containerPath, params.itemId )
end

function Crafter.cl_onRepeat( self, buttonName, index, gridItem )
	self.network:sendToServer( "sv_n_repeat", { slot = index } )
end

function Crafter.cl_onCollect( self, buttonName, index, gridItem )
	self.network:sendToServer( "sv_n_collect", { slot = index } )
end

function Crafter.sv_n_repeat( self, params )
	local val = self.sv.craftArray[params.slot + 1]
	if val then
		val.loop = not val.loop
		if val.loop then
			sm.pipeGraph.setAutomatedTask( self.shape, val.recipe, IsParallelCrafter( self.shape:getShapeUuid() ) )
		else
			sm.pipeGraph.removeAutomatedTask( self.shape, sm.uuid.new( val.recipe.itemId ) )
		end

		if val.count < 1 and not val.loop then
			table.remove( self.sv.craftArray, params.slot + 1 )
		end
		self:sv_markStorageDirty()
		self:sv_markClientDataDirty()
	end
end

function Crafter.sv_n_collect( self, params, player )
	local val = self.sv.craftArray[params.slot + 1]
	if val then
		local recipe = val.recipe
		local craftTime = math.ceil( recipe.craftTime / self.crafter.speed ) * 40
		if val.batched and val.count > 0 then
			craftTime = craftTime * val.count
		end
		if val.time >= craftTime then
			local uid = sm.uuid.new( recipe.itemId )
			sm.container.beginTransaction()
			sm.container.collect( player:getInventory(), uid, recipe.quantity * val.count )
			if recipe.extras then
				for _,extra in ipairs( recipe.extras ) do
					sm.container.collect( player:getInventory(), sm.uuid.new( extra.itemId ), extra.quantity * val.count )
				end
			end
			if sm.container.endTransaction() then -- Has space
				sv_awardBlockCraftAchievement( recipe, val.count )
				if uid == ITEMS.obj_interactive_beacon then
					ProgressionManager.Sv_CraftBeacon()
				end
				if val.loop then
					val.time = -1
					val.count = 0
				else
					table.remove( self.sv.craftArray, params.slot + 1 )
				end
				self:sv_markStorageDirty()
				self:sv_markClientDataDirty()
			else
				self.network:sendToClient( player, "cl_n_onMessage", "#{INFO_INVENTORY_FULL}" )
			end
		else
			print( "Not done" )
		end
	end
end

function Crafter.sv_spawn( self )
	if not sm.exists( self.sv.saved.spawner ) then
		print("No spawner existed")
		return false
	end

	local val = self.sv.craftArray[1]
	local recipe = val.recipe

	local spawnerSize = sm.item.getShapeSize( self.sv.saved.spawner.shape.uuid ) * 0.25
	local spawnerRot = self.sv.saved.spawner.shape:getWorldRotation()
	local spawnerPos = self.sv.saved.spawner.shape:getWorldPosition()

	local uid = sm.uuid.new( recipe.itemId )
	local spawnSize = sm.item.getShapeSize( uid ) * 0.25
	local spawnRot = spawnerRot * sm.quat.rotNegX90()
	if self.crafter.spawnRotation then
		spawnRot = self.crafter.spawnRotation * spawnRot
	end
	local spawnPos = spawnerPos - sm.vec3.new( 0, 0, spawnerSize.y * 0.5 ) - ( spawnRot * ( sm.quat.rotX90() * spawnSize ) ) * sm.vec3.new( 0.5, 0.5, 1 )




	if sm.item.isMultiShape( uid ) then
		sm.creation.buildMultiShape( uid, spawnPos, spawnRot )
	else
		local body = sm.body.createBody( spawnPos, spawnRot, true )
		local shape = body:createPart( uid, sm.vec3.new( 0, 0, 0), sm.vec3.new( 0, -1, 0 ), sm.vec3.new( 1, 0, 0 ), true )
		QuestManager.Sv_SendEvent( QuestEvent.DispenserSpawnShape, { shapeUuid = uid } )
	end

	if uid == ITEMS.obj_craftbot_cookbot and QuestManager.Sv_IsQuestComplete( "quest_mystery_call" ) then
		DialogManager.Sv_QueueNamedBondBuilderFront( "hubert_cookbot", 30 )
	end

	table.remove( self.sv.craftArray, 1 )
	self:sv_markStorageDirty()
	self:sv_markClientDataDirty()
	return true
end

function Crafter.cl_onUpgrade( self, buttonName )
	self.network:sendToServer( "sv_n_upgrade" )
end

function Crafter.sv_n_upgrade( self, params, player )
	print( "Upgrading" )

	if sm.game.getEnableUpgrade() then
		if self.crafter.upgrade then
			if sm.container.beginTransaction() then

				if self.crafter.upgradeCostMultiComponent then
					sm.container.spend( player:getInventory(), MultiComponentKit, self.crafter.upgradeCost, true )
				else
					sm.container.spend( player:getInventory(), ITEMS.obj_consumable_component, self.crafter.upgradeCost, true )
				end

				if sm.container.endTransaction() then
					local upgrade = self.crafter.upgrade
					--RecipeManager.Sv_UnlockCrafterUpgrades( upgrade ) previously unlocked recipes the first time you upgraded a new level of crafter, deactivated in recipemanager.
					self.crafter = crafters[upgrade]
					self.network:sendToClients( "cl_n_upgrade", upgrade )
					self.shape:replaceShape( sm.uuid.new( upgrade ) )
				end
			end
		else
			print( "Can't be upgraded" )
		end
	end
end

function Crafter.cl_n_upgrade( self, upgrade )
	print( "Client Upgrading" )
	if not sm.isHost then
		self.crafter = crafters[upgrade]
	end
	self:cl_updateRecipeGrid()

	if self.cl.guiInterface:isActive() then

		self.cl.lastUpgradeAvailable = nil
		self.cl.lastUpgradeVisible = nil
		self:cl_refreshUpgradeButton()

		self.cl.guiInterface:setText( "SubTitle", self.crafter.subTitle )

		if self.crafter.upgrade then
			local nextLevel = crafters[ self.crafter.upgrade ]
			local upgradeInfo = {}
			local nextLevelSlots = nextLevel.slots - self.crafter.slots
			if nextLevelSlots > 0 then
				upgradeInfo["Slots"] = nextLevelSlots
			end
			local nextLevelSpeed = nextLevel.speed - self.crafter.speed
			if nextLevelSpeed > 0 then
				upgradeInfo["Speed"] = nextLevelSpeed
			end
			self.cl.guiInterface:setData( "UpgradeInfo", upgradeInfo )

			self.cl.guiInterface:playEffect( "Upgrade", "Gui - Upgrade", false )
		else
			self.cl.guiInterface:setData( "UpgradeInfo", nil )
		end
	end

	sm.effect.playHostedEffect( "Part - Upgrade", self.interactable )
end

function Crafter.cl_n_onMessage( self, msg )
	NotificationManager.Cl_AddGenericNotification( msg )
end

Workbench = class( Crafter )
Workbench.maxParentCount = 1
Workbench.connectionInput = sm.interactable.connectionType.logic

Dispenser = class( Crafter )
Dispenser.maxParentCount = 1
Dispenser.connectionInput = sm.interactable.connectionType.logic

Craftbot = class( Crafter )
PortableCraftbot = class( Crafter )

MininghubDispenser = class( Crafter )