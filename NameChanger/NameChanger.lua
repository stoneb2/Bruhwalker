-- SET YOUR NAME HERE /////////////////////////////////////////////////////////////////////
local myName = "Riot Cryptor" 

-- SET YOUR RANDOM DATABASE HERE //////////////////////////////////////////////////////////
local database = {
    "FNC Adam",
    "RGE Odoamne",
    "100T Ssumday",
    "100T Tenacity",
    "TL Alphari",
    "TL Jenkins",
    "C9 Fudge",
    "EDG Flandre",
    "FPX Nuguri",
    "FPX xiaolaohu",
    "RNG Xiaohu",
    "LNG Ale",
    "DWG Khan",
    "GEN Rascal",
    "GEN Burdol",
    "T1 Canna",
    "HLE DuDu",
    "HLE Morgan",
    "PSG Hanabi",
    "PSG Kartis",
    "BYG Liang",
    "BYG PK",
    "INF Buggax",
    "INF Brayaron",
    "PCE Vizicsacsi",
    "PCE Lived",
    "RED GUIGO",
    "DFM Evi",
    "GS Crazy",
    "GS Luana",
    "UOL BOSS",
    "FNC Bwipo",
    "RGE Inspired",
    "100T Closer",
    "100T Kenvi",
    "TL Santorin",
    "TL Armao",
    "C9 Blaber",
    "EDG Jiejie",
    "EDG JunJia",
    "FPX Tian",
    "RNG Wei",
    "LNG Tarzan",
    "DWG Canyon",
    "DWG Malrang",
    "GEN Clid",
    "GEN YoungJae",
    "T1 Oner",
    "T1 Cuzz",
    "HLE Willer",
    "HLE yoHan",
    "PSG River",
    "BYG HuSha",
    "INF SolidSnake",
    "PCE Babip",
    "RED Aegis",
    "DFM Steal",
    "GS Mojito",
    "UOL AHaHaCiK",
    "FNC Nisqy",
    "RGE Larssen",
    "RGE Blueknight",
    "100T Abbedagge",
    "TL Jensen",
    "C9 Perkz",
    "EDG Scout",
    "FPX Doinb",
    "RNG Cryin",
    "RNG Yuekai",
    "LNG icon",
    "DWG ShowMaker",
    "GEN Bdd",
    "T1 Faker",
    "HLE Chovy",
    "PSG Maple",
    "BYG Husky",
    "BYG Maoan",
    "INF cody",
    "PCE Halo",
    "PCE Tally",
    "RED Avenger",
    "RED Grevthar",
    "DFM Aria",
    "DFM Ceros",
    "GS Bolulu",
    "UOL Nomanz",
    "FNC Upset",
    "RGE Hans sama",
    "100T FBI",
    "TL Tactical",
    "C9 Zven",
    "EDG Viper",
    "FPX Lwx",
    "RNG GALA",
    "LNG Light",
    "DWG Ghost",
    "DWG Rahel",
    "GEN Ruler",
    "T1 Gumayusi",
    "T1 Teddy",
    "HLE Deft",
    "PSG Unified",
    "BYG Doggo",
    "INF WhiteLotus",
    "INF Kz",
    "PCE Violet",
    "RED TitaN",
    "DFM Yutapon",
    "GS Alive",
    "GS Padden",
    "UOL Argonavt",
    "UOL Frappii",
    "FNC Hyllisang",
    "RGE Trymbi",
    "100T huhi",
    "TL CoreJJ",
    "C9 Vulcan",
    "EDG Meiko",
    "FPX Crisp",
    "FPX Shenyi",
    "RNG Ming",
    "LNG Iwandy",
    "LNG Kedaya",
    "DWG BeryL",
    "GEN Life",
    "T1 Keria",
    "HLE Vsta",
    "PSG Kawing",
    "BYG Kino",
    "INF Ackerman",
    "PCE Aladoric",
    "RED Jojo",
    "DFM Gaeng",
    "DFM Kazu",
    "GS Zergsting",
    "UOL SaNTaS"
}

local teams = {
    "Fnatic",
    "Rogue",
    "100 Thieves",
    "Team Liquid",
    "Cloud9",
    "EDward Gaming",
    "FunPlus Pheonix",
    "Royal Never Give Up",
    "LNG Esports",
    "DWG KIA",
    "Gen.G",
    "T1",
    "Hanwha Life Esports",
    "PSG Talon",
    "Beyond Gaming",
    "Infinity Esports",
    "PEACE",
    "RED Canids",
    "DetonatioN FocusMe",
    "Galatasaray Esports",
    "Unicorns Of Love"
}

local teams_abbreviated = {
    "FNC",
    "RGE",
    "100T",
    "TL",
    "C9",
    "EDG",
    "FPX",
    "RNG",
    "LNG",
    "DWG",
    "GEN",
    "T1",
    "HLE",
    "PSG",
    "BYG",
    "INF",
    "PCE",
    "RED",
    "DFM",
    "GS",
    "UOL"
}

local version = 1.0
local myHero = game.local_player

local file_name = "VectorMath.lua"
if not file_manager:file_exists(file_name) then
   local url = "https://raw.githubusercontent.com/stoneb2/Bruhwalker/main/VectorMath/VectorMath.lua"
   http:download_file(url, file_name)
   console:log("VectorMath Library Downloaded")
   console:log("Please Reload with F5")
