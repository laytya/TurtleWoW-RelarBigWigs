
----------------------------------
--      Module Declaration      --
----------------------------------

local module, L = BigWigs:ModuleDeclaration("Fankriss the Unyielding", "Ahn'Qiraj")


----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	cmd = "Fankriss",
	
	bigicon_cmd = "bigicon",
	bigicon_name = "Stacks big icon alert",
	bigicon_desc = "Shows a big icon when you have too many stacks",
	
	worm_cmd = "worm",
	worm_name = "Worm Alert",
	worm_desc = "Warn for Incoming Worms",
	
	wound_cmd = "wound",
	wound_name = "Wound 5 stacks alerts",
	wound_desc = "Alert for 5 stacks of Wound",
	
	sounds_cmd = "sounds",
	sounds_name = "Too many stacks sound alert",
	sounds_desc = "Sound effect when you have too many stacks",
	
	taunt_cmd = "taunt",
	taunt_name = "Big icon for taunt alert",
	taunt_desc = "Shows a big icon when you should taunt.",
	
	wormtrigger = "Fankriss the Unyielding casts Summon Worm.",
	wormwarn = "Incoming Worm! (%d)",
	wormbar = "Sandworm Enrage (%d)",

	entangle_cmd = "entangle",
	entangle_name = "Entangle Alert",
	entangle_desc = "Warn for Entangle and incoming Bugs",
	
	wound_trigger = "(.+) (.+) afflicted by Mortal Wound %(5%)",
	
	entangleplayer = "You are afflicted by Entangle.",
	entangleplayerother = "(.*) is afflicted by Entangle.",
	entanglewarn = "Entangle!",
} end )

L:RegisterTranslations("esES", function() return {
	--cmd = "Fankriss",
	--worm_cmd = "worm",
	worm_name = "Alerta de Gusano",
	worm_desc = "Avisa para Gusanos entrantes",

	wormtrigger = "Fankriss el Implacable lanza Invocar gusano.",
	wormwarn = "¡Gusano entrante! (%d)",
	wormbar = "Gusano de arena enfurecido (%d)",

	--entangle_cmd = "entangle",
	entangle_name = "Alerta de Enredar",
	entangle_desc = "Avisa para Enredar y insectos entrantes",
	entangleplayer = "Sufres de Enredar.",
	entangleplayerother = "(.*) sufre de Enredar.",
	entanglewarn = "¡Enredado!",
} end )

L:RegisterTranslations("deDE", function() return {
	worm_name = "Wurm beschw\195\182ren",
	worm_desc = "Warnung, wenn Fankriss einen Wurm beschw\195\182rt.",

	wormtrigger = "Fankriss der Unnachgiebige wirkt Wurm beschw\195\182ren.",
	wormwarn = "Wurm wurde beschworen! (%d)",
	wormbar = "Wurm ist w\195\188tend (%d)",

	entangle_name = "Umschlingen Warnung",
	entangle_desc = "Warnt vor Umschlingen und den Käfern",
	entangleplayer = "Ihr seid von Umschlingen betroffen.",
	entangleplayerother = "(.*) ist von Umschlingen betroffen.",
	entanglewarn = "Umschlingen!",
} end )

---------------------------------
--      	Variables 		   --
---------------------------------

-- module variables
module.revision = 20004 -- To be overridden by the module!
module.enabletrigger = module.translatedName -- string or table {boss, add1, add2}
--module.wipemobs = { L["add_name"] } -- adds which will be considered in CheckForEngage
module.toggleoptions = {"wound", "taunt", "bigicon", "sounds", "entangle", "bosskill"}


-- locals
local timer = {
	wound = 15,
}

local icon = {
	entangle = "Spell_Nature_Web",
	taunt = "spell_nature_reincarnation",
	stacks = "ability_criticalstrike",
}

local syncName = {
	entangle = "FankrissEntangle"..module.revision,
	wound = "FankrissWound"..module.revision,
}

local _, playerClass = UnitClass("player")


------------------------------
--      Initialization      --
------------------------------

-- called after module is enabled
function module:OnEnable()
	--self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")

	self:ThrottleSync(10, syncName.entangle)
	self:ThrottleSync(10, syncName.wound)
end

-- called after module is enabled and after each wipe
function module:OnSetup()
--worms = 0
end

-- called after boss is engaged
function module:OnEngage()

end

-- called after boss is disengaged (wipe(retreat) or victory)
function module:OnDisengage()
end


------------------------------
--      Event Handlers      --
------------------------------

function module:Event(msg)
	local _,_,woundperson = string.find(msg, L["wound_trigger"])
	if string.find(msg, L["entangleplayer"]) or string.find(msg, L["entangleplayerother"]) then
		self:Sync(syncName.entangle)
	end
	if string.find(msg, L["wound_trigger"]) then
		self:Sync(syncName.wound.." "..woundperson)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.entangle and self.db.profile.entangle then
		self:Entangle()
	elseif sync == syncName.wound and self.db.profile.wound then
		self:Wound(rest)
	end
end

function module:Entangle()
	self:Message(L["entanglewarn"], "Urgent", true, "Alarm")
	self:WarningSign(icon.entangle, 0.7)
end

function module:Wound(rest)
	if rest == UnitName("player") then
		if self.db.profile.sounds then
			self:Sound("stacks")
		end
		if self.db.profile.bigicon then
			self:WarningSign(icon.stacks, 0.7)
		end
	else
		if playerClass == "WARRIOR" and self.db.profile.taunt then
			self:WarningSign(icon.taunt, 0.7)
		end
	end
end
