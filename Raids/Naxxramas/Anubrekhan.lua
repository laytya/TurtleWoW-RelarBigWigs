
local module, L = BigWigs:ModuleDeclaration("Anub'Rekhan", "Naxxramas")

module.revision = 30012
module.enabletrigger = module.translatedName
module.toggleoptions = {"locust", "impale", "enrage", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Anubrekhan",

	locust_cmd = "locust",
	locust_name = "Locust Swarm Alert",
	locust_desc = "Warn for Locust Swarm",

	enrage_cmd = "enrage",
	enrage_name = "Crypt Guard Enrage Alert",
	enrage_desc = "Warn for Enrage",
	
	impale_cmd = "impale",
	impale_name = "Impale Alert",
	impale_desc = "Warns for Impale",
	
	starttrigger1 = "Just a little taste...",
	starttrigger2 = "Yes, run! It makes the blood pump faster!",
	starttrigger3 = "There is no way out.",
	
	trigger_locustSwarmCast = "Anub'Rekhan begins to cast Locust Swarm.",--CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF
	msg_locustSwarmCasting = "Incoming Locust Swarm!",
	bar_locustSwarmCasting = "Incoming Locust Swarm!",
	
	trigger_locustSwarmGain = "Anub'Rekhan is afflicted by Locust Swarm.",--CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE

	bar_locustSwarmIsUp = "Locust Swarm",
	
	trigger_locustSwarmEnds = "Locust Swarm fades from Anub'Rekhan.",--CHAT_MSG_SPELL_AURA_GONE_OTHER
	
	bar_locustSwarmCd = "Locust Swarm CD",
		
	trigger_impale = "Anub'Rekhan's Impale hits",
	bar_impale = "Impale CD",
	
	trigger_enrage = "Crypt Guard gains Enrage.",--CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	msg_enrage = "Crypt Guard Enrage - Stun + Traps!",
} end )

local timer = {
	firstLocustSwarm = {80,120},--96
	locustSwarmInterval = {90,110},
	locustSwarmDuration = 20,
	locustSwarmCastTime = 3,
	impale = {11.484,16.594},
}
local icon = {
	locust = "Spell_Nature_InsectSwarm",
	impale = "ability_backstab",
}
local syncName = {
	locustCast = "AnubLocustInc"..module.revision,
	locustGain = "AnubLocustSwarm"..module.revision,
	locustEnds = "AnubLocustEnds"..module.revision,
	impale = "AnubImpale"..module.revision,
	enrage = "AnubEnrage"..module.revision,
}

module:RegisterYellEngage(L["starttrigger1"])
module:RegisterYellEngage(L["starttrigger2"])
module:RegisterYellEngage(L["starttrigger3"])

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "Event")--Locust
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")--Impale
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")--Impale
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")--Impale
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")--guardEnrage
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")--LocustEnd
	
	self:ThrottleSync(10, syncName.locustCast)
	self:ThrottleSync(10, syncName.locustGain)
	self:ThrottleSync(10, syncName.locustEnds)
	self:ThrottleSync(10, syncName.impale)
	self:ThrottleSync(2, syncName.enrage)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
	if self.db.profile.locust then
		self:IntervalBar(L["bar_locustSwarmCd"], timer.firstLocustSwarm[1], timer.firstLocustSwarm[2], icon.locust, true, "white")
	end
	if self.db.profile.impale then
		self:Impale()
	end
end

function module:OnDisengage()
end

function module:Event(msg)
	if msg == L["trigger_locustSwarmCast"] then
		self:Sync(syncName.locustCast)
	elseif msg == L["trigger_locustSwarmGain"] then
		self:Sync(syncName.locustGain)
	elseif msg == L["trigger_locustSwarmEnds"] then
		self:Sync(syncName.locustEnds)
	elseif string.find(msg, L["trigger_impale"]) then
		self:Sync(syncName.impale)
	elseif msg == L["trigger_enrage"] then
		self:Sync(syncName.enrage)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.locustCast and self.db.profile.locust then
		self:LocustCast()
	elseif sync == syncName.locustGain and self.db.profile.locust then
		self:LocustGain()
	elseif sync == syncName.locustEnds and self.db.profile.locust then
		self:LocustEnds()
	elseif sync == syncName.impale and self.db.profile.impale then
		self:Impale()
	elseif sync == syncName.enrage and self.db.profile.enrage then
		self:Enrage()
	end
end

function module:LocustCast()
	self:RemoveBar(L["bar_impale"])
	
	if self.db.profile.locust then
		self:RemoveBar(L["bar_locustSwarmCd"])
		
		self:Message(L["msg_locustSwarmCasting"], "Orange", nil, "Beware")
		self:WarningSign(icon.locust, timer.locustSwarmCastTime)
		self:Bar(L["bar_locustSwarmCasting"], timer.locustSwarmCastTime, icon.locust, true, "green")
	end
	
	self:DelayedSync(timer.locustSwarmCastTime, syncName.locustGain)
end

function module:LocustGain()
	self:RemoveBar(L["bar_locustSwarmCasting"])
	self:Bar(L["bar_locustSwarmIsUp"], timer.locustSwarmDuration, icon.locust, true, "green")
end

function module:LocustEnds()
	self:RemoveBar(L["bar_locustSwarmIsUp"])
	self:IntervalBar(L["bar_locustSwarmCd"], timer.locustSwarmInterval[1], timer.locustSwarmInterval[2], icon.locust, true, "white")
	
	if self.db.profile.impale then
		self:Impale()
	end
end

function module:Impale()
	self:IntervalBar(L["bar_impale"], timer.impale[1], timer.impale[2], icon.impale, true, "red")
end

function module:Enrage()
	self:Message(L["msg_enrage"], "Important", nil, "Alarm")
end