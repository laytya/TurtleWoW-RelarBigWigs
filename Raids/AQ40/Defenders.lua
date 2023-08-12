
local module, L = BigWigs:ModuleDeclaration("Anubisath Defender", "Ahn'Qiraj")

module.revision = 30009
module.enabletrigger = module.translatedName
module.toggleoptions = {"reflect", "plagueyou", "plagueother", "icon", "thunderclap", "shadowstorm", -1, "explode", "enrage"}
module.trashMod = true

L:RegisterTranslations("enUS", function() return {
	cmd = "Defender",

	plagueyou_cmd = "plagueyou",
	plagueyou_name = "Plague on you alert",
	plagueyou_desc = "Warn if you got the Plague",
	
	reflect_cmd = "reflect",
	reflect_name = "Spell reflect alert",
	reflect_desc = "Shows bars for which reflect the Defender has",

	plagueother_cmd = "plagueother",
	plagueother_name = "Plague on others alert",
	plagueother_desc = "Warn if others got the Plague",

	explode_cmd = "explode",
	explode_name = "Explode Alert",
	explode_desc = "Warn for Explode",

	enrage_cmd = "enrage",
	enrage_name = "Enrage Alert",
	enrage_desc = "Warn for Enrage",

	summon_cmd = "summon",
	summon_name = "Summon Alert",
	summon_desc = "Warn for add summons",

	icon_cmd = "icon",
	icon_name = "Place icon",
	icon_desc = "Place raid icon on the last plagued person (requires promoted or higher)",
	
	thunderclap_cmd = "thunderclap",
	thunderclap_name = "Thunderclap Alert",
	thunderclap_desc = "Warn for Thunderclap",
	
	shadowstorm_cmd = "shadowstorm",
	shadowstorm_name = "Shadowstorm Alert",
	shadowstorm_desc = "Warn for Shadowstorm",
	
	thunderclaptrigger = "Anubisath Defender's Thunderclap hits",
	thunderclap_split = "Thunderclap -- 2 GROUPS!!",

	shadowstormtrigger = "Anubisath Defender's Shadow Storm hits",
	shadowstorm_stay = "!!STACK IN MELEE RANGE!!",

	arcreftrigger = "Detect Magic is reflected",--OTHERPLAYER's Detect Magic is reflected back by Anubisath Guardian. CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE",
	arcrefwarn = "Fire & Arcane reflect",
	
	shareftrigger = "Anubisath Guardian is afflicted by Detect Magic.",--CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE
	sharefwarn = "Shadow & Frost reflect",
	--sharefbufficon = "Interface\\Icons\\Spell_Arcane_Blink",
	
	explodetrigger = "Anubisath Defender gains Explode.",
	explodewarn = "Exploding!",

	enragetrigger = "Anubisath Defender gains Enrage.",
	enragewarn = "Enraged!",

	summonguardtrigger = "Anubisath Defender casts Summon Anubisath Swarmguard.",
	summonguardwarn = "Swarmguard Summoned",
	summonwarriortrigger = "Anubisath Defender casts Summon Anubisath Warrior.",
	summonwarriorwarn = "Warrior Summoned",

	plaguetrigger = "^([^%s]+) ([^%s]+) afflicted by Plague%.$",
	plaguewarn = " has the Plague!",
	plagueyouwarn = "You have the plague!",
	plagueyou = "You",
	plagueare = "are",
	plague_onme = "Plague on ",
} end )

module.defaultDB = {
	enrage = false,
	bosskill = nil,
}

local timer = {
	explode = 6,
	arcref = 600,
	sharef = 600,
}

local icon = {
	explode = "spell_fire_selfdestruct",
	plague = "Spell_Shadow_CurseOfTounges",
	arcref = "spell_arcane_portaldarnassus",
	sharef = "spell_arcane_portalundercity",
}

