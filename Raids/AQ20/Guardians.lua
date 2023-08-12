
local module, L = BigWigs:ModuleDeclaration("Anubisath Guardian", "Ruins of Ahn'Qiraj")

module.revision = 30009
module.enabletrigger = module.translatedName 
module.toggleoptions = {"reflect", "plagueyou", "plagueother", "icon", "thunderclap", "shadowstorm", "summon", "meteor", -1, "explode", "enrage"}
module.trashMod = true

L:RegisterTranslations("enUS", function() return {
	cmd = "Guardian",

	summon_cmd = "summon",
	summon_name = "Summon Alert",
	summon_desc = "Warn for summoned adds",

	reflect_cmd = "reflect",
	reflect_name = "Spell reflect alert",
	reflect_desc = "Shows bars for which reflect the Guardian has",
	
	plagueyou_cmd = "plagueyou",
	plagueyou_name = "Plague on you alert",
	plagueyou_desc = "Warn for plague on you",
	
	plagueother_cmd = "plagueother",
	plagueother_name = "Plague on others alert",
	plagueother_desc = "Warn for plague on others",
	
	thunderclap_cmd = "thunderclap",
	thunderclap_name = "Thunderclap Alert",
	thunderclap_desc = "Warn for Thunderclap",
	
	shadowstorm_cmd = "shadowstorm",
	shadowstorm_name = "Shadowstorm Alert",
	shadowstorm_desc = "Warn for Shadowstorm",
	
	icon_cmd = "icon",
	icon_name = "Place icon",
	icon_desc = "Place raid icon on the last plagued person (requires promoted or higher)",

	explode_cmd = "explode",
	explode_name = "Explode Alert",
	explode_desc = "Warn for incoming explosion",

	enrage_cmd = "enrage",
	enrage_name = "Enrage Alert",
	enrage_desc = "Warn for enrage",
	
	meteor_cmd = "meteor",
	meteor_name = "Meteor Alert",
	meteor_desc = "Warn for meteor",
	
	arcreftrigger = "Detect Magic is reflected",--OTHERPLAYER's Detect Magic is reflected back by Anubisath Guardian. CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE",
	arcrefwarn = "Fire & Arcane reflect",
	
	shareftrigger = "Anubisath Guardian is afflicted by Detect Magic.",--CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE
	sharefwarn = "Shadow & Frost reflect",
	--sharefbufficon = "Interface\\Icons\\Spell_Arcane_Blink",
		
	thunderclaptrigger = "Anubisath Guardian's Thunderclap hits",
	thunderclap_split = "Thunderclap -- 2 GROUPS!!",
	
	shadowstormtrigger = "Anubisath Guardian's Shadow Storm hits",
	shadowstorm_stay = "!!STACK IN MELEE RANGE!!",

	meteortrigger = "Anubisath Guardian's Meteor",
	meteorbar = "Meteor CD",
	meteorwarn = "Meteor!",
	
	explodetrigger = "Anubisath Guardian gains Explode.",
	explodewarn = "Exploding!",
	
	enragetrigger = "Anubisath Guardian gains Enrage.",
	enragewarn = "Enraged!",
	
	summonguardtrigger = "Anubisath Guardian casts Summon Anubisath Swarmguard.",
	summonguardwarn = "Swarmguard Summoned",
	summonwarriortrigger = "Anubisath Guardian casts Summon Anubisath Warrior.",
	summonwarriorwarn = "Warrior Summoned",
	
	plaguetrigger = "^([^%s]+) ([^%s]+) afflicted by Plague%.$",
	plaguewarn = " has the Plague!",
	plagueyouwarn = "You have the Plague!",
	plagueyou = "You",
	plagueare = "are",
	plague_onme = "Plague on ",
} end )

module.defaultDB = {
	bosskill = false,
	enrage = false,
}

local timer = {
	meteor = {8,13},
	explode = 6,
	arcref = 600,
	sharef = 600,
}

local icon = {
	plague = "Spell_Shadow_CurseOfTounges",
	meteor = "Spell_Fire_Fireball02",
	explode = "spell_fire_selfdestruct",
	arcref = "spell_arcane_portaldarnassus",
	sharef = "spell_arcane_portalundercity",
}

