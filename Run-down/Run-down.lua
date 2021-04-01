file_manager:encrypt_file("Run-down.lua")

do 
    local function AutoUpdate()
        local Version = 1
        local file_name = "BenKat.lua"
        local url = "https://raw.githubusercontent.com/stoneb2/Bruhwalker/main/BenKat/BenKat.lua?token=ALFJBUQC5TMIXXLYNUHNMY3AMYOOW"
        local web_version = http:get("https://raw.githubusercontent.com/stoneb2/Bruhwalker/main/BenKat/BenKat.version.txt?token=ALFJBUS5IGWW6Q5XQEKDBHLAMYOYW")
        console:log("BenKat Version: "..Version)
        console:log("BenKat Web Version: "..tonumber(web_version))
        if tonumber(web_version) == Version then
            console:log("BenKat successfully loaded")
        else
            http:download(url, file_name)
            console:log("New BenKat Update Available")
            console:log("Please Reload with F5")
        end
    end
    AutoUpdate()
end

local_player = game.local_player
local flame = "Your mother is a nice woman"
local team = tonumber(local_player.team)

local function GetAllyHeroes()
    local _AllyHeroes = {}
    players = game.players
    for i, unit in ipairs(players) do
        if unit and not unit.is_enemy and unit.object_id ~= local_player.object_id then
            table.insert(_AllyHeroes, unit)
        end
    end
    return _AllyHeroes
end

RUNDOWN_category = menu:add_category("IM RUNNING IT DOWN")
runit = menu:add_checkbox("Run it?", RUNDOWN_category, 0)
flameit = menu:add_checkbox("Flame", RUNDOWN_category, 1)
ally_champs = GetAllyHeroes()
follow_table = {}
follow_table[1] = tostring(ally_champs[1].champ_name)
follow_table[2] = tostring(ally_champs[2].champ_name)
follow_table[3] = tostring(ally_champs[3].champ_name)
follow_table[4] = tostring(ally_champs[4].champ_name)
follow = menu:add_checkbox("Follow?", RUNDOWN_category, 0)
follow_settings = menu:add_subcategory("Follow settings", RUNDOWN_category)
follow_champ = menu:add_combobox("Who to follow: ", follow_settings, follow_table, 1)
mastery = menu:add_checkbox("Show mastery on death", RUNDOWN_category, 1)
ff = menu:add_checkbox("Try to ff on death", RUNDOWN_category, 1)
gg = menu:add_checkbox("GG message at end of game", RUNDOWN_category, 1)

local function run_down()
    if team == 100 then
        if menu:get_value(follow) == 1 then
            ally_list = GetAllyHeroes()
            for _, v in pairs(ally_list) do
                if tostring(v.champ_name) == follow_table[menu:get_value(follow_champ) + 1] then
                    orbwalker:move_to(v.origin.x, v.origin.y, v.origin.z)
                    if v.is_recalling then
                        keyPress(98)
                    end
                end
            end
        else
            orbwalker:move_to(14298, 171.978, 14338)
        end
    else
        if menu:get_value(follow) == 1 then
            ally_list = GetAllyHeroes()
            for i = 1, v in pairs(ally_list) do
                if tostring(v.champ_name) == follow_table[menu:get_value(follow_champ) + 1] then
                    orbwalker:move_to(v.origin.x, v.origin.y, v.origin.z)
                    if v.is_recalling then
                        keypress(98)
                    end
                end
            end
        else
            orbwalker:move_to(406.83, 182.13, 379.81)
        end
    end
end

local function on_tick()
    if menu:get_value(runit) == 1 then
        run_down()
    end
end

local function on_death()
    if menu:get_value(runit) == 1 and menu:get_value(flameit) == 1 then
        game:send_chat(flame)
    end
    if menu:get_value(runit) == 1 and menu:get_value(mastery) == 1 then
        game:mastery_display()
    end
    if menu:get_value(runit) == 1 and menu:get_value(ff) == 1 then
        game:send_chat("/ff")
    end
end

local function on_game_end()
    if menu:get_value(runit) == 1 and menu:get_value(gg) == 1 then
        game:send_chat("GGWP! :)")
    end
end

client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_death", on_death)