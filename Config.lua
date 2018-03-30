UITweaks = {
	-- general switches
	enableBGCalendar 		= false, -- show bg bonus week in honor tab?
	easyBandages 			= false, -- enables "/bandage" macro
	moveBGButton 			= true, -- moves bg button from minimap to honor frame
	moveTicketFrame 		= true, -- moves ticket frame from corner to game menu (ESC)
	joinAsGroupButton 		= false, -- enables group bg join (AV)
	hideBuffs 				= true, -- don't display buff/debuff frame AT ALL
	filterCommonErrors 		= true, -- should filter common messages?
	hidePlayersTooltip 		= true, -- disable tooltips for players/mobs/npcs?
	lagMeter 				= true, -- shows lag in game menu
	chatBG 					= true, -- show chat background?
	hideErrors 				= true, -- hide Lua errors?
	showAllBuffs 			= true, -- extend default buffs frames to support up to 32 buffs?
	tooltipGuild 			= true, -- include guilds in tooltip
		tooltipClassColor 	= true, -- color player names by class in tooltip
	bigDebuffs 				= true, -- makes debuffs icon bigger
	debugEvents 			= false,
	
	-- see help/GlobalStrings.lua if you care for localization, otherwise just
	-- type error Exactly As it's Written
	filterMessages = {
		ERR_GENERIC_NO_TARGET,
		ERR_INVALID_ATTACK_TARGET,
		ERR_NO_ATTACK_TARGET,
		SPELL_FAILED_NO_COMBO_POINTS,
		SPELL_FAILED_INTERRUPTED,
		SPELL_FAILED_SPELL_IN_PROGRESS,
		SPELL_FAILED_MOVING,
		ERR_ABILITY_COOLDOWN,
		ERR_SPELL_COOLDOWN,
		OUT_OF_ENERGY,
		ERR_UNIT_NOT_FOUND,
		SPELL_FAILED_TOO_CLOSE,
	};
	
	-- action bars
	fadeInTime = 0.05, -- general timer
	fadeOutTime = 2, -- general timer
	hideBarsHPPct = 90, -- hide above % of your hp
	actionBars = {
		--"MultiBarBottomLeft" -- remove this line if you don't want to auto show/hide anything
		--"AutoBar",
		--"BuffFrame", "TemporaryEnchantFrame"
	},
	
	-- minimap related
	minimapFadeOutTime = 10, -- time after which minimap buttons will hide
	minimapButtons = {
		--[[
		"CT_OptionButton",
		"AtlasButton",
		"GathererUI_IconFrame",
		"kosListMiniMapButton"
		]] -- currently unused as I don't use minimap anymore
	},
};