
local module, L = BigWigs:ModuleDeclaration("Gluth", "Naxxramas")

module.revision = 20007
module.enabletrigger = module.translatedName
module.toggleoptions = {"frenzy", "fear", "decimate", "enrage", "bosskill", "zombies"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Gluth",

	fear_cmd = "fear",
	fear_name = "Fear Alert",
	fear_desc = "Warn for fear",

	frenzy_cmd = "frenzy",
	frenzy_name = "Frenzy Alert",
	frenzy_desc = "Warn for frenzy",

	enrage_cmd = "enrage",
	enrage_name = "Enrage Timer",
	enrage_desc = "Warn for Enrage",

	decimate_cmd = "decimate",
	decimate_name = "Decimate Alert",
	decimate_desc = "Warn for Decimate",
	
	frenzy_trigger = "%s goes into a frenzy!",
	frenzygain_trigger = "Gluth gains Frenzy.",
	frenzygain_trigger2 = "Gluth goes into a frenzy!",
	frenzy_warn = "Frenzy Alert!",
	frenzy_message = "Frenzy! Tranq now!",
	frenzy_bar = "Frenzy",
	
	frenzyend_trigger = "Frenzy fades from Gluth.",
	frenzy_Nextbar = "Next Frenzy",
	
	berserk_trigger = "gains Berserk",
	
	enragewarn = "ENRAGE!",
	enragebartext = "Enrage",
	enrage_warn_90 = "Enrage in 90 seconds",
	enrage_warn_30 = "Enrage in 30 seconds",
	enrage_warn_10 = "Enrage in 10 seconds",

	starttrigger = "devours all nearby zombies!",
	startwarn = "Gluth Engaged! ~1:45 till Decimate!",
	
	decimatesoonwarn = "Decimate Soon!",
	decimatebar = "Decimate Zombies",

	zombies_cmd = "zombies",
	zombies_name = "Zombie Spawn",
	zombies_desc = "Shows timer for zombies",
	zombiebar = "Next Zombie - %d",
	
	fear_trigger = "by Terrifying Roar.",
	fear_warn_5 = "5 second until AoE Fear!",
	fear_warn = "AoE Fear alert - 20 seconds till next!",
	fear_bar = "AoE Fear",
} end )

L:RegisterTranslations("esES", function() return {
	--cmd = "Gluth",

	--fear_cmd = "fear",
	fear_name = "Alerta de Miedo",
	fear_desc = "Avisa para Miedo",

	--frenzy_cmd = "frenzy",
	frenzy_name = "Alerta de Frenesí",
	frenzy_desc = "Avisa para Frenesí",

	--enrage_cmd = "enrage",
	enrage_name = "Temporizador de Enfurecer",
	enrage_desc = "Avisa para Enfurecer",

	--decimate_cmd = "decimate",
	decimate_name = "Alerta de Diezmar",
	decimate_desc = "Avisa para Diezmar",

	frenzy_trigger = "¡%s entra frenesí!",
	berserk_trigger = "gana Rabia",
	fear_trigger = "de Clamor aterrorizador.",
	starttrigger = "¡devora todos los zombis cercanos!",

	frenzy_warn = "¡Alerta de Frenesí!",
	fear_warn_5 = "5 segundos hasta Miedo!",
	fear_warn = "¡Alerta de Miedo - 20 segundos hasta el próximo!",

	enragewarn = "¡ENFURECER!",
	enragebartext = "Enfurecer",
	enrage_warn_90 = "Enfurecer en 90 segundos",
	enrage_warn_30 = "Enfurecer en 30 segundos",
	enrage_warn_10 = "Enfurecer en 10 segundos",

	startwarn = "¡Entrando en combate con Gluth! ~1:45 hasta Diezmar!",
	decimatesoonwarn = "¡Diezmar Pronto!",
	decimatebar = "Diezmar Zombi",

	--zombies_cmd = "zombies",
	zombies_name = "Zombi",
	zombies_desc = "Muestra temporizador para zombis",
	zombiebar = "Próximo Zombi - %d",

	fear_bar = "Miedo",

	testtrigger = "testtrigger";

	frenzygain_trigger = "Gluth gana Frenesí.",
	frenzygain_trigger2 = "Gluth entra frenzy!",
	frenzyend_trigger = "Frenesí desaparece de Gluth.",
	frenzy_message = "¡Frensí! Disparo tranquilizante ahora!",
	frenzy_bar = "Frenesí",
	frenzy_Nextbar = "Próximo Frenesí",
} end )

local timer = {
	decimateInterval = 105,
	zombie = 6,
	enrage = 330,
	fear = 20,
	frenzy = 10,
	firstFrenzy = 10,
}
local icon = {
	zombie = "Ability_Seal",
	enrage = "Spell_Shadow_UnholyFrenzy",
	fear = "Spell_Shadow_PsychicScream",
	decimate = "INV_Shield_01",
	tranquil = "Spell_Nature_Drowsy",
	frenzy = "Ability_Druid_ChallangingRoar",
}
local syncName = {
	frenzy = "GluthFrenzyStart"..module.revision,
	frenzyOver = "GluthFrenzyEnd"..module.revision,
}

