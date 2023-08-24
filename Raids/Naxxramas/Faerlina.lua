
local module, L = BigWigs:ModuleDeclaration("Grand Widow Faerlina", "Naxxramas")

module.revision = 30010
module.enabletrigger = module.translatedName
module.toggleoptions = {"mc", "sounds", "bigicon", "raidSilence", "poison", "silence", "enrage", "rain", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Faerlina",

	silence_cmd = "silence",
	silence_name = "Silence Alert",
	silence_desc = "Warn for silence",

	bigicon_cmd = "bigicon",
	bigicon_name = "BigIcon MC and Enrage Alert",
	bigicon_desc = "BigIcon alerts when priest must MC and when the boss goes Enraged",

	sounds_cmd = "sounds",
	sounds_name = "Sound MC and Enrage Alert",
	sounds_desc = "Sound alert when priest must MC and when the boss goes Enraged",
	
	mc_cmd = "mc",
	mc_name = "MC timer bars",
	mc_desc = "Timer bars for Worshipper MindControls",
	
	enrage_cmd = "enrage",
	enrage_name = "Enrage Alert",
	enrage_desc = "Warn for Enrage",

	rain_cmd = "rain",
	rain_name = "Rain of Fire Alert",
	rain_desc = "Warn when you are standing in Rain of Fire",
	
	raidSilence_cmd = "raidSilence",
	raidSilence_name = "Raid members Silenced Alert",
	raidSilence_desc = "Warn when raid members are silenced",

	poison_cmd = "poison",
	poison_name = "Poison Volley Alert",
	poison_desc = "Warns shamans on Poison Volley",
	
	trigger_start1 = "Kneel before me, worm!",
	trigger_start2 = "Slay them in the master's name!",
	trigger_start3 = "You cannot hide from me!",
	trigger_start4 = "Run while you still can!",

	trigger_rain = "You suffer (.+) Fire damage from Grand Widow Faerlina's Rain of Fire.",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE --string find cause could be a partial absorb
	trigger_rain2 = "You absorb Grand Widow Faerlina's Rain of Fire.",--CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE
	
	trigger_poison = "is afflicted by Poison Bolt Volley",--CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	
	trigger_raidSilence = "is afflicted by Silence.",--CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE
	bar_raidSilence = "Raid member Silenced",
	
	trigger_mcGain = "(.*) gains Mind Control.",--CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS
	--trigger_mcGain = "Naxxramas Worshipper is afflicted by Mind Control",--CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE
	mc_bar = " MC",
	
	trigger_worshipperDies = "Naxxramas Worshipper dies.",--CHAT_MSG_COMBAT_FRIENDLY_DEATH
	
	trigger_mcFade = "Mind Control fades from (.*).",--CHAT_MSG_SPELL_AURA_GONE_OTHER
	--trigger_mcFade = "Naxxramas Worshipper begins to perform Widow's Embrace",--CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF
	--trigger_mcSuccess = "Widow's Embrace fades from Naxxramas Worshipper.",--CHAT_MSG_SPELL_AURA_GONE_OTHER
	--trigger_embrace = "Grand Widow Faerlina gains Widow's Embrace.",--CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	msg_silencedHalf = "Silenced before enrage! next in 30 seconds",
	msg_silenceZero = "Silenced WAY early! No delay on Enrage",
	bar_silence = "Boss Silenced",
	
	trigger_enrage = "Grand Widow Faerlina gains Enrage.",--CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS
	msg_enrageGain = "Enrage!",
	bar_enrageGain = "Boss is ENRAGED!",
	
	trigger_enrageFade = "Enrage fades from Grand Widow Faerlina.",--CHAT_MSG_SPELL_AURA_GONE_OTHER
	msg_silencedEnrageFull = "Enrage silenced! next in 61 seconds",
	
	msg_enrageSoon = "Enrage in 10 seconds",
	
	bar_enrageCD = "Enrage CD",
	
	trigger_dispel = "(.*) casts Dispel Magic on Naxxramas Worshipper.",--CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF
	msg_dispelCast = " Dispelled a Worshipper! Don't Dispel MC!",
} end )

L:RegisterTranslations("esES", function() return {
	--cmd = "Faerlina",

	--silence_cmd = "silence",
	silence_name = "Alerta de Silencio",
	silence_desc = "Avisa para silencio",

	--enrage_cmd = "enrage",
	enrage_name = "Alerta de Enfurecer",
	enrage_desc = "Avisa para Enfurecer",

	trigger_start1 = "¡MUERE... o arrodíllate ante mí!",
	trigger_start2 = "¡Matadlos en el nombre del maestro!",
	trigger_start3 = "¡No puedes esconderte de mí!",
	trigger_start4 = "¡Corred mientras podáis!",

	silencetrigger = "Grand Viuda Faerlina sufre de Abrazo de la viuda.", -- EDITED it affects her too.
	enragetrigger = "Grand Viuda Faerlina gana Enfurecer.",
	enragefade = "Enfurecer desaparece de Grand Viuda Faerlina.",

	silencewarn = "¡Silencio! Demora Enfurecer!",
	silencewarnnodelay = "¡Silencio!",
	silencewarn5sec = "Silencio desaparece en 5 secgundos",

	enragebar = "Enfurecer",
	silencebar = "Silencio",

	--rain_cmd = "rain",
	rain_name = "Alerta de Lluvia de Fuego",
	rain_desc = "Avisa si estás en Lluvia de Fuego",
	trigger_rain = "Sufres de Lluvia de Fuego",
} end )

