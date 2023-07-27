
local module, L = BigWigs:ModuleDeclaration("Gurubashi Bat Rider", "Zul'Gurub")

module.revision = 20001
module.enabletrigger = module.translatedName
module.toggleoptions = {"bigicon", "bars"}
module.trashMod = true

L:RegisterTranslations("enUS", function() return {
	cmd = "BatRider",

	bars_cmd = "bars",
	bars_name = "Toggle bars",
	bars_desc = "Toggles showing bars for timers.",
	
	bigicon_cmd = "bigicon",
	bigicon_name = "BigIcon warnings",
	bigicon_desc = "Big icon warning on explosion",
	
	explodingTrigger = "Gurubashi Bat Rider becomes fully engulfed in flames.",
	explodingBar = "Exploding",
	explodingMsg = "Exploding!",
} end )

module.defaultDB = {
	bosskill = nil,
}

local timer = {
	exploding = 3,
}

local icon = {
	exploding = "spell_fire_incinerate",
}

local syncName = {
}

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE", "Emote")
end

function module:OnSetup()
	self.started = nil
end

function module:OnEngage()
end

function module:OnDisengage()
end

function module:Emote(msg)
	DEFAULT_CHAT_FRAME:AddMessage("BatRider Emote")
	DEFAULT_CHAT_FRAME:AddMessage("msg="..msg)
	if msg == L["explodingTrigger"] then
		
		DEFAULT_CHAT_FRAME:AddMessage("explodingTrigger")
		
		self:Bar(L["explodingBar"], timer.exploding, icon.exploding, true, "Red")
		self:Message(L["explodingMsg"], "Important")
		if self.db.profile.bigicon then
			self:WarningSign(icon.exploding, timer.exploding)
		end
		
		self:Sound("RunAway")
	end
end
