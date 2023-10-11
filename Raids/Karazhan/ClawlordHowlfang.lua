
local module, L = BigWigs:ModuleDeclaration("Clawlord Howlfang", "Karazhan")

module.revision = 30020
module.enabletrigger = module.translatedName
module.toggleoptions = {"terrifyingpresence", "curse", "enrage", "bosskill"}
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Karazhan"],
	AceLibrary("Babble-Zone-2.2")["Karazhan"],
}

L:RegisterTranslations("enUS", function() return {
	cmd = "ClawlordHowlfang",

	terrifyingpresence_cmd = "terrifyingpresence",
	terrifyingpresence_name = "Terrifying Presence Alert",
	terrifyingpresence_desc = "Warn for Terrifying Presence",

	curse_cmd = "curse",
	curse_name = "Curse Alert",
	curse_desc = "Warn for Curse",
	
	enrage_cmd = "enrage",
	enrage_name = "Enrage Alert",
	enrage_desc = "Warns for Enrage",
	
	
	
	trigger_terrifyingPresenceSelf = "You are afflicted by Terrifying Presence %((.+)%).",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	trigger_terrifyingPresence = "(.+) is afflicted by Terrifying Presence %((.+)%).",--CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE
	bar_terrifyingPresence = "% reduced",

	trigger_curse = "afflicted by Shadowbane Curse.",--CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	msg_curse = "Shadowbane Curse, Decurse!",
	
	trigger_yellEnrage = "My pack shall tear you apart, bone by bone!",--CHAT_MSG_MONSTER_YELL
	msg_enrage = "Enrage!",
	
	trigger_engage = "So it was you I smelled! Such a foul taint.",--CHAT_MSG_MONSTER_YELL
} end )

local timer = {
	terrifyingPresence = 10,
}
local icon = {
	terrifyingPresence = "Spell_Shadow_VampiricAura",
	curse = "Spell_Shadow_GatherShadows",
	enrage = "Spell_Shadow_UnholyFrenzy",
}
local color = {
	terrifyingPresence = "White",
	curse = "Black",
}
local syncName = {
	terrifyingPresence = "ClawlordHowlfangTerrifyingPresence"..module.revision,
	curse = "ClawlordHowlfangCurse"..module.revision,
	enrage = "ClawlordHowlfangEnrage"..module.revision,
}

module:RegisterYellEngage(L["trigger_engage"])

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")--trigger_terrifyingPresenceSelf, trigger_curse
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")--trigger_terrifyingPresence, trigger_curse
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")--trigger_terrifyingPresence, trigger_curse
	
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL", "Event")--trigger_yellEnrage
	
	self:ThrottleSync(0, syncName.terrifyingPresence)
	self:ThrottleSync(10, syncName.curse)
	self:ThrottleSync(10, syncName.enrage)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
end

function module:OnDisengage()
end

function module:Event(msg)
	if string.find(msg, L["trigger_terrifyingPresence"]) then
		local _,_, tpPlayer, tpQty = string.find(msg, L["trigger_terrifyingPresence"])
		local tpPlayerAndQty = tpPlayer .. " " .. tpQty
		self:Sync(syncName.terrifyingPresence .. " " .. tpPlayerAndQty)
		
	elseif string.find(msg, L["trigger_terrifyingPresenceSelf"]) then
		local _,_, tpQty, _ = string.find(msg, L["trigger_terrifyingPresence"])
		local tpPlayer = UnitName("Player")
		local tpPlayerAndQty = tpPlayer .. " " .. tpQty
		self:Sync(syncName.terrifyingPresence .. " " .. tpPlayerAndQty)
	
	elseif string.find(msg, L["trigger_curse"]) then
		self:Sync(syncName.curse)
	
	elseif string.find(msg, L["trigger_yellEnrage"]) then
		self:Sync(syncName.enrage)
		
	end
end


function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.terrifyingPresence and rest and self.db.profile.terrifyingpresence then
		self:TerrifyingPresence(rest)
	elseif sync == syncName.curse and self.db.profile.curse then
		self:Curse()
	elseif sync == syncName.enrage and self.db.profile.enrage then
		self:Enrage()
	end
end


function module:TerrifyingPresence(rest)

local tpPlayer = strsub(rest,0,strfind(rest," ") - 1)
local tpQty = tonumber(strsub(rest,strfind(rest," "),strlen(rest)))
local currentReduction = tpQty * 5
local previousQty = tpQty - 1
local previousReduction = previousQty * 5

	--if no tank, don't do anything
	TargetByName("Clawlord Howlfang",true)
	if UnitName("targettarget") == nil then
		TargetLastTarget()
		bwHowlfangPreviousTarget = nil
		return
	end
	
	local currentTank = UnitName("targettarget")
	TargetLastTarget()

	--if current tank is same as previous tank, remove previous bar
	if bwHowlfangPreviousTarget ~= nil then
		if currentTank == tpPlayer and currentTank == bwHowlfangPreviousTarget then
			self:RemoveBar(tpPlayer.." "..previousReduction..L["bar_terrifyingPresence"])
		end
	end
	
	self:Bar(tpPlayer.." "..currentReduction..L["bar_terrifyingPresence"], timer.terrifyingPresence, icon.terrifyingPresence, true, color.terrifyingPresence)
	bwHowlfangPreviousTarget = tpPlayer
end

function module:Curse()
	self:Message(L["msg_curse"], "Urgent", false, nil, false)
	
	if UnitClass("Player") == "Mage" then
		self:WarningSign(icon.curse, 0.7)
	elseif UnitClass("Player") == "Druid" then
		self:WarningSign(icon.curse, 0.7)
	end
end

function module:Enrage()
	self:Message(L["msg_enrage"], "Attention", false, nil, false)
	self:WarningSign(icon.enrage, 0.7)
end