local timer = {
	silencedEnrage = 61,
	silencedWithoutEnrage = 30,
	
	silence = 30,
	raidSilence = 8,
	mc = 60,
}
local icon = {
	enrage = "Spell_Shadow_UnholyFrenzy",
	silence = "Spell_Holy_Silence",
	rain = "Spell_Shadow_RainOfFire",
	poison = "spell_nature_poisoncleansingtotem",
	mc = "spell_shadow_shadowworddominate",
}
local syncName = {
	enrage = "FaerlinaEnrage"..module.revision,
	enrageFade = "FaerlinaEnrageFade"..module.revision,
	raidSilence = "FaerlinaRaidSilence"..module.revision,
	poison = "FaerlinaPoison"..module.revision,
	mc = "FaerlinaMc"..module.revision,
	mcEnd = "FaerlinaMcEnd"..module.revision,
	worshipperDies = "FaerlinaWorshipperDies"..module.revision,
	dispel = "FaerlinaDispel"..module.revision,
}

bwWorshipperDiesTime = 0
bwFaerlinaEnragedFadedTime = 0
bwFaerlinaIsEnraged = false

module:RegisterYellEngage(L["trigger_start1"])
module:RegisterYellEngage(L["trigger_start2"])
module:RegisterYellEngage(L["trigger_start3"])
module:RegisterYellEngage(L["trigger_start4"])

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")--Rain of Fire
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")--Poison, RaidSilence
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")--Poison, RaidSilence
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS", "Event")--mcGain
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS", "Event")--mcGain
	self:RegisterEvent("CHAT_MSG_COMBAT_FRIENDLY_DEATH", "Event")--WorshipperDies
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Event")--mcFade, enrageFade
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")--mcFade
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")--enrage
	self:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF", "Event")--dispel
	
	self:ThrottleSync(5, syncName.enrage)
	self:ThrottleSync(5, syncName.enrageFade)
	self:ThrottleSync(5, syncName.raidSilence)
	self:ThrottleSync(5, syncName.poison)
	self:ThrottleSync(2, syncName.mc)
	self:ThrottleSync(2, syncName.mcEnd)
	self:ThrottleSync(1, syncName.worshipperDies)
	self:ThrottleSync(1, syncName.dispel)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
	bwWorshipperDiesTime = 0
	bwFaerlinaEnragedFadedTime = GetTime()
	bwFaerlinaIsEnraged = false
	
	if self.db.profile.enrage then
		self:DelayedMessage(timer.silencedEnrage - 11, L["msg_enrageSoon"], "Urgent", nil, nil)
		self:Bar(L["bar_enrageCD"], timer.silencedEnrage - 1, icon.enrage, true, "red")
	end
	
	if UnitClass("player") == "Priest" and self.db.profile.bigicon then
		self:DelayedWarningSign(timer.silencedEnrage - 12, icon.mc, 0.7)
	end
	if UnitClass("player") == "Priest" and self.db.profile.sounds then
		self:DelayedSound(timer.silencedEnrage - 12, "Info")
	end
end

function module:OnDisengage()
end



function module:Event(msg)
	if (msg == L["trigger_rain2"] or string.find(msg, L["trigger_rain"])) and self.db.profile.rain then
		self:WarningSign(icon.rain, 0.7)
	end
	if string.find(msg, L["trigger_poison"]) then
		self:Sync(syncName.poison)
	end
	if string.find(msg, L["trigger_raidSilence"]) then
		self:Sync(syncName.raidSilence)
	end
	if string.find(msg, L["trigger_mcGain"]) then
		local _,_, mcGainPriest, _ = string.find(msg, L["trigger_mcGain"])
		self:Sync(syncName.mc.." "..mcGainPriest)
	end
	if msg == L["trigger_worshipperDies"] then
		self:Sync(syncName.worshipperDies)
	end
	if string.find(msg, L["trigger_mcFade"]) then
		local _,_, mcEndPriest, _ = string.find(msg, L["trigger_mcFade"])
		self:Sync(syncName.mcEnd.." "..mcEndPriest)
	end
	if string.find(msg, L["trigger_enrage"]) then
		self:Sync(syncName.enrage)
	end
	if msg == L["trigger_enrageFade"] then
		self:Sync(syncName.enrageFade)
	end
	if string.find(msg, L["trigger_dispel"]) then
		local _,_, dispeller, _ = string.find(msg, L["trigger_dispel"])
		self:Sync(syncName.dispel.." "..dispeller)
	end
end



