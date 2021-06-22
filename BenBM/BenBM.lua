do
    local function AutoUpdate()
        local Version = 1
        local file_name = "BenBM.lua"
        local url = "https://raw.githubusercontent.com/stoneb2/Bruhwalker/main/Qiayana/Qiyana.lua"
        local web_version = http:get("https://raw.githubusercontent.com/stoneb2/Bruhwalker/main/Qiayana/Qiyana.version.txt")
        console:log("BenBM Version: "..Version)
        console:log("BenBM Web Version: "..tonumber(web_version))
        if tonumber(web_version) == Version then
            console:log("BenBM Library successfully loaded")
        else
            http:download_file(url, file_name)
            console:log("New BenBM Update Available")
            console:log("Please Reload with F5")
        end
    end
    AutoUpdate()
end

local file_name = "VectorMath.lua"
if not file_manager:file_exists(file_name) then
   local url = "https://raw.githubusercontent.com/stoneb2/Bruhwalker/main/VectorMath/VectorMath.lua"
   http:download_file(url, file_name)
   console:log("VectorMath Library Downloaded")
   console:log("Please Reload with F5")
end

local ml = require "VectorMath"

local_player = game.local_player

team = tonumber(local_player.team)

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

ally_champs = GetAllyHeroes()
ally_table = {}
for index, ally in pairs(ally_champs) do
    ally_table[index] = tostring(ally_champs[index].champ_name)
end

BM = menu:add_category("Ben's BM Tool")
enabled = menu:add_checkbox("Enabled", BM, 0)

flash_enable = menu:add_checkbox("Flash Mastery", BM, 0)
flash_settings = menu:add_subcategory("Flash Mastery Settings", BM)
flash_kill = menu:add_checkbox("Flash Mastery on Kill", flash_settings, 0)
flash_assist = menu:add_checkbox("Flash Mastery on Assist", flash_settings, 0)
flash_death = menu:add_checkbox("Flash Mastery on Death", flash_settings, 0)

question_mark_enable = menu:add_checkbox("Send ? in All Chat", BM, 0)
question_mark_settings = menu:add_subcategory("Send ? in All Chat Settings", BM)
question_mark_kill = menu:add_checkbox("Send ? in All Chat on Kill", question_mark_settings, 0)

question_mark_ping_enable = menu:add_checkbox("Question Mark Ping", BM, 0)
question_mark_ping_settings = menu:add_subcategory("Question Mark Ping Settings", BM)
question_mark_ping_death = menu:add_checkbox("Question Mark Ping Ally Deaths", question_mark_ping_settings, 0)
question_mark_ping_death_settings = menu:add_subcategory("Question Ping Ally Deaths Settings", question_mark_ping_settings)
question_mark_ping_max_pings = menu:add_slider("Max Pings Per Ally", question_mark_ping_settings, 1, 6, 1)
question_mark_ping_all = menu:add_checkbox("Ping All Allies", question_mark_ping_death_settings, 0)
if #ally_champs > 0 then
    question_mark_ping_ally1 = menu:add_checkbox("Ping "..tostring(ally_champs[1].champ_name), question_mark_ping_death_settings, 0)
end
if #ally_champs > 1 then
    question_mark_ping_ally2 = menu:add_checkbox("Ping "..tostring(ally_champs[2].champ_name), question_mark_ping_death_settings, 0)
end
if #ally_champs > 2 then
    question_mark_ping_ally3 = menu:add_checkbox("Ping "..tostring(ally_champs[3].champ_name), question_mark_ping_death_settings, 0)
end
if #ally_champs > 4 then
    question_mark_ping_ally4 = menu:add_checkbox("Ping "..tostring(ally_champs[4].champ_name), question_mark_ping_death_settings, 0)
end

run_it = menu:add_checkbox("Run it Down Mid", BM, 0)

follow_ally = menu:add_checkbox("Follow Ally", BM, 0)
follow_settings = menu:add_subcategory("Follow Ally Settings", BM)
follow_who = menu:add_combobox("Who to follow: ", follow_settings, ally_table, 0)
follow_dead_table = {}
follow_dead_table[1] = "Walk to Base"
follow_dead_table[2] = "Follow Next Closest Ally"
follow_dead_table[3] = "Run It Down"
follow_dead_settings = menu:add_combobox("Follow Ally Is Dead Settings: ", follow_settings, follow_dead_table, 0)

ff = menu:add_checkbox("Try to FF on Death", BM, 0)
gg = menu:add_checkbox("GG Message At End of Game", BM, 0)

local function ClosestLivingAlly()
    local allies = GetAllyHeroes()
    local closestDistance = 999999
    local closestAlly = nil
    for _, ally in pairs(allies) do
        if ally then
            if ally.is_alive then
                if local_player:distance_to(ally.origin) < closestDistance then
                    closestAlly = ally
                    closestDistance = local_player:distance_to(ally.origin)
                end
            end
        end
    end
    return closestAlly
end