local lastFrenzy = 0
local _, playerClass = UnitClass("player")

module:RegisterYellEngage(L["starttrigger"])

function module:OnEnable()
	self:RegisterEvent("BigWigs_Message")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Frenzy")
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER", "Frenzy")
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE", "Frenzy")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Enrage")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Fear")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Fear")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Fear")

	self:ThrottleSync(5, syncName.frenzy)
end

function module:OnSetup()
	self.started = nil
	self.prior = nil
	self.zomnum = 1
	lastFrenzy = 0
end

function module:OnEngage()
	if self.db.profile.decimate then
		self:Message(L["startwarn"], "Attention")
		self:Decimate()
		self:ScheduleRepeatingEvent( "bwgluthdecimate", self.Decimate, timer.decimateInterval, self )
	end
	if self.db.profile.zombies then
		self.zomnum = 1
		self:Bar(string.format(L["zombiebar"],self.zomnum), timer.zombie, icon.zombie, true, "Green")
		self.zomnum = self.zomnum + 1
		self:Zombie()
	end
	if self.db.profile.enrage then
		self:Bar(L["enragebartext"], timer.enrage, icon.enrage, true, "Cyan")
		self:DelayedMessage(timer.enrage - 90, L["enrage_warn_90"], "Attention")
		self:DelayedMessage(timer.enrage - 30, L["enrage_warn_30"], "Attention")
		self:DelayedMessage(timer.enrage - 10, L["enrage_warn_10"], "Urgent")
	end
	if self.db.profile.frenzy then
		self:Bar(L["frenzy_Nextbar"], timer.firstFrenzy, icon.frenzy, true, "white")
	end
	if self.db.profile.fear then
		self:Bar(L["fear_bar"], timer.fear, icon.fear)
	end
end

function module:OnDisengage()
end

function module:Zombies()
	self:Bar(string.format(L["zombiebar"],self.zomnum), timer.zombie, icon.zombie, true, "Green")

	if self.zomnum <= 10 then
		self.zomnum = self.zomnum + 1
	elseif self.zomnum > 10 then
		self:CancelScheduledEvent("bwgluthzbrepop")
		self:RemoveBar(string.format(L["zombiebar"], self.zomnum ))
		self.zomnum = 1
	end
end

function module:Zombie()
	self:ScheduleRepeatingEvent("bwgluthzbrepop", self.Zombies, timer.zombie, self)
end

function module:Frenzy( msg )
	if msg == L["frenzygain_trigger"] or msg == L["frenzygain_trigger2"] then
		self:Sync(syncName.frenzy)
	elseif msg == L["frenzyend_trigger"] then
		self:Sync(syncName.frenzyOver)
	end
end

function module:Fear( msg )
	if self.db.profile.fear and not self.prior and string.find(msg, L["fear_trigger"]) then
		self:Message(L["fear_warn"], "Important")
		self:Bar(L["fear_bar"], timer.fear, icon.fear, true, "Blue")
		self:DelayedMessage(timer.fear - 5, L["fear_warn_5"], "Urgent")
		self.prior = true
	end
end

function module:Decimate()
	if self.db.profile.decimate then
		self:Bar(L["decimatebar"], timer.decimateInterval, icon.decimate, true, "Black")
		self:DelayedMessage(timer.decimateInterval - 5, L["decimatesoonwarn"], "Urgent")
	end
	if self.db.profile.zombies then
		self.zomnum = 1
		self:Bar(string.format(L["zombiebar"],self.zomnum), timer.zombie, icon.zombie, true, "Green")
		self.zomnum = self.zomnum + 1
		self:Zombie()
	end
end

function module:Enrage( msg )
	if string.find(msg, L["berserk_trigger"]) then
		if self.db.profile.enrage then
			self:Message(L["enragewarn"], "Important")
		end
	end
end

function module:BigWigs_Message(text)
	if text == L["fear_warn_5"] then self.prior = nil end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.frenzy and self.db.profile.frenzy then
		self:Message(L["frenzy_message"], "Important", nil, true, "Alert")
		self:Bar(L["frenzy_bar"], timer.frenzy, icon.frenzy, true, "red")
		if playerClass == "HUNTER" then
			self:WarningSign(icon.tranquil, timer.frenzy, true)
		end
		lastFrenzy = GetTime()
	elseif sync == syncName.frenzyOver and self.db.profile.frenzy then
		self:RemoveBar(L["frenzy_bar"])
		self:RemoveWarningSign(icon.tranquil, true)
		if lastFrenzy ~= 0 then
			local NextTime = (lastFrenzy + timer.frenzy) - GetTime()
			self:Bar(L["frenzy_Nextbar"], NextTime, icon.frenzy, true, "white")
		end
	end
end