function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.poison and self.db.profile.poison then
		self:Poison()
	elseif sync == syncName.raidSilence and self.db.profile.raidSilence then
		self:RaidSilence()
	elseif sync == syncName.mc and self.db.profile.mc then
		self:Mc(rest)
	elseif sync == syncName.mcEnd and self.db.profile.mc then
		self:McEnd(rest)
	elseif sync == syncName.enrage then
		self:Enrage()
	elseif sync == syncName.enrageFade then
		self:EnrageFade()
	elseif sync == syncName.worshipperDies then
		self:WorshipperDies()
	elseif sync == syncName.dispel then
		self:Dispel(rest)
	end
end



function module:Poison()
	if UnitClass("player") == "Shaman" then
		self:WarningSign(icon.poison, 0.7)
	end
end

function module:RaidSilence()
	self:Bar(L["bar_raidSilence"], timer.raidSilence, icon.silence, true, "blue")
end

function module:Mc(rest)
	self:Bar(rest..L["mc_bar"], timer.mc, icon.mc, true, "black")
end

function module:McEnd(rest)
	self:RemoveBar(rest..L["mc_bar"])
	
	--Determine if the Mc faded less than 1 second after a worshipper died, if yes, then is probably a successful silence :: no trigger
	--GetTime() < (bwWorshipperDiesTime + 1) 
	
	--WAY Too Soon, LESS THAN 30sec after silence -->> time to enrage is not changed
	if bwFaerlinaIsEnraged == false and (GetTime() < (bwFaerlinaEnragedFadedTime + 30)) and (GetTime() < (bwWorshipperDiesTime + 1)) then
		self:RemoveBar(L["bar_enrageGain"])
		if self.db.profile.silence then
			self:Message(L["msg_silenceZero"], "Urgent")
		end

	
	--Too Soon but still silences, MORE THAN 30, LESS THAN 60sec after silence -->> time to enrage is 30sec
	elseif bwFaerlinaIsEnraged == false and (GetTime() < (bwFaerlinaEnragedFadedTime + 60)) and (GetTime() < (bwWorshipperDiesTime + 1)) then 
		self:RemoveBar(L["bar_enrageGain"])
		self:RemoveBar(L["bar_enrageCD"])
		
		if self.db.profile.silence then
			self:Bar(L["bar_silence"], timer.silence, icon.silence, true, "white")
			self:Message(L["msg_silencedHalf"], "Urgent")
		end
		
		if self.db.profile.enrage then
			self:Bar(L["bar_enrageCD"], timer.silencedWithoutEnrage, icon.enrage, true, "red")
			self:DelayedMessage(timer.silencedWithoutEnrage - 10, L["msg_enrageSoon"], "Urgent", nil, nil)
		end
		if UnitClass("player") == "Priest" and self.db.profile.bigicon then
			self:DelayedWarningSign(timer.silencedWithoutEnrage - 10, icon.mc, 0.7)
		end
		if UnitClass("player") == "Priest" and self.db.profile.sounds then
			self:DelayedSound(timer.silencedWithoutEnrage - 10, "Info")
		end
	end
end

function module:Enrage()
	self:RemoveBar(L["bar_enrageCD"])
	self:CancelDelayedMessage(L["msg_enrageSoon"])
	
	bwFaerlinaIsEnraged = true
	
	if self.db.profile.enrage then
		self:Message(L["msg_enrageGain"], nil, nil, false)
		self:Bar(L["bar_enrageGain"], timer.silencedEnrage, icon.enrage, true, "red")
		
		if (UnitClass("player") == "Warrior" or UnitClass("player") == "Priest") and self.db.profile.bigicon then
			self:WarningSign(icon.enrage, 0.7)
		end
		if (UnitClass("player") == "Warrior" or UnitClass("player") == "Priest") and self.db.profile.sounds then
			self:Sound("Info")
		end
	end
end

function module:EnrageFade()
	bwFaerlinaEnragedFadedTime = GetTime()
	bwFaerlinaIsEnraged = false
	
	--Silence DURING an enrage, -->> time to enrage is 60(61)sec
	self:RemoveBar(L["bar_enrageGain"])
	self:RemoveBar(L["bar_enrageCD"])
	
	if self.db.profile.silence then
		self:Bar(L["bar_silence"], timer.silence, icon.silence, true, "white")
		self:Message(L["msg_silencedEnrageFull"], "Urgent")
	end
	
	if self.db.profile.enrage then
		self:Bar(L["bar_enrageCD"], timer.silencedEnrage, icon.enrage, true, "red")
		self:DelayedMessage(timer.silencedEnrage - 10, L["msg_enrageSoon"], "Urgent", nil, nil)
	end
	if UnitClass("player") == "Priest" and self.db.profile.bigicon then
		self:DelayedWarningSign(timer.silencedEnrage - 10, icon.mc, 0.7)
	end
	if UnitClass("player") == "Priest" and self.db.profile.sounds then
		self:DelayedSound(timer.silencedEnrage - 10, "Info")
	end
end

function module:WorshipperDies()
	bwWorshipperDiesTime = GetTime()
end

function module:Dispel(rest)
	self:Message(rest..L["msg_dispelCast"], "Urgent")
end
