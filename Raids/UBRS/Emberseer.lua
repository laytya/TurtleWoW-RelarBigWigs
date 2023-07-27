local module, L = BigWigs:ModuleDeclaration("Pyroguard Emberseer", "Blackrock Spire")

local adds = AceLibrary("Babble-Boss-2.2")["Blackhand Incarcerator"]
local boss = AceLibrary("Babble-Boss-2.2")["Pyroguard Emberseer"]

module.revision = 30002
module.enabletrigger = {adds, boss}
module.toggleoptions = {"firenova", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Emberseer",

	firenova_cmd = "firenova",
	firenova_name = "Fire Nova Timer",
	firenova_desc = "Indicates time left to next Fire Nova.",

	timer_bar = "seconds to boss",

	firenova_bar = "Fire Nova",
	firenova_trigger = "Fire Nova",

	bossfree_trigger = "Ha! Ha! Ha! Thank you for freeing me, fools. Now let me repay",
	bossdeath_trigger = "Pyroguard Emberseer dies.",

} end )

local timer = {
	firenova = 6,
}

local icon = {
	firenova = "spell_fire_sealoffire",
}

local syncName = {
	firstfirenova = "emberseerFirstFireNova"..module.revision,
	firenova = "emberseerFirenova"..module.revision,
	bossdeath = "emberseerBossdeath"..module.revision,
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event") -- fire nova
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event") -- fire nova
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event") -- fire nova
	self:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH", "Event") -- boss death -> module disabled
	--self:RegisterEvent("CHAT_MSG_MONSTER_SAY", "Event") -- mangos boss free trigger
	--self:RegisterEvent("CHAT_MSG_SAY", "Event") -- testing purposes

	self:ThrottleSync(3, syncName.firenova)
	self:ThrottleSync(3, syncName.firstfirenova)
	self:ThrottleSync(3, syncName.bossdeath)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
end

function module:OnDisengage()
end

function module:Event(msg)

	if string.find(msg, L["bossdeath_trigger"]) then
		self:Sync(syncName.bossdeath)
	elseif string.find(msg, L["firenova_trigger"]) then
		self:Sync(syncName.firenova)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)

	if sync == syncName.bossdeath then
		self:Bossdeath()
	elseif sync == syncName.firstfirenova then
		self:FirstFirenova()
	elseif sync == syncName.firenova then
		self:Firenova()
	end
end

function module:FirstFirenova()
	if self.db.profile.firenova then
		self:Bar(L["firenova_bar"], timer.firenova, icon.firenova, true, "Red")
	end
end

function module:Firenova()
	if self.db.profile.firenova then
		self:Bar(L["firenova_bar"], timer.firenova, icon.firenova, true, "Red")
	end
end

function module:Bossdeath()
	if self.db.profile.bosskill then
		self.core:ToggleModuleActive(self, false)
	end
end
