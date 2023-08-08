
local module, L = BigWigs:ModuleDeclaration("Maexxna", "Naxxramas")

module.revision = 30008
module.enabletrigger = module.translatedName
module.toggleoptions = { "spray", "poison", "cocoon", "bosskill" }

L:RegisterTranslations("enUS", function()
    return {
        cmd = "Maexxna",

        spray_cmd = "spray",
        spray_name = "Web Spray Alert",
        spray_desc = "Warn for webspray and spiders",

        enrage_cmd = "enrage",
        enrage_name = "Enrage Alert",
        enrage_desc = "Warn for enrage",

        cocoon_cmd = "cocoon",
        cocoon_name = "Cocoon Alert",
        cocoon_desc = "Warn for Cocooned players",

        poison_cmd = "Poison",
        poison_name = "Necrotic Poison Alert",
        poison_desc = "Warn for Necrotic Poison",

        cocoontrigger = "(.*) (.*) afflicted by Web Wrap.",
        webspraytrigger = "afflicted by Web Spray",
        poisontrigger = "afflicted by Necrotic Poison.",
        --etrigger1 = "gains Enrage",

        cocoonwarn = "%s Cocooned!",
        poisonwarn = "Necrotic Poison!",
        --enragetrigger = "%s becomes enraged.",

        webspraywarn30sec = "Wall Cocoons in 10 seconds",
        webspraywarn20sec = "Wall Cocoons! 15 seconds until Spiders spawn!",
        webspraywarn10sec = "10 seconds until Web Spray!",
        webspraywarn5sec = "AOE - Spiders Spawn - AOE! WEB SPRAY 5 SECONDS!",
        webspraywarn = "Web Spray! 40 seconds until next!",

        webspraybar = "Web Spray",
        cocoonbar = "Cocoons",
        spiderbar = "Spiders",
        poisonbar = "Necrotic Poison",

        you = "You",
        are = "are",
    }
end)

L:RegisterTranslations("esES", function()
    return {
        --cmd = "Maexxna",

        --spray_cmd = "spray",
        spray_name = "Alerta de Pulverizador de tela de araña",
        spray_desc = "Avisa para Pulverizador de tela de araña",

        --enrage_cmd = "enrage",
        --enrage_name = "Alerta de Enfurecer",
        --enrage_desc = "Avisa para Enfurecer",

        --cocoon_cmd = "cocoon",
        cocoon_name = "Alerta de Capullo",
        cocoon_desc = "Avisa para jugadores en Capullo",

        --poison_cmd = "Poison",
        poison_name = "Alerta de Veneno necrótico",
        poison_desc = "Avisa para Veneno necrótico",

        cocoontrigger = "(.*) (.*) sufre de Trampa arácnida.",
        webspraytrigger = "sufre de Pulverizador de tela de araña",
        poisontrigger = "sufre de Veneno necrótico.",
        etrigger1 = "gana Enfurecer",

        cocoonwarn = "¡%s en Capullo!",
        poisonwarn = "¡Veneno necrótico!",
        --enragetrigger = "%s becomes enraged.",

        webspraywarn30sec = "Capullos al muro en 10 segundos",
        webspraywarn20sec = "¡Capullos al muro! 15 segundos hasta aparezcan las arañas!",
        webspraywarn10sec = "¡10 segundos hasta Pulverizador de tela de araña!",
        webspraywarn5sec = "¡AOE - Aparecen las arañas - AOE! PULVERIZADOR DE TELA DE ARAÑA 5 SEGUNDOS!",
        webspraywarn = "¡Pulverizador de tela de araña! 40 segundos hasta el próximo!",

        --enragewarn = "¡Enfurecer!",
        --enragesoonwarn = "¡Enfurecer pronto!",

        webspraybar = "Pulverizador de tela de araña",
        cocoonbar = "Capullos",
        spiderbar = "Arañás",
        poisonbar = "Veneno necrótico",

        you = "Tu",
        are = "estás",
    }
end)

