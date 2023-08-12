
local module, L = BigWigs:ModuleDeclaration("Instructor Razuvious", "Naxxramas")
local understudy = AceLibrary("Babble-Boss-2.2")["Deathknight Understudy"]

module.revision = 30008
module.enabletrigger = module.translatedName
module.toggleoptions = {"mc", "shout", "unbalance", "shieldwall", "bosskill"}

L:RegisterTranslations("enUS", function() return {
	cmd = "Razuvious",

	shout_cmd = "shout",
	shout_name = "Shout Alert",
	shout_desc = "Warn for disrupting shout",
	
	mc_cmd = "mc",
	mc_name = "MC timer bars",
	mc_desc = "Shows Mind Control timer bars",
	
	unbalance_cmd = "unbalancing",
	unbalance_name = "Unbalancing Strike Alert",
	unbalance_desc = "Warn for Unbalancing Strike",

	shieldwall_cmd = "shieldwall",
	shieldwall_name = "Shield Wall Timer",
	shieldwall_desc = "Show timer for Shield Wall",

	starttrigger1 = "Stand and fight!",
	starttrigger2 = "Show me what you've got!",
	starttrigger3 = "Hah hah, I'm just getting warmed up!",
	startwarn = "Instructor Razuvious engaged! 15sec to Shout, 30sec to Unbalancing Strike!",

	shouttrigger = "lets loose a triumphant shout.",
	shouttrigger2 = "Razuvious's Disrupting Shout",
	shout7secwarn = "7 sec to Disrupting Shout",
	shout3secwarn = "3 sec to Disrupting Shout!",
	shoutwarn = "Disrupting Shout! Next in 25secs",
	noshoutwarn = "No shout! Next in 20secs",
	shoutbar = "Disrupting Shout",

	unbalance_trigger = "afflicted by Unbalancing Strike",
	unbalancesoonwarn = "Unbalancing Strike coming soon!",
	unbalancewarn = "Unbalancing Strike! Next in ~30sec",
	unbalancebar = "Unbalancing Strike",

	shieldwalltrigger   = "Deathknight Understudy gains Shield Wall.",
	shieldwallbar       = "Shield Wall",
	
	mc_trigger = "You gain Mind Control.", --CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS
	mcEnd_trigger = "Mind Control fades from you.", --Aura gone self
	mc_bar = " MC",
	mcLocked_bar = "Can't MC ",
} end )

L:RegisterTranslations("esES", function() return {
	--cmd = "Razuvious",

	--shout_cmd = "shout",
	shout_name = "Alerta de Grito perturbador",
	shout_desc = "Avisa para Grito perturbador",

	--unbalance_cmd = "unbalancing",
	unbalance_name = "Alerta de Golpe desequilibrante",
	unbalance_desc = "Avisa para Golpe desequilibrante",

	--shieldwall_cmd = "shieldwall",
	shieldwall_name = "Temporizador de Muro de escudo",
	shieldwall_desc = "Muestra un temporizador para Muro de escudo",

	startwarn = "¡Entrando en combate con Instructor Razuvious! 15 segundos hasta Grito, 30 segundos hasta Golpe desequilibrante!",

	starttrigger1 = "Stand and fight!",
	starttrigger2 = "Show me what you've got!",
	starttrigger3 = "Hah hah, I'm just getting warmed up!",
	--starttrigger4 = "Stand and fight!",

	shouttrigger = "Grito perturbador",
	shout7secwarn = "7 segundos hasta Grito perturbador",
	shout3secwarn = "¡3 segundos hasta Grito perturbador!",
	shoutwarn = "¡Grito perturbador! El próximo en 25 segundos",
	noshoutwarn = "¡No hay grito! El próximo en 20 segundos",
	shoutbar = "Grito perturbado",

	unbalance_trigger = "sufre de Golpe desequilibrante",
	unbalancesoonwarn = "¡Golpe desequilibrante pronto!",
	unbalancewarn = "¡Golpe desequilibrante! El próximo en ~30 segundos",
	unbalancebar = "Golpe desequilibrante",

	shieldwalltrigger   = "Caballero de la Muerte suplente gana Muro de escudo.",
	shieldwallbar       = "Muro de escudo",
} end )

