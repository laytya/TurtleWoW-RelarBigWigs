local module, L = BigWigs:ModuleDeclaration("The Beast", "Blackrock Spire")

module.revision = 30002
module.enabletrigger = module.translatedName
module.toggleoptions = {"charge", "fear", "immolate", "flamebreak", "fireball", "bosskill"}
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Blackrock Spire"],
	AceLibrary("Babble-Zone-2.2")["Blackrock Spire"],
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Beast",
	
	charge_cmd = "charge",
	charge_name = "Charge",
	charge_desc = "Charge cooldown timer.",

	fear_cmd = "fear",
	fear_name = "Fear",
	fear_desc = "Fear cooldown timer.",

	immolate_cmd = "immolate",
	immolate_name = "Immolate",
	immolate_desc = "Immolate cooldown timer.",

	flamebreak_cmd = "flamebreak",
	flamebreak_name = "Flamebreak",
	flamebreak_desc = "Flamebreak cooldown timer.",

	fireball_cmd = "fireball",
	fireball_name = "Fireball",
	fireball_desc = "Fireball cooldown timer.",

	test_trigger = "test",
	test_bar = "Test",

} end )

local timer = {
	testTimer = 10,
}

local icon = {
	testIcon = "trade_engineering",
}

local syncName = {
	test = "test"..module.revision,
}

function module:OnEnable()

	self:RegisterEvent("CHAT_MSG_SAY", "Event") -- Testing purposes
	
	self:ThrottleSync(3, syncName.test)
end

function module:OnSetup()
	--self.started = nil
end

function module:OnEngage()
end

function module:OnDisengage()
end

function module:Event(msg)

	if string.find(msg, L["test_trigger"]) then
		self:Sync(syncName.test)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)

	if sync == syncName.test then
		self:Test()
	end
end

function module:Test()
	if self.db.profile.test then
		self:Bar(L["test_bar"], timer.testTimer, icon.testIcon, true, "Red")
	end
end