do
    local function AutoUpdate()
        local Version = 1
        local file_name = "ScriptDetector.lua"
        local url = "https://raw.githubusercontent.com/stoneb2/Bruhwalker/main/ScriptDetector/ScriptDetector.lua"
        local web_version = http:get("https://raw.githubusercontent.com/stoneb2/Bruhwalker/main/ScriptDetector/ScriptDetector.version.txt")
        console:log("ScriptDetector Version: " .. Version)
        console:log("ScriptDetector Web Version: " .. tonumber(web_version))
        if tonumber(web_version) == Version then
            console:log("ScriptDetector successfully loaded")
        else
            http:download_file(url, file_name)
            console:log("New ScriptDetector Update Available")
            console:log("Please Reload with F5")
        end
    end
    AutoUpdate()
end

local_player = game.local_player

waypoints = menu:add_category("Script Detector")
time_limit_slider = menu:add_slider("Average Time Length", waypoints, 1, 20, 5, "Time interval to collect waypoints. Works best at 5 seconds, do not recommend changing.")
waypoint_draw = menu:add_checkbox("Draw Clicks per Second Below Champions", waypoints, 1)
color_settings = menu:add_subcategory("Color Settings", waypoints)
color_r = menu:add_slider("R", color_settings, 0, 255, 255)
color_g = menu:add_slider("G", color_settings, 0, 255, 255)
color_b = menu:add_slider("B", color_settings, 0, 255, 255)
color_a = menu:add_slider("Alpha", color_settings, 0, 255, 255)

cheater_list = {}
for i, player in ipairs(game.players) do
    cheater_list[player.object_id] = false
end

tracker = {}
for i, player in ipairs(game.players) do
    tracker[player.object_id] = {
        path = {},
        time = {}
    }
end

local function IsValid(unit)
    if (unit and unit.is_alive and unit.is_visible and unit.object_id and unit.health > 0) then
        return true
    end
    return false
end

averages = {}
local function on_new_path(obj, path)
    if IsValid(obj) then
        for i, player in ipairs(game.players) do
            if player.object_id == obj.object_id then
                table.insert(tracker[obj.object_id].path, path)
                table.insert(tracker[obj.object_id].time, game.game_time)
            end
        end
    end
end

local function on_draw()
    for i, player in pairs(tracker) do
        for j, time in pairs(player) do
            for k, actual_time in pairs(time) do
                if type(actual_time) == "number" then
                    if actual_time <= game.game_time - menu:get_value(time_limit_slider) then
                        table.remove(tracker[i].path, k)
                        table.remove(tracker[i].time, k)
                    end
                end
            end
        end
    end
    for i, player in pairs(tracker) do
        averages[i] = #player.time / menu:get_value(time_limit_slider)
        if averages[i] > 10 and not cheater_list[i] and i ~= local_player.object_id then
            cheater_list[i] = true
            champ_name = game:get_object(i).champ_name
            game:print_chat("<font color='#9a7aa0'>" .. tostring(champ_name) .. " is scripting!!!!!!</font>")
        end
    end
    if menu:get_value(waypoint_draw) == 1 then
        for i, player in ipairs(game.players) do
            if player.is_visible and player.is_alive then
                if averages[player.object_id] then
                    if player.object_id == local_player.object_id then
                        x, y = game:world_to_screen_2(player.origin.x, player.origin.y, player.origin.z).x, game:world_to_screen_2(player.origin.x, player.origin.y, player.origin.z - 25).y
                    else
                        x, y = game:world_to_screen_2(player.origin.x, player.origin.y, player.origin.z).x, game:world_to_screen_2(player.origin.x, player.origin.y, player.origin.z).y
                    end
                    renderer:draw_text_centered(x, y, tostring(averages[player.object_id]), menu:get_value(color_r), menu:get_value(color_g), menu:get_value(color_b), menu:get_value(color_a))
                end
            end
        end
    end
end

client:set_event_callback("on_new_path", on_new_path)
client:set_event_callback("on_draw", on_draw)
