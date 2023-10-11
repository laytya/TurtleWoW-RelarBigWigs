local module, L = BigWigs:ModuleDeclaration("Warchief Rend Blackhand", "Blackrock Spire")

local gyth = AceLibrary("Babble-Boss-2.2")["Gyth"]
local rend = AceLibrary("Babble-Boss-2.2")["Warchief Rend Blackhand"]

module.revision = 30002
module.enabletrigger = {gyth, rend}
module.toggleoptions = {"flamebreath", "freeze", "dismount", -1, "whirlwind", "enrage", "bosskill"}
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Blackrock Spire"],
	AceLibrary("Babble-Zone-2.2")["Blackrock Spire"],
}
--module.zonename = {
--	AceLibrary("AceLocale-2.2"):new("BigWigs")["Outdoor Raid Bosses Zone"],
--	AceLibrary("Babble-Zone-2.2")["Blackrock Spire"],
--	AceLibrary("Babble-Zone-2.2")["Upper Blackrock Spire"],
--}

L:RegisterTranslations("enUS", function() return {
	cmd = "Gyth",
	
	flamebreath_cmd = "flamebreath",
	flamebreath_name = "Flamebreath",
	flamebreath_desc = "Warn for Flamebreath.",
	
	freeze_cmd = "freeze",
	freeze_name = "Freeze",
	freeze_desc = "Prompts group to dispel your Freeze.",
	
	dismount_cmd = "dismount",
	dismount_name = "Dismount",
	dismount_desc = "Warn when Rend dismounts Gyth.",
	
	whirlwind_cmd = "whirlwind",
	whirlwind_name = "Whirlwind",
	whirlwind_desc = "Timer for Rend Whirlwind.",
	
	enrage_cmd = "enrage",
	enrage_name = "Enrage",
	enrage_desc = "Prompts Enrage.",

	flamebreath_bar = "Casting Flamebreath",
	flamebreathCast_trigger = "Gyth begins to cast Flame Breath",
	
	freeze_trigger = "You are afflicted by Freeze.",
	freeze_dispel = "Your Freeze is removed",
	freeze_fade = "Freeze fades from you",
	freeze_trigger_priest = "afflicted by Freeze",
	freeze_dispel_priest = "Freeze is removed",
	freeze_fade_priest = "Freeze fades",
	freeze_announce = "DISPEL ME",
	
	dismount_trigger = "Warchief Rend Blackhand is knocked off",
	dismount_trigger2 = "Gyth casts Summon Rend Blackhand",
	dismount_message = "Rend has dismounted Gyth!",
	
	whirlwind_open_trigger = "Blackhand gains Whirl",
	whirlwind_remove_trigger = "Blackhand's Whirlwind",
	whirlwind_bar = "Whirlwind CD",
	whirlwind_open_bar = "Whirlwind",
	
	enrage_trigger = "Blackhand gains Enrage",
	bossdeath_trigger = "Your victory shall be short lived."
} end )

local timer = {
	flamebreathCast = 2,
	whirlwindOpenTimer = 1.9,
	whirlwindCDTimer = 9.6,
}

local icon = {
	flamebreath = "Spell_fire_fire",
	whirlwind = "ability_whirlwind",
	enrage = "spell_shadow_unholyfrenzy",
	freeze = "spell_frost_glacier",
}

local syncName = {
	rendFlamebreath = "rendFlamebreath"..module.revision,
	rendDismount = "rendDismount"..module.revision,
	rendWhirlwind = "rendWhirlwind"..module.revision,
	rendWhirlwindRemove = "rendWhirlwindRemove"..module.revision,
	rendEnrage = "rendEnrage"..module.revision,
	rendBossdeath = "rendBossdeath"..module.revision,
}

function module:OnEnable()

	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event") -- Gyth Flamebreath
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event") -- Gyth Freeze self detection
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event") -- Detect Freeze party detection
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event") -- Gyth Freeze raid detection
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "Event") -- Rend Dismount
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE", "Event") -- Rend Dismount emote, probably doesn't work
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL", "Event") -- For module disabling
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event") -- Rend WW, Rend Enrage
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event") -- Rend WW
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event") -- Rend WW
	self:RegisterEvent("CHAT_MSG_SPELL_BREAK_AURA", "Event") -- Freeze dispel
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event") -- Freeze fade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event") -- Freeze fade from Party
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event") -- Freeze fade from Raid???
	self:RegisterEvent("CHAT_MSG_SAY", "Event") -- Testing purposes
	
	self:ThrottleSync(2, syncName.rendFlamebreath)
	self:ThrottleSync(2, syncName.rendDismount)
	self:ThrottleSync(2, syncName.rendWhirlwind)
	self:ThrottleSync(2, syncName.rendWhirlwindRemove)
	self:ThrottleSync(2, syncName.rendEnrage)
	self:ThrottleSync(2, syncName.rendBossdeath)