local syncName = {
	enrage = "GuardianEnrage"..module.revision,
	explode = "GuardianExplode"..module.revision,
	thunderclap = "GuardianThunderclap"..module.revision,
	summonguard = "GuardianSummonGuard"..module.revision,
	summonwarrior = "GuardianSummonWarrior"..module.revision,
	shadowstorm = "GuardianShadowstorm"..module.revision,
	meteor = "GuardianMeteor"..module.revision,
	arcref = "GuardianArcaneReflect"..module.revision,
	sharef = "GuardianShadowReflect"..module.revision,
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")
	
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")--Plague
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")--Plague
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")--Plague
	
	self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE", "Event")--EXPECTING this to be: YOUR Detect Magic is reflected back by Anubisath Guardian. CHAT_MSG_SPELL_SELF_DAMAGE",
	self:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE","Event")--OTHERPLAYER's Detect Magic is reflected back by Anubisath Guardian. CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE",
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE","Event")--Anubisath Guardian is afflicted by Detect Magic. CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE",
	
	self:ThrottleSync(10, syncName.enrage)
	self:ThrottleSync(10, syncName.explode)
	self:ThrottleSync(6, syncName.thunderclap)
	self:ThrottleSync(10, syncName.sharef)
	self:ThrottleSync(10, syncName.arcref)
end

function module:OnSetup()
	self.started = false
end

function module:OnEngage()
	bwGuardiansFirst = true
	bwGuardiansFirstArcRef = true
	bwGuardiansFirstShaRef = true
end

function module:OnDisengage()
	bwGuardiansFirst = true
	bwGuardiansFirstArcRef = true
	bwGuardiansFirstShaRef = true
end

function module:CHAT_MSG_COMBAT_HOSTILE_DEATH(msg)
	if msg == string.format(UNITDIESOTHER, boss) then
		self.core:ToggleModuleActive(self, false)
	end
end

function module:Event(msg)
	if msg == L["summonguardtrigger"] then
		self:Sync(syncName.summonguard)
	end
	if msg == L["summonwarriortrigger"] then
		self:Sync(syncName.summonwarrior)
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
	
	if string.find(msg, L["meteortrigger"]) then
		self:Sync(syncName.meteor)
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
		self:WarningSign(icon.explode, 3)
		self:Sound("RunAway")
	elseif sync == syncName.enrage and self.db.profile.enrage then
		self:Message(L["enragewarn"], "Important")
	
	elseif sync == syncName.meteor and self.db.profile.meteor then
		self:Meteor()
	elseif sync ==syncName.thunderclap and self.db.profile.thunderclap then
		self:Thunderclap()
	elseif sync == syncName.shadowstorm and self.db.profile.shadowstorm then
		self:ShadowStorm()
	
	elseif sync == syncName.summonguard and self.db.profile.summon then
		self:SummonGuard()
	elseif sync == syncName.summonwarrior and self.db.profile.summon then
		self:SummonWarrior()
	
	elseif sync == syncName.arcref and self.db.profile.reflect then
		self:ArcaneReflect()
	elseif sync == syncName.sharef and self.db.profile.reflect then
		self:ShadowReflect()
	end
end

function module:ArcaneReflect()
	if bwGuardiansFirstArcRef == true then
		self:Bar(L["arcrefwarn"], timer.arcref, icon.arcref, true, "red")
		bwGuardiansFirstArcRef = false
	end
end

function module:ShadowReflect()
	if bwGuardiansFirstShaRef == true then 
		self:Bar(L["sharefwarn"], timer.sharef, icon.sharef, true, "blue")
		bwGuardiansFirstShaRef = false
	end
end



function module:Meteor()
	self:IntervalBar(L["meteorbar"], timer.meteor[1], timer.meteor[2], icon.meteor, true, "cyan")
	self:Message(L["meteorwarn"], "Important")
end

function module:Thunderclap()
	if bwGuardiansFirst == true then
		self:Message(L["thunderclap_split"], "Attention")
		bwGuardiansFirst = false
	end
end

function module:ShadowStorm()
	if bwGuardiansFirst == true then
		self:Message(L["shadowstorm_stay"], "Attention")
		bwGuardiansFirst = false
	end
end



function module:SummonGuard()
	self:Message(L["summonguardwarn"], "Attention")
end

function module:SummonWarrior()
	self:Message(L["summonwarriorwarn"], "Attention")
end