local syncName = {
	enrage = "DefenderEnrage"..module.revision,
	explode = "DefenderExplode"..module.revision,
	thunderclap = "DefenderThunderclap"..module.revision,
	shadowstorm = "DefenderShadowstorm"..module.revision,
	arcref = "DefenderArcaneReflect"..module.revision,
	sharef = "DefenderShadowReflect"..module.revision,
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")--Explosion and Enrage
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "Event")--adds summon
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")--plague
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")--plague
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")--plague
	
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")--Thunderclap and Shadowstorm
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")--Thunderclap and Shadowstorm
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")--Thunderclap and Shadowstorm

	self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE", "Event")--EXPECTING this to be: YOUR Detect Magic is reflected back by Anubisath Guardian. CHAT_MSG_SPELL_SELF_DAMAGE",
	self:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE","Event")--OTHERPLAYER's Detect Magic is reflected back by Anubisath Guardian. CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE",
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE","Event")--Anubisath Guardian is afflicted by Detect Magic. CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE",
	
	self:ThrottleSync(10, syncName.enrage)
	self:ThrottleSync(10, syncName.explode)
	self:ThrottleSync(6, syncName.thunderclap)
	self:ThrottleSync(6, syncName.shadowstorm)
	self:ThrottleSync(10, syncName.sharef)
	self:ThrottleSync(10, syncName.arcref)
end

function module:OnSetup()
end

function module:OnEngage()
	bwDefendersFirst = true
	bwDefendersFirstArcRef = true
	bwDefendersFirstShaRef = true
end

function module:OnDisengage()
	bwDefendersFirst = true
	bwDefendersFirstArcRef = true
	bwDefendersFirstShaRef = true
end

function module:Event(msg)
	if msg == L["summonguardtrigger"] and self.db.profile.summon then
		self:Message(L["summonguardwarn"], "Attention")
	end
	if msg == L["summonwarriortrigger"] and self.db.profile.summon then
		self:Message(L["summonwarriorwarn"], "Attention")
	end
	
	if string.find(msg, L["plaguetrigger"]) then
		local _,_, pplayer, ptype = string.find(msg, L["plaguetrigger"])
		if pplayer then
			if self.db.profile.plagueyou and pplayer == L["plagueyou"] then
				SendChatMessage("Plague on "..UnitName("player").."!","SAY")
				self:Message(L["plagueyouwarn"], "Personal")
				self:Message(UnitName("player") .. L["plaguewarn"])
				self:WarningSign(icon.plague, 5)
				self:Sound("RunAway")
			elseif self.db.profile.plagueother then
				self:Message(pplayer .. L["plaguewarn"], "Attention")
				self:TriggerEvent("BigWigs_SendTell", pplayer, L["plagueyouwarn"])
			end
			if self.db.profile.icon then
				self:TriggerEvent("BigWigs_SetRaidIcon", pplayer)
			end
		end
	end
	
	if string.find(msg, L["thunderclaptrigger"]) then
		self:Sync(syncName.thunderclap)
	end
	if string.find(msg, L["shadowstormtrigger"]) then
		self:Sync(syncName.shadowstorm)
	end
	
	if msg == L["explodetrigger"] then
		self:Sync(syncName.explode)
	end
	if msg == L["enragetrigger"] then
		self:Sync(syncName.enrage)
	end
	
	if string.find(msg, L["arcreftrigger"]) then
		self:Sync(syncName.arcref)
	end
	if msg == L["shareftrigger"] then
		self:Sync(syncName.sharef)		
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.explode and self.db.profile.explode then
		self:Message(L["explodewarn"], "Important")
		self:Bar(L["explodewarn"], timer.explode, icon.explode, true, "Black")
		self:WarningSign(icon.explode, timer.explode)
		self:Sound("RunAway")
	elseif sync == syncName.enrage and self.db.profile.enrage then
		self:Message(L["enragewarn"], "Important")
	elseif sync == syncName.thunderclap and self.db.profile.thunderclap then
		self:Thunderclap()
	elseif sync == syncName.shadowstorm and self.db.profile.shadowstorm then
		self:Shadowstorm()
	elseif sync == syncName.arcref and self.db.profile.reflect then
		self:ArcaneReflect()
	elseif sync == syncName.sharef and self.db.profile.reflect then
		self:ShadowReflect()
	end
end

function module:Thunderclap()
	if bwDefendersFirst == true then
		self:Message(L["thunderclap_split"], "Attention")
		bwDefendersFirst = false
	end
end

function module:Shadowstorm()
	if bwDefendersFirst == true then
		self:Message(L["shadowstorm_stay"], "Attention")
		bwDefendersFirst = false
	end
end

function module:ArcaneReflect()
	if bwDefendersFirstArcRef == true then
		self:Bar(L["arcrefwarn"], timer.arcref, icon.arcref, true, "red")
		bwDefendersFirstArcRef = false
	end
end

function module:ShadowReflect()
	if bwDefendersFirstShaRef == true then 
		self:Bar(L["sharefwarn"], timer.sharef, icon.sharef, true, "blue")
		bwDefendersFirstShaRef = false
	end
end
