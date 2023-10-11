
local module, L = BigWigs:ModuleDeclaration("Grizikil", "Karazhan")

module.revision = 30020
module.enabletrigger = module.translatedName
module.toggleoptions = {"bosskill"}
module.zonename = {
	AceLibrary("AceLocale-2.2"):new("BigWigs")["Karazhan"],
	AceLibrary("Babble-Zone-2.2")["Karazhan"],
}

L:RegisterTranslations("enUS", function() return {
	cmd = "Grizikil",

	trigger_yellSmt = "You-you-you no defeat me, I am strong!",--CHAT_MSG_MONSTER_YELL
	
	trigger_engage = "Whats this? You're here for the orb?! ITS MINE, Grellkin, get them!",--CHAT_MSG_MONSTER_YELL
	
	msg_pullAll = "Grizikil module Enabled - Pull --ALL-- imp packs before engaging!",
} end )

local timer = {

}
local icon = {

}
local color = {

}
local syncName = {

}

module:RegisterYellEngage(L["trigger_engage"])

function module:OnEnable()
	self:Message(L["msg_pullAll"], "Urgent", false, nil, false)
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
end

function module:OnDisengage()
end

function module:Event(msg)
end


function module:BigWigs_RecvSync(sync, rest, nick)
end