local timer = {
	firstShout = 15,
	shout = 25,
	noShoutDelay = 5, --is 1 on Kronos, are shouts rigid timed on TWoW?
	unbalance = 30,
	shieldwall = 20,
	mc = 60,
	mcLocked = 60,
}
local icon = {
	shout = "Ability_Warrior_WarCry",
	unbalance = "Ability_Warrior_DecisiveStrike",
	shieldwall = "Ability_Warrior_ShieldWall",
	mc = "spell_shadow_shadowworddominate",
	taunt = "spell_nature_reincarnation",
	mcLocked = "spell_shadow_sacrificialshield",
}
local syncName = {
	shout = "RazuviousShout"..module.revision,
	shieldwall = "RazuviousShieldwall"..module.revision,
	mc = "RazuviousMc"..module.revision,
	mcEnd = "RazuviousMcEnd"..module.revision,
	mcLocked = "RazuviousMcLocked"..module.revision,
}

module:RegisterYellEngage(L["starttrigger1"])
module:RegisterYellEngage(L["starttrigger2"])
module:RegisterYellEngage(L["starttrigger3"])

local _, playerClass = UnitClass("player")

function module:OnEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE", "Event")--changed from "CheckForUnbalance" to "Event"
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE", "Event")--changed from "CheckForUnbalance" to "Event"

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "Event")--changed from "CheckForUnbalance" to "Event"
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "Event")--changed from "CheckForUnbalance" to "Event"
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "Event")--changed from "CheckForUnbalance" to "Event"
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE", "Event")--changed from "CheckForUnbalance" to "Event"

	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS", "Event")--changed from "CheckForShieldwall" to "Event"
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS", "Event")--changed from "CheckForShieldwall" to "Event"
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS", "Event")--changed from "CheckForShieldwall" to "Event"
	self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "Event")--changed from "CheckForShieldwall" to "Event"
	
	self:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE", "Event")
	self:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE", "Event")

	self:ThrottleSync(5, syncName.shout)
	self:ThrottleSync(5, syncName.shieldwall)
	self:ThrottleSync(0, syncName.mc)
	self:ThrottleSync(0, syncName.mcEnd)
	self:ThrottleSync(0, syncName.mcLocked)
end

function module:OnSetup()
end

function module:OnEngage()
	if self.db.profile.shout then
		self:Message(L["startwarn"], "Attention", nil, "Urgent")
		self:DelayedMessage(timer.firstShout - 7, L["shout7secwarn"], "Urgent")
		self:DelayedMessage(timer.firstShout - 3, L["shout3secwarn"], "Urgent")
		self:Bar(L["shoutbar"], timer.firstShout, icon.shout, true, "red")
		self:DelayedWarningSign(timer.shout - 3, icon.shout, 0.7)
		--self:ScheduleEvent("bwrazuviousnoshout", self.NoShout, timer.shout + timer.noShoutDelay, self) -- praeda first no shout fix
	end
end

function module:OnDisengage()
end