end

function module:OnSetup()
end

function module:OnEngage()
	local wasTargettingPlayer = false
	local myTarget
end

function module:OnDisengage()
end

function module:Event(msg)

	if string.find(msg, L["flamebreathCast_trigger"]) then
		self:Sync(syncName.rendFlamebreath)
		
	elseif string.find(msg, L["freeze_trigger"]) then
		self:Freeze()
		
	elseif string.find(msg, L["freeze_dispel"]) then
		self:FreezeOff()
		
	elseif string.find(msg, L["freeze_fade"]) then
		self:FreezeOff()
		
	elseif string.find(msg, L["freeze_trigger_priest"]) then
		self:FreezePriest()
		
	elseif string.find(msg, L["freeze_dispel_priest"]) then
		self:FreezeOff()
		
	elseif string.find(msg, L["freeze_fade_priest"]) then
		self:FreezeOff()
		
	elseif string.find(msg, L["dismount_trigger"]) or string.find(msg, L["dismount_trigger2"]) then
		self:Sync(syncName.rendDismount)
		
	elseif string.find(msg, L["whirlwind_open_trigger"]) then
		self:Sync(syncName.rendWhirlwind)
		
	elseif string.find(msg, L["whirlwind_remove_trigger"]) then
		self:Sync(syncName.rendWhirlwindRemove)
		
	elseif string.find(msg, L["enrage_trigger"]) then
		self:Sync(syncName.rendEnrage)
	
	elseif string.find(msg, L["bossdeath_trigger"]) then
		self:Sync(syncName.rendBossdeath)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)

	if sync == syncName.rendFlamebreath then
		self:Flamebreath()
		
	elseif sync == syncName.rendDismount then
		self:Dismount()
		
	elseif sync == syncName.rendWhirlwind then
		self:Whirlwind()
		
	elseif sync == syncName.rendWhirlwindRemove then
		self:WhirlwindRemove()
		
	elseif sync == syncName.rendEnrage then
		self:Enrage()
	
	elseif sync == syncName.rendBossdeath then
		self:Bossdeath()
	end
end

function module:Flamebreath()
	if self.db.profile.flamebreath then
		self:Bar(L["flamebreath_bar"], timer.flamebreathCast, icon.flamebreath, true, "Red")
	end
end

function module:Freeze()
	if self.db.profile.freeze then
		self:WarningSign(icon.freeze, 30)
		SendChatMessage(L["freeze_announce"],"YELL")

	end
end

function module:FreezePriest()
	if self.db.profile.freeze then
		if UnitClass("player") == "Priest" or UnitClass("player") == "Paladin" then
			self:WarningSign(icon.freeze, 30)
		end
	end
end

function module:FreezeOff()
	if self.db.profile.freeze then
		self:RemoveWarningSign(icon.freeze)
	end
end

function module:Dismount()
	if (IsRaidLeader() or IsRaidOfficer()) then
		if self.db.profile.dismount then
			if UnitName("target") and UnitInRaid("target") then -- If you're targetting a player
				myTarget = UnitName("target")
				wasTargettingPlayer = true
				self:TargetMark("Warchief Rend Blackhand",6)
			else
				self:TargetMark("Warchief Rend Blackhand", 6)
			end
			self:TargetMark("Gyth", 8)
			if wasTargettingPlayer == true then
				TargetByName(myTarget, exactMatch)
				wasTargettingPlayer = false
			end
		end
	end
	if self.db.profile.dismount then
		self:Message(L["dismount_message"], "Positive", false, "Alert", false)
	end
end

function module:Whirlwind()
	if self.db.profile.whirlwind then
		self:RemoveBar(L["whirlwind_bar"])
		self:Bar(L["whirlwind_open_bar"], timer.whirlwindOpenTimer, icon.whirlwind, true, "Orange")
		self:DelayedBar(1.9, L["whirlwind_bar"], timer.whirlwindCDTimer, icon.whirlwind, true, "White")
	end
end

function module:WhirlwindRemove()
	if self.db.profile.whirlwind then
		self:RemoveBar(L["whirlwind_open_bar"])
	end
end

function module:Enrage()
	if self.db.profile.enrage then
		self:WarningSign(icon.enrage, 4)
	end
end

function module:Bossdeath()
	if self.db.profile.bosskill then
		self.core:ToggleModuleActive(self, false)
	end
end

function module:TargetMark(target, mark) -- Helper function
	TargetByName(target, exactMatch)
	if GetRaidTargetIndex("target") ~= mark then
		SetRaidTarget("target",mark)
	end
end