
local module, L = BigWigs:ModuleDeclaration("Anub'Rekhan", "Naxxramas")

module.revision = 30008
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

	starttrigger1 = "Just a little taste...",
	starttrigger2 = "Yes, run! It makes the blood pump faster!",
	starttrigger3 = "There is no way out.",

	etrigger = "gains Enrage.",
	enragewarn = "Crypt Guard Enrage - Stun + Traps!",

	gaintrigger = "Anub'Rekhan gains Locust Swarm.",
	gainendwarn = "Locust Swarm ended!",
	gainnextwarn = "Next Locust Swarm in ~90 sec",
	gainwarn10sec = "~10 Seconds until Locust Swarm",
	gainincbar = "Possible Locust Swarm",
	gainbar = "Locust Swarm",

	casttrigger = "Anub'Rekhan begins to cast Locust Swarm.",
	castwarn = "Incoming Locust Swarm!",

	impale_cmd = "impale",
	impale_name = "Impale Alert",
	impale_desc = "Warns for Impale",
	impaletrigger = "Anub'Rekhan begins to cast Impale", -- todo
	impalebar = "Next Impale",
	impalesay = "Impale on me",

} end )

L:RegisterTranslations("esES", function() return {
	--cmd = "Anubrekhan",

	--locust_cmd = "locust",
	locust_name = "Alerta de Enjambre de langostas",
	locust_desc = "Avisa para Enjambre de langostas",

	--enrage_cmd = "enrage",
	enrage_name = "Alerta de Enfurecer de la Guardia de la cripta",
	enrage_desc = "Avisa para Enfurecer",

	starttrigger1 = "Sólo un bocado...",
	starttrigger2 = "¡Eso, corrid! Así la sangre singula más rápido!", -- singula?
	starttrigger3 = "No hay salida.",

	etrigger = "gana Enfurecer.",
	enragewarn = "¡Enfurecer Guardia de la cripta - Aturde + Trampas!",

	gaintrigger = "Anub'Rekhan gana Enjambre de langostas.",
	gainendwarn = "¡Se termina Enjambre de langostas!",
	gainnextwarn = "Próximo Enjambre de langostas en ~90 segundos",
	gainwarn10sec = "~10 segundos hasta Enjambre de langostas",
	gainincbar = "Enjambre de langostas Posible",
	gainbar = "Enjambre de langostas",

	casttrigger = "Anub'Rekhan comienza a lanzar Enjambre de langostas.",
	castwarn = "¡Enjambre de langostas entrante!",

	--impale_cmd = "impale",
	impale_name = "Alerta de Clavar",
	impale_desc = "Avisa para Clavar",
	impaletrigger = "Anub'Rekhan comienza a lanzar Clavar", -- todo
	impalebar = "Próximo Clavar",
	impalesay = "Clavar en mí",

} end )

local timer = {
	firstLocustSwarm = {80,120},
	locustSwarmInterval = {90,110},
	locustSwarmDuration = 20,
	locustSwarmCastTime = 3,
	impale = {12,18},
}
local icon = {
	locust = "Spell_Nature_InsectSwarm",
	impale = "ability_backstab",
}
local syncName = {
	locustCast = "AnubLocustInc"..module.revision,
	locustGain = "AnubLocustSwarm"..module.revision,
	impale = "AnubImpale"..module.revision,
}

module:RegisterYellEngage(L["starttrigger1"])
module:RegisterYellEngage(L["starttrigger2"])
module:RegisterYellEngage(L["starttrigger3"])

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF", "CheckForLocustCast")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "CheckForLocustCast")
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")

	self:ThrottleSync(10, syncName.locustCast)
	self:ThrottleSync(10, syncName.locustGain)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
	self:IntervalBar(L["gainincbar"], timer.firstLocustSwarm[1], timer.firstLocustSwarm[2], icon.locust, true, "white")
end

function module:OnDisengage()
end

function module:CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS(msg)
	if msg == L["gaintrigger"] then
		self:Sync(syncName.locustGain)
	elseif msg == L["etrigger"] then
		self:Message(L["enragewarn"], "Important", nil, "Alarm")
	end
end

function module:CheckForLocustCast(msg)
	if string.find(msg, L["casttrigger"]) then
		self:Sync(syncName.locustCast)
	end
end

function module:CheckForImpale(msg)
	if string.find(msg, L["impaletrigger"]) then
		self:Sync(syncName.impale)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.locustCast then
		self:LocustCast()
	elseif sync == syncName.locustGain then
		self:LocustGain()
		elseif sync == syncName.impale then
			self:Impale()
	end
end

function module:LocustCast()
	self:RemoveBar(L["impalebar"])
	
	if self.db.profile.locust then
		self:RemoveBar(L["gainincbar"])
		
		self:Message(L["castwarn"], "Orange", nil, "Beware")
		self:WarningSign(icon.locust, timer.locustSwarmCastTime)
		self:Bar(L["castwarn"], timer.locustSwarmCastTime, icon.locust, true, "green")
	end
	
	self:DelayedSync(timer.locustSwarmCastTime, syncName.locustGain)
end

function module:LocustGain()
	if self.db.profile.locust then
		self:Bar(L["gainbar"], timer.locustSwarmDuration, icon.locust, true, "green")
		self:Message(L["gainnextwarn"], "Urgent")
		self:DelayedIntervalBar(timer.locustSwarmDuration, L["gainincbar"], timer.locustSwarmInterval[1]-timer.locustSwarmDuration, timer.locustSwarmInterval[2]-timer.locustSwarmDuration, icon.locust, true, "white")
	end
end

function module:Impale(name)
	if self.db.profile.impale then
		self:IntervalBar(L["impalebar"], timer.impale[1], timer.impale[2], icon.impale, true, "red")
	end
end