function module:Event(msg)
	if string.find(msg, L["shieldwalltrigger"]) then
		self:Sync(syncName.shieldwall)
	end
	if string.find(msg, L["shouttrigger"]) then
		self:Sync(syncName.shout)
	end
	if string.find(msg, L["shouttrigger2"]) then
		self:Sync(syncName.shout)
	end
	if string.find(msg, L["unbalance_trigger"]) then
		self:Message(L["unbalancewarn"], "Urgent")
		self:DelayedMessage(timer.unbalance - 5, L["unbalancesoonwarn"], "Urgent")
		self:Bar(L["unbalancebar"], timer.unbalance, icon.unbalance)
	end
	if string.find(msg, L["mc_trigger"]) then
		mcPerson = UnitName("player")
		if GetRaidTargetIndex("target")== nil then mcIcon = "NoIcon"; end
		if GetRaidTargetIndex("target")==1 then mcIcon = "Star"; end
		if GetRaidTargetIndex("target")==2 then mcIcon = "Circle"; end
		if GetRaidTargetIndex("target")==3 then mcIcon = "Diamond"; end
		if GetRaidTargetIndex("target")==4 then mcIcon = "Triangle"; end
		if GetRaidTargetIndex("target")==5 then mcIcon = "Moon"; end
		if GetRaidTargetIndex("target")==6 then mcIcon = "Square"; end
		if GetRaidTargetIndex("target")==7 then mcIcon = "Cross"; end
		if GetRaidTargetIndex("target")==8 then mcIcon = "Skull"; end
		self:Sync(syncName.mc.." "..mcPerson.." "..mcIcon)
	end
	if string.find(msg, L["mcEnd_trigger"]) then
		mcPerson = UnitName("player")
		self:Sync(syncName.mcEnd.." "..mcPerson.." "..mcIcon) --is mcIcon changing when priest2 does MC or is it local, and only the sync changes?
		self:Sync(syncName.mcLocked.." "..mcIcon)
	end
end

function module:NoShout()
	self:CancelDelayedWarningSign(icon.shout)
	self:CancelScheduledEvent("bwrazuviousnoshout")
	self:ScheduleEvent("bwrazuviousnoshout", self.NoShout, timer.shout + timer.noShoutDelay, self)
	if self.db.profile.shout then
		self:Bar(L["shoutbar"], timer.shout - timer.noShoutDelay, icon.shout, true, "red")
		self:DelayedMessage(timer.shout - timer.noShoutDelay - 7, L["shout7secwarn"], "Urgent")
		self:DelayedMessage(timer.shout - timer.noShoutDelay - 3, L["shout3secwarn"], "Urgent")
		self:DelayedWarningSign(timer.shout - 3, icon.shout, 0.7)
	end
end

function module:BigWigs_RecvSync(sync, rest, nick)
	if sync == syncName.shout and self.db.profile.shout then
		self:Shout()
	elseif sync == syncName.shieldwall and self.db.profile.shieldwall then
		self:Shieldwall()
	elseif sync == syncName.mc and self.db.profile.mc then
		self:Mc(rest)
	elseif sync == syncName.mcEnd and self.db.profile.mc then
		self:McEnd(rest)
	elseif sync == syncName.mcLocked and self.db.profile.mc then
		self:McLocked(rest)
	end
end

function module:Mc(rest)
	self:Bar(rest..L["mc_bar"], timer.mc, icon.mc, true, "white")
end

function module:McEnd(rest)
	self:RemoveBar(rest..L["mc_bar"])
	if playerClass == "WARRIOR" then
		self:WarningSign(icon.taunt, 0.7)
		self:Sound("Info")
	end
end

function module:McLocked(rest)
	self:Bar(L["mcLocked_bar"]..rest, timer.mcLocked, icon.mcLocked, true, "black") --if it works, then find a way to pass only the Icon to this bar.
end

function module:Shout()
	self:CancelDelayedWarningSign(icon.shout)
	--self:CancelScheduledEvent("bwrazuviousnoshout")
	--self:ScheduleEvent("bwrazuviousnoshout", self.NoShout, timer.shout + timer.noShoutDelay, self)
	self:Message(L["shoutwarn"], "Attention", nil, "Alarm")
	self:DelayedMessage(timer.shout - 7, L["shout7secwarn"], "Urgent")
	self:DelayedMessage(timer.shout - 3, L["shout3secwarn"], "Urgent")
	self:Bar(L["shoutbar"], timer.shout, icon.shout, true, "red")
	self:DelayedWarningSign(timer.shout - 3, icon.shout, 0.7)
end

function module:Shieldwall()
	self:Bar(L["shieldwallbar"], timer.shieldwall, icon.shieldwall, true, "green")
	if playerClass == "PRIEST" then
		self:DelayedWarningSign(timer.shieldwall, icon.taunt, 0.7)
	end
end