local timer = {
    poison = { 8.5, 25 },
    firstPoison = 10,
    cocoon = 20,
    spider = 30,
    webspray = 40,
}
local icon = {
    spider = "INV_Misc_MonsterSpiderCarapace_01",
    cocoon = "Spell_Nature_Web",
    poison = "Ability_Creature_Poison_03",
    webspray = "Ability_Ensnare",
    enrage = "Spell_shadow_unholyfrenzy",
}
local syncName = {
    webspray = "MaexxnaWebspray" .. module.revision,
    poison = "MaexxnaPoison" .. module.revision,
    cocoon = "MaexxnaCocoon" .. module.revision,
    enrage = "MaexxnaEnrage" .. module.revision,
}

local times = {}

local enrageannounced = false

function module:OnEnable()
    --self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS", "EnrageEvent")
    self:RegisterEvent("UNIT_HEALTH")

    self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE", "SprayEvent")
    self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", "SprayEvent")
    self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE", "SprayEvent")

    self:ThrottleSync(8, syncName.webspray)
    self:ThrottleSync(5, syncName.poison)
    self:ThrottleSync(0, syncName.cocoon)
end

function module:OnSetup()
    enrageannounced = false
    times = {}
end

function module:OnEngage()
    self:Message(L["poisonwarn"], "Important")
    self:IntervalBar(L["poisonbar"], timer.poison[1], timer.poison[2], icon.poison, true, "Green")
    self:Webspray()
end

function module:OnDisengage()
end

function module:UNIT_HEALTH(arg1)
	if UnitName(arg1) == module.translatedName then
		local health = UnitHealth(arg1)
		if health > 25 and health <= 30 and not enrageannounced then
			self:Sync(syncName.enrage)
			enrageannounced = true
		elseif health > 30 and enrageannounced then
			enrageannounced = nil
		end
	end
end

function module:SprayEvent(msg)
    if string.find(msg, L["webspraytrigger"]) then
        self:Sync(syncName.webspray)
    elseif string.find(msg, L["poisontrigger"]) then
        self:Sync(syncName.poison)
    elseif string.find(msg, L["cocoontrigger"]) then
        local _, _, wplayer, wtype = string.find(msg, L["cocoontrigger"])
        if wplayer and wtype then
            if wplayer == L["you"] and wtype == L["are"] then
                wplayer = UnitName("player")
            end
            local t = GetTime()
            if (not times[wplayer]) or (times[wplayer] and (times[wplayer] + 10) < t) then
                self:Sync(syncName.cocoon .. " " .. wplayer)
            end
        end
    end
end

function module:BigWigs_RecvSync(sync, rest)
    if sync == syncName.webspray then
        self:Webspray()
    elseif sync == syncName.poison then
        self:Poison()
    elseif sync == syncName.cocoon and rest then
        self:Cocoon(rest)
    elseif sync == syncName.enrage then
        self:Enrage()
    end
end

function module:Webspray()
    self:Message(L["webspraywarn"], "Important")
    self:Bar(L["cocoonbar"], timer.cocoon, icon.cocoon, true, "blue")
    self:Bar(L["spiderbar"], timer.spider, icon.spider, true, "red")
    self:Bar(L["webspraybar"], timer.webspray, icon.webspray, true, "white")
end

function module:Poison()
    if self.db.profile.poison then
        self:Message(L["poisonwarn"], "Important")
        self:IntervalBar(L["poisonbar"], timer.poison[1], timer.poison[2], icon.poison, true, "Green")
    end
end

function module:Cocoon(player)
    local t = GetTime()
    if (not times[player]) or (times[player] and (times[player] + 10) < t) then
        if self.db.profile.cocoon then
            self:Message(string.format(L["cocoonwarn"], player), "Urgent")
        end
        times[player] = t
    end
end

function module:Enrage()
    self:Message("Maexxna becomes Enraged !", "Important")
	self:WarningSign(icon.enrage, 0.7)
end