end

local ml = require("VectorMath")

local NameChanger = {}

local function OnLoad()
    if NameChanger:AutoUpdate() then
        return
    end

    NameChanger:__init()
end

function NameChanger:AutoUpdate()
    local file_name = "NameChanger.lua"
    local url = "https://raw.githubusercontent.com/stoneb2/Bruhwalker/main/NameChanger/NameChanger.lua"
    local web_version = http:get("https://raw.githubusercontent.com/stoneb2/Bruhwalker/main/NameChanger/NameChanger.version.txt")
    if tonumber(web_version) ~= version then
        http:download_file(url, file_name)
        console:log("New Name Changer Update Available")
        console:log("Please Reload with F5")

        return true
    end

    return false
end

function NameChanger:__init()
    self:Menu()
end

function NameChanger:Menu()
    self.menu = menu:add_category("Name Changer")

    self.label = menu:add_label('"/ban Cryptor" - Ben', self.menu)

    self.enabled = menu:add_checkbox("Enabled", self.menu, 0)
    menu:set_callback(self.enabled, function(...) self:EnabledToggle(...) end)

    self.custom_name = menu:add_checkbox("Use Custom Name for Me", self.menu, 0)
    menu:set_callback(self.custom_name, function(...) self:CustomNameToggle(...) end)

    self.match = menu:add_checkbox("Match Team Names", self.menu, 1)
    menu:set_callback(self.match, function(...) self:OptionToggle(...) end)

    self.ally_team = menu:add_combobox("Ally Team", self.menu, teams, 0)
    menu:set_callback(self.ally_team, function(...) self:OptionToggle(...) end)

    self.enemy_team = menu:add_combobox("Enemy Team", self.menu, teams, 1)
    menu:set_callback(self.enemy_team, function(...) self:OptionToggle(...) end)
end

function NameChanger:IsMe(unit)
    if ml.IsValid(unit) then
        if unit.object_id == local_player.object_id then
            return true
        end
    end

    return false
end

function NameChanger:InList(val, tab)
    for _, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function NameChanger:GetAllies()
    local _AllyHeroes = {}
    local players = game.players
    for i, unit in ipairs(players) do
        if unit and not unit.is_enemy then
            table.insert(_AllyHeroes, unit)
        end
    end
    return _AllyHeroes
end

function NameChanger:GetEnemies()
    local _EnemyHeroes = {}
	local players = game.players	
	for i, unit in ipairs(players) do
		if unit and unit.is_enemy then
			table.insert(_EnemyHeroes, unit)
		end
	end	
	return _EnemyHeroes
end

function NameChanger:EnabledToggle(value)
    local enabled = value == 1

    if not enabled then
        for i, player in ipairs(game.players) do
            player:restore_name()
        end

        return
    end

    self:SetNames()
end

function NameChanger:CustomNameToggle(value)
    local enabled = value == 1

    if not enabled then
        self:SetNames()
        return
    end

    myHero:set_name(myName)
end

function NameChanger:OptionToggle(value)
    self:SetNames()
end

function NameChanger:RandomName()
    local max = #database
    local rand = math.random(1, max)
    return database[rand]
end

function NameChanger:RandomNamesByTeam()
    local allyNames = {}
    local enemyNames = {}

    local allyTeamIndex = menu:get_value(self.ally_team) + 1
    local allyAbbrev = teams_abbreviated[allyTeamIndex]
    local allyNum = #self:GetAllies()

    local enemyTeamIndex = menu:get_value(self.enemy_team) + 1
    local enemyAbbrev = teams_abbreviated[enemyTeamIndex]
    local enemyNum = #self:GetEnemies()

    for _, name in ipairs(database) do
        if #allyNames == allyNum and #enemyNames == enemyNum then
            break
        end

        if #allyNames < allyNum and string.find(name, allyAbbrev) and not self:InList(name, allyNames) then
            table.insert(allyNames, name)
        end

        if #enemyNames < enemyNum and string.find(name, enemyAbbrev) and not self:InList(name, enemyNames) then
            table.insert(enemyNames, name)
        end
    end

    return allyNames, enemyNames
end

function NameChanger:SetNames()
    local enabled = menu:get_value(self.enabled) == 1
    if not enabled then
        return
    end

    local match_teams = menu:get_value(self.match) == 1
    if not match_teams then
        local set_names = {}
        for i, player in ipairs(game.players) do
            ::retry::

            local name = self:RandomName()
            if not self:InList(name, set_names) then
                player:set_name(name)
                table.insert(set_names, name)
            else
                goto retry
            end
        end

        local custom_name = menu:get_value(self.custom_name) == 1
        if custom_name then
            myHero:set_name(myName)
        end

        return
    end

    local allyNames, enemyNames = self:RandomNamesByTeam()
    local custom_name = menu:get_value(self.custom_name) == 1
    for i, ally in ipairs(self:GetAllies()) do
        if self:IsMe(ally) and custom_name then
            ally:set_name(myName)
            goto continue
        end
        
        ally:set_name(allyNames[i])

        ::continue::
    end

    for i, enemy in ipairs(self:GetEnemies()) do
        enemy:set_name(enemyNames[i])
    end
end

OnLoad()