
local module, L = BigWigs:ModuleDeclaration("High Priestess Mar'li", "Zul'Gurub")

module.revision = 30012
module.enabletrigger = module.translatedName
module.toggleoptions = {"phase", "spider", "drain", "volley", "webs", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Marli",
	
	spider_cmd = "spider",
	spider_name = "Spider Alert",
	spider_desc = "Warn when spiders spawn",

	volley_cmd = "volley",
	volley_name = "Poison Bolt Volley Alert",
	volley_desc = "Warn for Poison Bolt Volleys\n\n(Disclaimer: this bar has a \194\1772 seconds error)",

	drain_cmd = "drain",
	drain_name = "Drain Life Alert",
	drain_desc = "Warn for life drain",

	phase_cmd = "phase",
	phase_name = "Phase Notification",
	phase_desc = "Announces the boss' phase transition",
	
	webs_cmd = "webs",
	webs_name = "Webs Notification",
	webs_desc = "Warn for Enveloping Webs",
	
	spawn_name = "Spawn of Mar'li",

	spiders_trigger = "Aid me my brood!",
	drainlifeyoustart_trigger = "You are afflicted by Drain Life\.",
	drainlifeotherstart_trigger = "(.+) is afflicted by Drain Life\.",
	drainlifeyouend_trigger = "Drain Life fades from you\.",
	drainlifeotherend_trigger = "Drain Life fades from (.+)\.",
	pbv = "Poison Bolt Volley",
	pbvafflicts_trigger = "afflicted by Poison Bolt Volley",
	pbvhits_trigger = "High Priestess Mar'li 's Poison Bolt Volley hits",
	pbvresist_trigger = "High Priestess Mar'li 's Poison Bolt Volley was resisted(.+)",
	pbvimmune_trigger = "High Priestess Mar'li 's Poison Bolt Volley fail(.+) immune",
	you = "you",
	drainlife = "Drain Life",
	spiders_message = "Spiders spawned!",
	drainlife_message = "Drain Life! Interrupt/dispel it!",
	trollphase = "Troll phase",
	trollphase_trigger = "The brood shall not fall",
	spiderphase = "Spider phase",
	spiderphase_trigger1 = "Draw me to your web mistress Shadra",
	spiderphase_trigger2 = "Shadra, make of me your avatar",
		
	trigger_webs = "is afflicted by Enveloping Webs.", --CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE // CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	
} end )

module.wipemobs = { L["spawn_name"] }

local timer = {
	charge = 10,
	teleport = 30,
}
local icon = {
	charge = "Spell_Frost_FrostShock",
	teleport = "Spell_Arcane_Blink",
	webs = "Spell_Nature_EarthBind",
}
local syncName = {
	drain = "MarliDrainStart"..module.revision,
	drainOver = "MarliDrainEnd"..module.revision,
	trollPhase = "MarliTrollPhase"..module.revision,
	spiderPhase = "MarliSpiderPhase"..module.revision,
	spiders = "MarliSpiders"..module.revision,
	volley = "MarliVolley"..module.revision,
	webs = "MarliWebs"..module.revision,
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")--webs
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")--webs
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")--webs
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_PARTY", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")

	self:ThrottleSync(5, syncName.drain)
	self:ThrottleSync(5, syncName.drainOver)
	self:ThrottleSync(5, syncName.trollPhase)
	self:ThrottleSync(5, syncName.spiderPhase)
	self:ThrottleSync(5, syncName.spiders)
	self:ThrottleSync(11, syncName.volley)
	self:ThrottleSync(3, syncName.webs)
end

function module:OnSetup()
end

function module:OnEngage()
end

function module:OnDisengage()
end

function module:CHAT_MSG_MONSTER_YELL(msg)
	if string.find(msg, L["spiders_trigger"]) then
		self:Sync(syncName.spiders)
	elseif string.find(msg, L["trollphase_trigger"]) then
		self:Sync(syncName.trollPhase)
	elseif string.find(msg, L["spiderphase_trigger1"]) or string.find(msg, L["spiderphase_trigger2"]) then
		self:Sync(syncName.spiderPhase)
	end
end

function module:Event(msg)
	local _,_,drainlifeotherstart,_ = string.find(msg, L["drainlifeotherstart_trigger"])
	local _,_,drainlifeotherend,_ = string.find(msg, L["drainlifeotherend_trigger"])
	if string.find(msg, L["pbvafflicts_trigger"]) or string.find(msg, L["pbvhits_trigger"]) or msg == L["pbvresist_trigger"] or msg == L["pbvimmune_trigger"] then
		self:Sync(syncName.volley)
	elseif string.find(msg, L["drainlife"]) then
		if msg == L["drainlifeyoustart_trigger"] then
			self:Sync(syncName.drain)
		elseif msg == L["drainlifeyouend_trigger"] then
			self:Sync(syncName.drainOver)
		elseif drainlifeotherstart and (UnitIsInRaidByName(drainlifeotherstart) or UnitIsPetByName(drainlifeotherstart)) then
			self:Sync(syncName.drain)
		elseif drainlifeotherend and drainlifeotherend ~= L["you"] and (UnitIsInRaidByName(drainlifeotherstart) or UnitIsPetByName(drainlifeotherstart)) then
			self:Sync(syncName.drainOver)
		end
	elseif string.find(msg, L["trigger_webs"]) then
		self:Sync(syncName.webs)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.spiders and self.db.profile.spider then
		self:Spiders()
	elseif sync == syncName.trollPhase and self.db.profile.phase then
		self:TrollPhase()
	elseif sync == syncName.spiderPhase and self.db.profile.phase then
		self:SpiderPhase()
	elseif sync == syncName.volley and self.db.profile.volley then
		self:Volley()
	elseif sync == syncName.drain and self.db.profile.drain then
		self:Drain()
	elseif sync == syncName.drainOver and self.db.profile.drain then
		self:DrainOver()
	elseif sync == syncName.webs and self.db.profile.webs then
		self:Webs()
	end
end

function module:Spiders()
	self:Message(L["spiders_message"], "Attention")
end

function module:TrollPhase()
	self:Message(L["trollphase"], "Attention")
end

function module:SpiderPhase()
	self:Message(L["spiderphase"], "Attention")
	self:RemoveBar(L["drainlife"])
	self:RemoveBar(L["pbv"])
end

function module:Volley()
	self:Bar(L["pbv"], 13, "Spell_Nature_CorrosiveBreath", true, "Green")
end

function module:Drain()
	self:Bar(L["drainlife"], 7, "Spell_Shadow_LifeDrain02", true, "Red")
	self:Message(L["drainlife_message"], "Attention")
end

function module:DrainOver()
	self:RemoveBar(L["drainlife"])
end

function module:Webs()
	if UnitClass("Player") == "Paladin" then
		self:WarningSign(icon.webs, 0.7)
	end
end