local function follow()
    local ally_list = GetAllyHeroes()
    for _, v in pairs(ally_list) do
        if tostring(v.champ_name) == ally_table[menu:get_value(follow_who) + 1] then
            if not v.is_alive then
                if menu:get_value(follow_dead_settings) == 0 then
                    if team == 100 then
                        orbwalker:move_to(406.83, 182.13, 379.81)
                    else
                        orbwalker:move_to(14298, 171.978, 14338)
                    end
                elseif menu:get_value(follow_dead_settings) == 1 then
                    local closestAlly = ClosestLivingAlly()
                    if closestAlly then
                        orbwalker:move_to(closestAlly.origin.x, closestAlly.origin.y, closestAlly.origin.z)
                    else
                        if team == 100 then
                            orbwalker:move_to(406.83, 182.13, 379.81)
                        else
                            orbwalker:move_to(14298, 171.978, 14338)
                        end
                    end
                elseif menu:get_value(follow_dead_settings) == 2 then
                    if team == 100 then
                        orbwalker:move_to(14298, 171.978, 14338)
                    else
                        orbwalker:move_to(406.83, 182.13, 379.81)
                    end
                end
            end
            if v.is_recalling then
                if team == 100 then
                    orbwalker:move_to(406.83, 182.13, 379.81)
                else
                    orbwalker:move_to(14298, 171.978, 14338)
                end
            else
                orbwalker:move_to(v.origin.x, v.origin.y, v.origin.z)
            end
        end
    end
end

local function run_down()
    if team == 100 then
        orbwalker:move_to(14298, 171.978, 14338)
    else
        orbwalker:move_to(406.83, 182.13, 379.81)
    end
end

local function on_kda_updated(kill, death, assist)
    if menu:get_value(enabled) == 1 then
        if kill then
            if menu:get_value(flash_enable) == 1 then
                if menu:get_value(flash_kill) == 1 then
                    game:mastery_display()
                end
                if menu:get_value(question_mark_enable) == 1 then
                    if menu:get_value(question_mark_kill) == 1 then
                        game:send_chat("/all ?")
                    end
                end
            end
        end
        if death then
            if menu:get_value(flash_enable) == 1 then
                if menu:get_value(flash_death) == 1 then
                    game:mastery_display()
                end
            end
        end
        if assist then
            if menu:get_value(flash_enable) == 1 then
                if menu:get_value(flash_assist) == 1 then
                    game:mastery_display()
                end
            end
        end
    end
end

local ally1_count = 0
local ally2_count = 0
local ally3_count = 0
local ally4_count = 0
local function on_tick()
    if menu:get_value(enabled) == 1 then
        if menu:get_value(run_it) == 1 then
            menu:set_value(follow_ally, 0)
            run_down()
        end
        if menu:get_value(follow_ally) == 1 then
            menu:set_value(run_it, 0)
            follow()
        end
        if menu:get_value(question_mark_ping_enable) == 1 then
            if menu:get_value(question_mark_ping_death) == 1 then
                local ally_table = GetAllyHeroes()
                for index, ally in pairs(ally_table) do
                    if index == 1 then
                        if not ally_table[1].is_alive then
                            if ally1_count < menu:get_value(question_mark_ping_max_pings) then
                                game:send_ping(ally_table[1].origin.x, ally_table[1].origin.y, ally_table[1].origin.z, PING_MISSING)
                                ally1_count = ally1_count + 1
                            end
                        else
                            ally1_count = 0
                        end
                    elseif index == 2 then
                        if not ally_table[2].is_alive then
                            if ally2_count < menu:get_value(question_mark_ping_max_pings) then
                                game:send_ping(ally_table[2].origin.x, ally_table[2].origin.y, ally_table[2].origin.z, PING_MISSING)
                                ally2_count = ally2_count + 1
                            end
                        else
                            ally2_count = 0
                        end
                    elseif index == 3 then
                        if not ally_table[3].is_alive then
                            if ally3_count < menu:get_value(question_mark_ping_max_pings) then
                                game:send_ping(ally_table[3].origin.x, ally_table[3].origin.y, ally_table[3].origin.z, PING_MISSING)
                                ally3_count = ally3_count + 1
                            end
                        else
                            ally3_count = 0
                        end
                    elseif index == 4 then
                        if not ally_table[4].is_alive then
                            if ally4_count < menu:get_value(question_mark_ping_max_pings) then
                                game:send_ping(ally_table[4].origin.x, ally_table[4].origin.y, ally_table[4].origin.z, PING_MISSING)
                                ally4_count = ally4_count + 1
                            end
                        else
                            ally4_count = 0
                        end
                    end
                end
            end
        end
    end
end

local function on_death()
    if menu:get_value(enabled) == 1 then
        if menu:get_value(ff) == 1 then
            game:send_chat("/ff")
        end
    end
end

local function on_game_end()
    if menu:get_value(enabled) == 1 then
        game:send_chat("GGWP! :)")
    end
end

client:set_event_callback("on_kda_updated", on_kda_updated)
client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_death", on_death)
client:set_event_callback("on_game_end", on_game_end)