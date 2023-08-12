
local module, L = BigWigs:ModuleDeclaration("Patchwerk", "Naxxramas")

module.revision = 20003
module.enabletrigger = module.translatedName
module.toggleoptions = {"enrage", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Patchwerk",

	enrage_cmd = "enrage",
	enrage_name = "Enrage Alert",
	enrage_desc = "Warn for Enrage",
	
	starttrigger1 = "Patchwerk want to play!",
	starttrigger2 = "Kel'Thuzad make Patchwerk his Avatar of War!",
	startwarn = "Patchwerk Engaged! Enrage in 7 minutes!",
	
	enragebartext = "Enrage",
	warn60 = "Enrage in 60 seconds",
	warn10 = "Enrage in 10 seconds",
	
	enragetrigger = "%s goes into a berserker rage!",
	enragewarn = "Enrage!",
} end )

L:RegisterTranslations("esES", function() return {
	--cmd = "Patchwerk",

	--enrage_cmd = "enrage",
	enrage_name = "Alerta de Enfurecer",
	enrage_desc = "Avisa para Enfurecer",

	enragetrigger = "%s goes into a berserker rage!",

	enragewarn = "¡Enfurecer!",
	starttrigger1 = "Patchwerk want to play!",
	starttrigger2 = "Kel'Thuzad make Patchwerk his Avatar of War!",
	startwarn = "¡Entrando en combate con Remendejo! Enfurecer en 7 minutos!",
	enragebartext = "Enfurecer",
	warn5m = "Enfurecer en 5 minutos",
	warn3m = "Enfurecer en 3 minutos",
	warn90 = "Enfurecer en 90 segundos",
	warn60 = "Enfurecer en 60 segundos",
	warn30 = "Enfurecer en 30 segundos",
	warn10 = "Enfurecer en 10 segundos",
} end )

local timer = {
	enrage = 420,
}
local icon = {
	enrage = "Spell_Shadow_UnholyFrenzy",
}
local syncName = {
	enrage = "PatchwerkEnrage"..module.revision,
}

local berserkannounced = nil

module:RegisterYellEngage(L["starttrigger1"])
module:RegisterYellEngage(L["starttrigger2"])

function module:OnEnable()
	self:ThrottleSync(10, syncName.enrage)
end

function module:OnSetup()
	self.started = false
	berserkannounced = false
end

function module:OnEngage()
	if self.db.profile.enrage then
		self:Message(L["startwarn"], "Important")
		self:Bar(L["enragebartext"], timer.enrage, icon.enrage, true, "White")
		self:DelayedMessage(timer.enrage - 60, L["warn60"], "Urgent")
		self:DelayedMessage(timer.enrage - 10, L["warn10"], "Important")
	end
end

function module:OnDisengage()
end

function module:CHAT_MSG_MONSTER_EMOTE( msg )
	if msg == L["enragetrigger"] then
		self:Sync(syncName.enrage)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.enrage then
		self:Enrage()
	end
end

function module:Enrage()
	if self.db.profile.enrage then
		self:Message(L["enragewarn"], "Important", nil, "Beware")

		self:RemoveBar(L["enragebartext"])

		self:CancelDelayedMessage(L["warn60"])
		self:CancelDelayedMessage(L["warn10"])
	end
end
