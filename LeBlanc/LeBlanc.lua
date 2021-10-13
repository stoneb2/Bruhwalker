if game.local_player.champ_name ~= "Leblanc" then
    return
end

do
    local function RequirementDownload()
        local file_name = "VectorMath.lua"
        local count = 0
        if not file_manager:file_exists(file_name) then
            local url = "https://raw.githubusercontent.com/stoneb2/Bruhwalker/main/VectorMath/VectorMath.lua"
            http:download_file(url, file_name)
            count = count + 1
            console:log("VectorMath Library Downloaded")
            console:log("Please Reload with F5")
        end

        local file_name = "Prediction.lib"
        if not file_manager:file_exists(file_name) then
            local url = "https://raw.githubusercontent.com/Ark223/Bruhwalker/main/Prediction.lib"
            http:download_file(url, file_name)
            count = count + 1
            console:log("Ark Prediction Downloaded")
            console:log("Please Reload with F5")
        end

        if count > 0 then
            return
        end
    end
    RequirementDownload()
end

local ml = require "VectorMath"
local arkpred = _G.Prediction

local_player = game.local_player

lb = menu:add_category("LeBlanc")
lb_enabled = menu:add_checkbox("Enabled", lb, 1)
combokey = menu:add_keybinder("Combo Key", lb, 32)

combo_settings = menu:add_subcategory("Combo Settings", lb)
combo_enabled = menu:add_checkbox("Enable", combo_settings, 1)
q_settings = menu:add_subcategory("Q Settings", combo_settings)
use_q = menu:add_checkbox("Use Q", q_settings, 1)
w_settings = menu:add_subcategory("W Settings", combo_settings)
use_w = menu:add_checkbox("Use W", w_settings, 1)
smart_w = menu:add_checkbox("Smart W Return (try it out, but don't recommend)", w_settings, 0)
gap_close = menu:add_checkbox("Gap Close", w_settings, 1)
e_settings = menu:add_subcategory("E Settings", combo_settings)
use_e = menu:add_checkbox("Use E", e_settings, 1)
r_settings = menu:add_subcategory("R Settings", combo_settings)
use_r = menu:add_checkbox("Use R", r_settings, 1)

harass_settings = menu:add_subcategory("Harass Settings", lb)
harass_enabled = menu:add_checkbox("Enable", harass_settings, 1)

clear_settings = menu:add_subcategory("Lane Clear", lb)
clear_q = menu:add_checkbox("Use Q", clear_settings, 1)
clear_q_mana = menu:add_slider("Minimum Mana to Use Q", clear_settings, 0, 100, 30)
clear_w = menu:add_checkbox("Use W", clear_settings, 1)
clear_w_mana = menu:add_slider("Minimum Mana to Use W", clear_settings, 0, 100, 30)
clear_w_min_num = menu:add_slider("Minimum Hit to Use W", clear_settings, 0, 7, 2)
clear_e = menu:add_checkbox("Use E", clear_settings, 1)
clear_e_mana = menu:add_slider("Minimum Mana to Use E", clear_settings, 0, 100, 30)

killsteal_settings = menu:add_subcategory("Killsteal Settings", lb)
killsteal_enabled = menu:add_checkbox("Enable", killsteal_settings, 1)

draw_settings = menu:add_subcategory("Draw Settings", lb)
drawings_enabled = menu:add_checkbox("Enable", draw_settings, 1)
draw_dmg = menu:add_checkbox("Draw Combo Damage on Healthbar", draw_settings, 1)
draw_targets = menu:add_checkbox("Label Targets By Priority", draw_settings, 1)
draw_q = menu:add_checkbox("Draw Q Range", draw_settings, 1)
draw_q_color = menu:add_subcategory("Draw Q Color", draw_settings)
draw_q_R = menu:add_slider("Q RGB Red", draw_q_color, 0, 255, 255)
draw_q_B = menu:add_slider("Q RGB Green", draw_q_color, 0, 255, 255)
draw_q_G = menu:add_slider("Q RGB Blue", draw_q_color, 0, 255, 255)
draw_w = menu:add_checkbox("Draw W Range", draw_settings, 1)
draw_w_color = menu:add_subcategory("Draw W Color", draw_settings)
draw_w_R = menu:add_slider("W RGB Red", draw_w_color, 0, 255, 255)
draw_w_B = menu:add_slider("W RGB Green", draw_w_color, 0, 255, 255)
draw_w_G = menu:add_slider("W RGB Blue", draw_w_color, 0, 255, 255)
draw_e = menu:add_checkbox("Draw E Range", draw_settings, 1)
draw_e_color = menu:add_subcategory("Draw E Color", draw_settings)
draw_e_R = menu:add_slider("E RGB Red", draw_e_color, 0, 255, 255)
draw_e_G = menu:add_slider("E RGB Green", draw_e_color, 0, 255, 255)
draw_e_B = menu:add_slider("E RGB Blue", draw_e_color, 0, 255, 255)
draw_r = menu:add_checkbox("Draw R Range", draw_settings, 1)
draw_r_color = menu:add_subcategory("Draw R Color", draw_settings)
draw_r_R = menu:add_slider("R RGB Red", draw_r_color, 0, 255, 255)
draw_r_G = menu:add_slider("R RGB Red", draw_r_color, 0, 255, 255)
draw_r_B = menu:add_slider("R RGB Red", draw_r_color, 0, 255, 0)

do
    local function AutoUpdate()
        local Version = 1
        local file_name = "LeBlanc.lua"
        local url = "https://raw.githubusercontent.com/stoneb2/Bruhwalker/main/LeBlanc/LeBlanc.lua"
        local web_version = http:get("https://raw.githubusercontent.com/stoneb2/Bruhwalker/main/LeBlanc/LeBlanc.version.txt")
        console:log("LeBlanc Version: "..Version)
        console:log("LeBlanc Web Version: "..tonumber(web_version))
        if tonumber(web_version) == Version then
            console:log("LeBlanc Library successfully loaded")
        else
            http:download_file(url, file_name)
            console:log("New LeBlanc Update Available")
            console:log("Please Reload with F5")
        end
    end
    AutoUpdate()
end

local W_return_pos = nil
local RW_return_pos = nil

local function on_object_created(object, obj_name)
    if obj_name == "LeBlanc_Base_W_return_indicator" then
        W_return_pos = vec3.new(object.origin.x, object.origin.y, object.origin.z)
    elseif obj_name == "LeBlanc_Base_RW_return_indicator" then
        RW_return_pos = vec3.new(object.origin.x, object.origin.y, object.origin.z)
    elseif obj_name == "Leblanc_Base_W_return_indicator_death" then
        W_return_pos = nil
    elseif obj_name == "Leblanc_Base_RW_return_indicator_death" then
        RW_return_pos = nil
    end
end

local spellQ = {
    range = 700,
    speed = 2000,
    delay = 0.25
}

local spellW = {
    range = 600,
    effect_radius = 240,
    speed = 1450,
    delay = 0.1
}

local w_input = {
    source = local_player,
    speed = spellW.speed, range = spellW.range,
    delay = spellW.delay, radius = spellW.effect_radius,
    collision = {}, type = "circular",
    hitbox = true
}

local spellE = {
    range = 950,
    width = 110,
    tether_radius = 865,
    speed = 1750,
    delay = 0.25
}

local e_input = {
    source = local_player,
    speed = spellE.speed, range = spellE.range,
    delay = spellE.delay, radius = spellE.width,
    collision = {"minion", "enemy_hero", "wind_wall"}, type = "linear",
    hitbox = true
}

local function HasSigil(target)
    if target:has_buff("LeblancQMark") or target:has_buff("LeblancRQMark") then
        return true
    end
    return false
end

local function WReturn()
    if local_player:has_buff("LeblancW") then
        return true
    end
    return false
end

local function RWReturn()
    if local_player:has_buff("LeblancRW") then
        return true
    end
    return false
end

local function WUsed()
    if WReturn() or RWReturn() then
        return true
    end
    return false
end

local function RSpell()
    local name = tostring(spellbook:get_spell_slot(SLOT_R).spell_data.spell_name)
    if name == "LeblancRQ" then
        return "Q"
    elseif name == "LeblancRW" then
        return "W"
    elseif name == "LeblancRE" then
        return "E"
    end
end

local function SigilDmg(target)
    local dmg = 0
    local level = 0
    if target:has_buff("LeblancQMark") then
        level = spellbook:get_spell_slot(SLOT_Q).level
        if level ~= 0 then
            dmg = ({65, 90, 115, 140, 165})[level] + (0.4 * local_player.ability_power)
        end
        return target:calculate_magic_damage(dmg)
    elseif target:has_buff("LeblancRQMark") then
        level = spellbook:get_spell_slot(SLOT_R).level
        if level ~= 0 then
            dmg = 2 * (({70, 140, 210})[level] + (0.4 * local_player.ability_power))
        end
        return target:calculate_magic_damage(dmg)
    end
end

local function QDmg(target)
    local dmg = 0
    local level = spellbook:get_spell_slot(SLOT_Q).level
    dmg = ({65, 90, 115, 140, 165})[level] + (0.4 * local_player.ability_power)
    return target:calculate_magic_damage(dmg)
end

local function WDmg(target)
    local dmg = 0
    local level = spellbook:get_spell_slot(SLOT_W).level
    dmg = ({75, 115, 155, 195, 235})[level] + (0.6 * local_player.ability_power)
    return target:calculate_magic_damage(dmg)
end

local function EDmg(target)
    local dmg1 = 0
    local dmg2 = 0
    local dmg = 0
    local level = spellbook:get_spell_slot(SLOT_E).level
    dmg1 = ({50, 70, 90, 110, 130})[level] + (0.3 * local_player.ability_power)
    dmg2 = ({80, 120, 160, 200, 240})[level] + (0.7 * local_player.ability_power)
    dmg = dmg1 + dmg2
    return target:calculate_magic_damage(dmg), target:calculate_magic_damage(dmg1), target:calculate_magic_damage(dmg2)
end

local function RQDmg(target)
    local dmg = 0
    local level = spellbook:get_spell_slot(SLOT_R).level
    dmg = ({70, 140, 210})[level] + (0.4 * local_player.ability_power)
    return target:calculate_magic_damage(dmg)
end

local function RWDmg(target)
    local dmg = 0
    local level = spellbook:get_spell_slot(SLOT_R).level
    dmg = ({150, 300, 450})[level] + (0.75 * local_player.ability_power)
    return target:calculate_magic_damage(dmg)
end

local function REDmg(target)
    local dmg1 = 0
    local dmg2 = 0
    local dmg = 0
    local level = spellbook:get_spell_slot(SLOT_R).level
    dmg1 = ({70, 140, 210})[level] + (0.4 * local_player.ability_power)
    dmg2 = 2 * (({70, 140, 210})[level] + (0.4 * local_player.ability_power))
    dmg = dmg1 + dmg2
    return target:calculate_magic_damage(dmg), target:calculate_magic_damage(dmg1), target:calculate_magic_damage(dmg2)
end

local function CastQ(target)
    --local x, y, z = target.origin.x, target.origin.y, target.origin.z
    --spellbook:cast_spell(SLOT_Q, spellQ.delay, x, y, z)
    spellbook:cast_spell_targetted(SLOT_Q, target, spellQ.delay)
end

local function CastW(pos)
    if WReturn() then
        return
    end
    local x, y, z = pos.x, pos.y, pos.z
    spellbook:cast_spell(SLOT_W, spellW.delay, x, y, z)
end

local function CastE(pos)
    local x, y, z = pos.x, pos.y, pos.z
    spellbook:cast_spell(SLOT_E, spellE.delay, x, y, z)
end

local function CastRQ(target)
    --local x, y, z = target.origin.x, target.origin.y, target.origin.z
    --spellbook:cast_spell(SLOT_R, spellQ.delay, x, y, z)
    spellbook:cast_spell_targetted(SLOT_R, target, spellQ.delay)
end

local function CastRW(pos)
    if RWReturn() then
        return
    end
    local x, y, z = pos.x, pos.y, pos.z
    spellbook:cast_spell(SLOT_R, spellW.delay, x, y, z)
end

local function CastRE(pos)
    local x, y, z = pos.x, pos.y, pos.z
    spellbook:cast_spell(SLOT_R, spellE.delay, x, y, z)
end

local function CastGPW(target)
    if spellbook:get_spell_slot(SLOT_W).spell_data.spell_name == "LeblancWReturn" then
        return
    end
    local x, y, z = target.origin.x, target.origin.y, target.origin.z
    if not WReturn() then
        if local_player:distance_to(target.origin) < 1200 and local_player:distance_to(target.origin) > 700 and ml.Ready(SLOT_W) then
            if not nav_mesh:is_wall(x, y, z) then
                spellbook:cast_spell(SLOT_W, spellW.delay, x, y, z)
            end
        end
    end
end

local function CastGPR(target)
    local r_spell = RSpell()
    local x, y, z = target.origin.x, target.origin.y, target.origin.z
    if ml.Ready(SLOT_Q) and local_player:distance_to(target.origin) < 1200 and local_player:distance_to(target.origin) > 700 and ml.Ready(SLOT_R) and r_spell == "W" then
        if not nav_mesh:is_wall(x, y, z) then
            spellbook:cast_spell(SLOT_R, spellW.delay, x, y, z)
        end
    end
end

local function ComboDmg(target)
    local p_damage = 0
    local q_damage = 0
    local w_damage = 0
    local e_damage = 0
    local r_damage = 0
    local elec_damage = 0
    if local_player:has_perk(Electrocute) then
        if local_player:has_buff("ASSETS/Perks/Styles/Domination/Electrocute/Electrocute.lua") then
            local level = local_player.level
            elec_damage = ({30, 38.82, 47.65, 56.47, 65.29, 74.12, 82.94, 91.76, 100.59, 109.41, 118.24, 127.06, 135.88, 144.71, 153.53, 162.35, 171.18, 180})[level] + (0.4 * local_player.bonus_attack_damage) + (0.25 * local_player.bonus_attack_damage)
        end
    end
    if HasSigil(target) then
        p_damage = SigilDmg(target)
    end
    if ml.Ready(SLOT_Q) then
        q_damage = QDmg(target)
    end
    if ml.Ready(SLOT_W) then
        w_damage = WDmg(target)
    end
    if ml.Ready(SLOT_E) then
        e_damage, x, y = EDmg(target)
    end
    if ml.Ready(SLOT_R) then
        r_damage = RQDmg(target)
    end
    local total_dmg = p_damage + q_damage + w_damage + e_damage + r_damage + elec_damage
    Damage = target:calculate_magic_damage(total_dmg)
    return Damage
end

local function NoReadyComboDmg(target)
    local q_damage = 0
    local w_damage = 0
    local e_damage = 0
    local r_damage = 0
    local elec_damage = 0
    if local_player:has_perk(Electrocute) then
        if local_player:has_buff("ASSETS/Perks/Styles/Domination/Electrocute/Electrocute.lua") then
            local level = local_player.level
            elec_damage = ({30, 38.82, 47.65, 56.47, 65.29, 74.12, 82.94, 91.76, 100.59, 109.41, 118.24, 127.06, 135.88, 144.71, 153.53, 162.35, 171.18, 180})[level] + (0.4 * local_player.bonus_attack_damage) + (0.25 * local_player.bonus_attack_damage)
        end
    end
    local ql = spellbook:get_spell_slot(SLOT_Q).level
    local wl = spellbook:get_spell_slot(SLOT_W).level
    local el = spellbook:get_spell_slot(SLOT_E).level
    local rl = spellbook:get_spell_slot(SLOT_R).level
    if ql > 0 then
        q_damage = QDmg(target)
    end
    if wl > 0 then
        w_damage = WDmg(target)
    end
    if el > 0 then
        e_damage, x, y = EDmg(target)
    end
    if rl > 0 then
        r_damage = RQDmg(target)
    end
    local total_dmg = q_damage + w_damage + e_damage + r_damage + elec_damage
    Damage = target:calculate_magic_damage(total_dmg)
    return Damage
end

local function sort_relative(ref, t, cmp)
    local n = #ref
    assert(#t == n)
    local r = {}
    for i = 1, n do 
        r[i] = i 
    end
    if not cmp then 
        cmp = function(a, b) 
            return a < b 
        end 
    end
    table.sort(r, function(a, b) return cmp(ref[a], ref[b]) end)
    for i = 1,n do 
        r[i] = t[r[i]] 
    end
    return r
end

local function size(tab)
    local count = 0
    for _ in pairs(tab) do
        count = count + 1
    end
    return count
end

local function GetFirst(tab)
    if tab[0] ~= nil then
        return tab[0]
    else
        return tab[1]
    end
end

local function PriorityList(range)
    local priority_list = {}
    local one_shot_champs = {}
    local one_shot_health = {}
    local not_one_shot_champs = {}
    local not_one_shot_health = {}
    local enemies, count  = ml.GetEnemyCount(local_player.origin, range)
    if count > 0 then
        for i, enemy in pairs(enemies) do
            if ml.IsValid(enemy) and enemy.is_alive then
                local combo_dmg = ComboDmg(enemy)
                local shielded_health = ml.GetShieldedHealth("AP", enemy)
                if combo_dmg > (enemy.health + shielded_health) then
                    table.insert(one_shot_champs, enemy)
                    local difficulty_factor = enemy.mr * enemy.armor * enemy.health
                    table.insert(one_shot_health, tonumber(difficulty_factor))
                else
                    table.insert(not_one_shot_champs, enemy)
                    local difficulty_factor = enemy.mr * enemy.armor * enemy.health
                    table.insert(not_one_shot_health, tonumber(difficulty_factor))
                end
            end
        end
        if #one_shot_champs > 0 then
            local one_shot_sorted = sort_relative(one_shot_health, one_shot_champs)
            for i, champ in pairs(one_shot_sorted) do
                table.insert(priority_list, champ)
            end
        end
        if size(not_one_shot_champs) > 0 then
            local not_one_shot_sorted = sort_relative(not_one_shot_health, not_one_shot_champs)
            for i, champ in pairs(not_one_shot_sorted) do
                table.insert(priority_list, champ)
            end
        end
    end
    return priority_list
end

local function SelectTarget(range)
    local target = GetFirst(PriorityList(range))
    return target
end

local function Combo()
    local wPriority = (spellbook:get_spell_slot(SLOT_W).level > spellbook:get_spell_slot(SLOT_W).level) or false
    if menu:get_value(gap_close) == 1 and local_player.level > 5 then
        local target_range = spellE.range
        if not ml.Ready(SLOT_E) then
            if ml.Ready(SLOT_Q) then
                target_range = spellQ.range
            else
                target_range = spellW.range
            end
        end
        local target = SelectTarget(target_range)
        if selector:get_focus_target() and ml.IsValid(selector:get_focus_target()) then
            target = selector:get_focus_target()
        end
        if target and ml.IsValid(target) and not target:has_buff("sionpassivezombie") then
            local dist = local_player:distance_to(target.origin)
            if dist <= 1300 and not wPriority then
                if not WReturn() then
                    if target:distance_to(local_player.origin) < 600 and ml.Ready(SLOT_W) then
                        local target_pos = vec3.new(target.origin.x, target.origin.y, target.origin.z)
                        CastW(target_pos)
                    elseif spellbook:get_spell_slot(SLOT_W).spell_data.name == "LeblancW" and not WReturn() then
                        if not WReturn() then
                            if ml.Ready(SLOT_W) and local_player:distance_to(target.origin) < 1200 then
                                local output = arkpred:get_prediction(w_input, target)
                                local inv = arkpred:get_invisible_duration(target)
                                if output.hit_chance > 0.5 and inv < 0.125 then
                                    local cast_pos = vec3.new(output.cast_pos.x, output.cast_pos.y, output.cast_pos.z)
                                    if cast_pos then
                                        CastW(cast_pos)
                                    end
                                end
                            end
                        end
                    end
                end
                if ml.Ready(SLOT_Q) and dist <= 710 then
                    CastQ(target)
                end
                if ml.Ready(SLOT_R) and dist <= 710 and RSpell() == "Q" then
                    CastRQ(target)
                end
                if (ml.Ready(SLOT_E) and dist <= 865) or HasSigil(target) then
                    local output = arkpred:get_prediction(e_input, target)
                    local inv = arkpred:get_invisible_duration(target)
                    if output.hit_chance > 0.5 and inv < 0.125 then
                        local cast_pos = vec3.new(output.cast_pos.x, output.cast_pos.y, output.cast_pos.z)
                        if cast_pos and ml.Ready(SLOT_E) then
                            CastE(cast_pos)
                        end
                    end
                end 
            elseif dist <= 1200 and wPriority then
                if not WReturn() then
                    if ml.Ready(SLOT_Q) and target:distance_to(local_player.origin) < 1200 and dist > 700 and not WReturn() and ml.Ready(SLOT_W) then
                        CastQ(target)
                    elseif dist < 600 and ml.Ready(SLOT_W) then
                        local output = arkpred:get_prediction(w_input, target)
                        local inv = arkpred:get_invisible_duration(target)
                        if output.hit_chance > 0.5 and inv < 0.125 then
                            local cast_pos = vec3.new(output.cast_pos.x, output.cast_pos.y, output.cast_pos.z)
                            if cast_pos then
                                CastW(cast_pos)
                            end
                        end
                    end
                end
                if ml.Ready(SLOT_R) and dist <= 750 and WReturn() and RSpell() == "W" and not RWReturn() then
                    local output = arkpred:get_prediction(w_input, target)
                    local inv = arkpred:get_invisible_duration(target)
                    if output.hit_chance > 0.5 and inv < 0.125 then
                        local cast_pos = vec3.new(output.cast_pos.x, output.cast_pos.y, output.cast_pos.z)
                        if cast_pos then
                            CastRW(cast_pos)
                        end
                    end
                end
                if ml.Ready(SLOT_Q) and dist <= 700 and RWReturn() then
                    CastQ(target)
                end
                if (ml.Ready(SLOT_E) and dist <= 865 and RWReturn()) or HasSigil(target) then
                    local output = arkpred:get_prediction(e_input, target)
                    local inv = arkpred:get_invisible_duration(target)
                    if output.hit_chance > 0.5 and inv < 0.125 then
                        local cast_pos = vec3.new(output.cast_pos.x, output.cast_pos.y, output.cast_pos.z)
                        if cast_pos and ml.Ready(SLOT_E) then
                            CastE(cast_pos)
                        end
                    end
                end
            end
        end
    elseif menu:get_value(gap_close) == 1 then
        local target = SelectTarget()
        if selector:get_focus_target() and ml.IsValid(selector:get_focus_target()) then
            target = selector:get_focus_target()
        end
        if target and ml.IsValid(target) and not target:has_buff("sionpassivezombie") then
            local dist = local_player:distance_to(target.origin)
            if dist <= 865 and not wPriority then
                if ml.Ready(SLOT_E) then
                    local output = arkpred:get_prediction(e_input, target)
                    local inv = arkpred:get_invisible_duration(target)
                    if output.hit_chance > 0.5 and inv < 0.125 then
                        local cast_pos = vec3.new(output.cast_pos.x, output.cast_pos.y, output.cast_pos.z)
                        if cast_pos then
                            CastE(cast_pos)
                        end
                    end
                end
                if ml.Ready(SLOT_Q) and dist <= 710 then
                    CastQ(target)
                end
                local r_spell = RSpell()
                if ml.Ready(SLOT_R) and dist <= 710 and r_spell == "Q" and HasSigil(target) then
                    CastRQ(target)
                end 
                if (ml.Ready(SLOT_W) and not WReturn() and dist <= 750) or HasSigil(target) then
                    local output = arkpred:get_prediction(w_input, target)
                    local inv = arkpred:get_invisible_duration(target)
                    if output.hit_chance > 0.5 and inv < 0.125 then
                        local cast_pos = vec3.new(output.cast_pos.x, output.cast_pos.y, output.cast_pos.z)
                        if cast_pos and ml.Ready(SLOT_W) and not WReturn() then
                            CastW(cast_pos)
                        end
                    end
                end
            elseif dist <= 865 and wPriority then
                if ml.Ready(SLOT_W) and not WReturn() and dist <= 750 then
                    local output = arkpred:get_prediction(w_input, target)
                    local inv = arkpred:get_invisible_duration(target)
                    if output.hit_chance > 0.5 and inv < 0.125 then
                        local cast_pos = vec3.new(output.cast_pos.x, output.cast_pos.y, output.cast_pos.z)
                        if cast_pos then
                            CastW(cast_pos)
                        end
                    end
                end
                local r_spell = RSpell()
                if ml.Ready(SLOT_R) and dist <= 750 and WReturn() and not RWReturn() and r_spell == "W" then
                    local output = arkpred:get_prediction(w_input, target)
                    local inv = arkpred:get_invisible_duration(target)
                    if output.hit_chance > 0.5 and inv < 0.125 then
                        local cast_pos = vec3.new(output.cast_pos.x, output.cast_pos.y, output.cast_pos.z)
                        if cast_pos then
                            CastRW(cast_pos)
                        end
                    end
                end
                if ml.Ready(SLOT_Q) and dist <= 700 and local_player.level < 6 then
                    CastQ(target)
                elseif ml.Ready(SLOT_Q) and not ml.Ready(SLOT_R) then
                    client:delay_function(CastQ(target), 0.4)
                end
                if ml.Ready(SLOT_E) and HasSigil(target) or not ml.Ready(SLOT_Q) then
                    local output = arkpred:get_prediction(e_input, target)
                    local inv = arkpred:get_invisible_duration(target)
                    if output.hit_chance > 0.5 and inv < 0.125 then
                        local cast_pos = vec3.new(output.cast_pos.x, output.cast_pos.y, output.cast_pos.z)
                        if cast_pos then
                            CastE(cast_pos)
                        end
                    end
                end
                if not ml.Ready(SLOT_W) or not ml.Ready(SLOT_E) then
                    local r_spell = RSpell()
                    if ml.Ready(SLOT_R) and r_spell == "Q" then
                        CastRQ(target)
                    end
                end
            end
            local pos = vec3.new(local_player.origin.x, local_player.origin.y, local_player.origin.z)
            local _, count = ml.GetEnemyCount(pos, 300)
            if count > 2 then
                local output = arkpred:get_prediction(w_input, target)
                local inv = arkpred:get_invisible_duration(target)
                if output.hit_chance > 0.5 and inv < 0.125 then
                    local cast_pos = vec3.new(output.cast_pos.x, output.cast_pos.y, output.cast_pos.z)
                    if cast_pos and ml.Ready(SLOT_W) and not WReturn() then
                        CastW(cast_pos)
                    end
                end
                if WReturn() then
                    local output = arkpred:get_prediction(w_input, target)
                    local inv = arkpred:get_invisible_duration(target)
                    if output.hit_chance > 0.5 and inv < 0.125 then
                        local cast_pos = vec3.new(output.cast_pos.x, output.cast_pos.y, output.cast_pos.z)
                        local r_spell = RSpell()
                        if cast_pos and ml.Ready(SLOT_R) and r_spell == "W" and not RWReturn() then
                            CastRW(cast_pos)
                        end
                    end
                end
            end
        end
    end
end

local function SmartW()
    if WReturn() and W_return_pos then
        local target = SelectTarget()
        if selector:get_focus_target() and ml.IsValid(selector:get_focus_target()) then
            target = selector:get_focus_target()
        end
        local _, count_W_return_pos = ml.GetEnemyCount(W_return_pos, 600)
        local _, count_pos = ml.GetEnemyCount(local_player.origin, 600)
        if count_W_return_pos < count_pos then
            if target and ml.IsValid(target) then
                if target.health > NoReadyComboDmg(target) then
                    local player_pos = vec3.new(local_player.origin.x, local_player.origin.y, local_player.origin.z)
                    CastW(player_pos)
                end
            end
        end
    end
end

local function Harass()
    Combo()
    SmartW()
end

local function GetManaPercent()
    local mana_percent = (local_player.mana / local_player.max_mana) * 100
    return mana_percent
end

local function MinionsAround(pos, range)
    local minion_table = {}
    minions = game.minions
    for i, m in ipairs(minions) do
        if m.object_id ~= 0 and m.is_enemy and m.is_alive and m:distance_to(pos) < range then
            table.insert(minion_table, m)
        end
    end
    return minion_table
end

local function GetCenter(points)
    local sum_x = 0
	local sum_z = 0
	for i = 1, #points do
		sum_x = sum_x + points[i].origin.x
		sum_z = sum_z + points[i].origin.z
	end
	local center = {x = sum_x / #points, y = 0, z = sum_z / #points}
	return center
end

local function ContainsThemAll(circle, points)
    local radius_sqr = circle.radi*circle.radi
	local contains_them_all = true
	local i = 1
	while contains_them_all and i <= #points do
		contains_them_all = ml.GetDistanceSqr2(points[i].origin, circle.center) <= radius_sqr
		i = i + 1
	end
	return contains_them_all
end

local function FarthestFromPositionIndex(points, position)
    local index = 2
	local actual_dist_sqr
	local max_dist_sqr = ml.GetDistanceSqr2(points[index].origin, position)
	for i = 3, #points do
		actual_dist_sqr = ml.GetDistanceSqr2(points[i].origin, position)
		if actual_dist_sqr > max_dist_sqr then
			index = i
			max_dist_sqr = actual_dist_sqr
		end
	end
	return index
end

local function RemoveWorst(targets, position)
    local worst_target = FarthestFromPositionIndex(targets, position)
	table.remove(targets, worst_target)
	return targets
end

local function GetInitialTargets(radius, main_target)
    local targets = {main_target}
	local diameter_sqr = 4 * radius * radius
	for i, target in ipairs(ml.GetEnemyHeroes()) do
		if target.object_id ~= 0 and target.object_id ~= main_target.object_id and ml.IsValid(target) and ml.GetDistanceSqr(main_target, target.origin) < diameter_sqr then
			table.insert(targets, target)
		end
	end
	return targets
end

local function GetPredictedInitialTargets(speed, delay, range, radius, main_target, ColWindwall, ColMinion)
	local predicted_main_target = arkpred:predict(speed ,delay, range, radius, main_target, ColWindwall, ColMinion)
	if predicted_main_target.can_cast then
		local predicted_targets = {main_target}
		local diameter_sqr = 4 * radius * radius
		for i, target in ipairs(ml.GetEnemyHeroes()) do
			if target.object_id ~= 0 and ml.IsValid(target) then
				predicted_target = arkpred:predict(math.huge, delay, range, radius, target, false, false)
				if predicted_target.can_cast and target.object_id ~= main_target.object_id and ml.GetDistanceSqr2(predicted_main_target.cast_pos, predicted_target.cast_pos) < diameter_sqr then
					table.insert(predicted_targets, target)
				end
			end
		end
	    return predicted_targets
	end
end

local function GetBestAOEPosition(speed, delay, range, radius, main_target, ColWindwall, ColMinion)
    local targets = GetPredictedInitialTargets(speed ,delay, range, radius, main_target, ColWindwall, ColMinion) or GetInitialTargets(radius, main_target)
	local position = GetCenter(targets)
	local best_pos_found = true
	local circle = {pos = position, radi = radius}
	circle.center = position
	if #targets >= 2 then best_pos_found = ContainsThemAll(circle, targets) end
	while not best_pos_found do
		targets = RemoveWorst(targets, position)
		position = GetCenter(targets)
		circle.center = position
		best_pos_found = ContainsThemAll(circle, targets)
	end
	return vec3.new(position.x, position.y, position.z), #targets
end

local function GetBestCircularFarmPos(unit, range, radius)
    local BestPos = nil
    local MostHit = 0
    minions = game.minions
    for i, m in ipairs(minions) do
        if m.object_id ~= 0 and m.is_enemy and m.is_alive and unit:distance_to(m.origin) < range then
            local Count = MinionsAround(m.origin, radius)
            if #Count > MostHit then
                MostHit = #Count
                BestPos = m.origin
            end
        end
    end
    return BestPos, MostHit
end

local function SiegeMinion(unit)
    if string.find(unit.champ_name, "MinionSiege") then
        return true
    end
    return false
end

local function SiegeCheck(minions)
    for i, minion in ipairs(minions) do
        if SiegeMinion(minion) then
            return minion
        end
    end
    return nil
end

local function ClosestMinionToMouse(minions)
    local mouse_pos = ml.GetMousePos()
    local closestMinion = nil
    local closestMinionDistance = 9999
    for _, minion in ipairs(minions) do
        if minion then
            if minion:distance_to(mouse_pos) < 650 then
                local minionDist = minion:distance_to(mouse_pos)
                if minionDist < closestMinionDistance then
                    closestMinion = minion
                    closestMinionDistance = minionDist
                end
            end
        end
    end
    return closestMinion
end

local function Clear()
    if menu:get_value(clear_w) == 1 and GetManaPercent() >= menu:get_value(clear_w_mana) then
        if ml.Ready(SLOT_W) then
            if WReturn() then
                CastW(local_player.origin)
            else
                local minions = MinionsAround(local_player.origin, spellW.range)
                if minions then
                    if #minions > 0 then
                        local star_unit = SiegeCheck(minions)
                        if star_unit and ml.IsValid(star_unit) and menu:get_value(clear_q) == 1 and GetManaPercent() >= menu:get_value(clear_q_mana) then
                            if ml.Ready(SLOT_Q) then
                                CastQ(star_unit)
                            end
                        else
                            star_unit = ClosestMinionToMouse(minions)
                            if ml.Ready(SLOT_Q) and ml.IsValid(star_unit) and menu:get_value(clear_q) == 1 and GetManaPercent() >= menu:get_value(clear_q_mana) then
                                CastQ(star_unit)
                            end
                        end
                        if star_unit then
                            local cast_pos, count = GetBestCircularFarmPos(star_unit, spellW.range, spellW.effect_radius)
                            if cast_pos and count > 0 then
                                CastW(cast_pos)
                            end
                        end
                    end
                end
            end
        end
    end
    if menu:get_value(clear_q) == 1 and GetManaPercent() >= menu:get_value(clear_q_mana) then
        if ml.Ready(SLOT_Q) then
            local minions = MinionsAround(local_player.origin, spellQ.range)
            if minions then
                if #minions > 0 then
                    for i, minion in ipairs(minions) do
                        if QDmg(minion) > minion.health then
                            CastQ(minion)
                        end
                    end
                end
            end
        end
    end
    if menu:get_value(clear_e) == 1 and GetManaPercent() >= menu:get_value(clear_e_mana) then
        if ml.Ready(SLOT_E) then
            local minions = MinionsAround(local_player.origin, spellE.range)
            if minions then
                if #minions > 0 then
                    for i, minion in ipairs(minions) do
                        if EDmg(minion) > minion.health then
                            local output = arkpred:get_prediction(e_input, minion)
                            local inv = arkpred:get_invisible_duration(minion)
                            if output.hit_chance > 0.5 and inv < 0.125 then  
                                local cast_pos = vec3.new(output.cast_pos.x, output.cast_pos.y, output.cast_pos.z)
                                if cast_pos and ml.Ready(SLOT_E) then
                                    CastE(cast_pos)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

local function EpicMonster(unit)
	if unit.champ_name == "SRU_Baron"
		or unit.champ_name == "SRU_RiftHerald"
		or unit.champ_name == "SRU_Dragon_Water"
		or unit.champ_name == "SRU_Dragon_Fire"
		or unit.champ_name == "SRU_Dragon_Earth"
		or unit.champ_name == "SRU_Dragon_Air"
		or unit.champ_name == "SRU_Dragon_Elder" then
		return true
	else
		return false
	end
end

local function SingleJgMob(unit)
    if unit.champ_name == "SRU_Blue" or unit.champ_name == "SRU_Red" or unit.champ_name == "SRU_Gromp" or unit.champ_name == "SRU_Crab" then
		return true
	else
		return false
	end
end

local function EpicMonstersAround(pos, range)
    local Count = 0
    local minion_table = {}
    minions = game.jungle_minions
    for i, m in ipairs(minions) do
        if m.object_id ~= 0 and m.is_jungle_minion and m.is_alive and m:distance_to(pos) < range then
            if EpicMonster(m) then
                Count = Count + 1
                table.insert(minion_table, m)
            end
        end
    end
    return minion_table, Count
end

local function SoloCampsAround(pos, range)
    local Count = 0
    local minion_table = {}
    minions = game.jungle_minions
    for i, m in ipairs(minions) do
        if m.object_id ~= 0 and m.is_jungle_minion and m.is_alive and m:distance_to(pos) < range then
            if SingleJgMob(m) then
                Count = Count + 1
                table.insert(minion_table, m)
            end
        end
    end
    return minion_table, Count
end

local function JungleMonstersAround(pos, range)
    local Count = 0
    local minion_table = {}
    minions = game.jungle_minions
    for i, m in ipairs(minions) do
        if m.object_id ~= 0 and m.is_jungle_minion and m.is_alive and m:distance_to(pos) < range then
            Count = Count + 1
            table.insert(minion_table, m)
        end
    end
    return minion_table, Count
end

local function GetLineJgMinionCount(source, aimPos, delay, speed, width)
    local Count = 0
    players = game.jungle_minions
    for _, target in ipairs(players) do
        local Range = 1100 * 1100
        if target.object_id ~= 0 and ml.IsValid(target) and ml.GetDistanceSqr(local_player, target.origin) < Range then
            local pointSegment, pointLine, isOnSegment = ml.VectorPointProjectionOnLineSegment(source.origin, aimPos, target.origin)
            if pointSegment and isOnSegment and (ml.GetDistanceSqr2(target.origin, pointSegment) <= (target.bounding_radius + width) * (target.bounding_radius + width)) then
                Count = Count + 1
            end
        end
    end
    return Count
end

local function GetBestCircularJungPos(unit, range, radius)
    local BestPos = nil
    local MostHit = 0
    minions = game.jungle_minions
    for i, m in ipairs(minions) do
        if m.object_id ~= 0 and m.is_jungle_minion and m.is_alive and unit:distance_to(m.origin) < range then
            local Count = JungleMonstersAround(m.origin, radius)
            if #Count > MostHit then
                MostHit = #Count
                BestPos = m.origin
            end
        end
    end
    return BestPos, MostHit
end

local function big_camp_units(monsters)
    for i, monster in ipairs(monsters) do
        if monster.champ_name == "SRU_Gromp" or monster.champ_name == "SRU_Murkwolf" or monster.champ_name == "SRU_Razorbeak" then
            return monster
        end
    end
    return nil
end

local function JgClear()
    if menu:get_value(clear_w) == 1 and GetManaPercent() >= menu:get_value(clear_w_mana) then
        if ml.Ready(SLOT_W) then
            if WReturn() then
                CastW(local_player.origin)
            else
                local epic_monsters, epic_monsters_count = EpicMonstersAround(local_player.origin, spellQ.range)
                local solo_monsters, solo_monsters_count = SoloCampsAround(local_player.origin, spellQ.range)
                local jg_monsters, jg_monsters_count = JungleMonstersAround(local_player.origin, spellW.range)
                if epic_monsters and epic_monsters_count > 0 then
                    for i, minion in ipairs(epic_monsters) do
                        spellbook:cast_spell(SLOT_W, spellW.delay, minion.origin.x, minion.origin.y, minion.origin.z)
                    end
                end
                if solo_monsters and solo_monsters_count > 0 then
                    for i, minion in ipairs(solo_monsters) do
                        spellbook:cast_spell(SLOT_W, spellW.delay, minion.origin.x, minion.origin.y, minion.origin.z)
                    end
                end
                if jg_monsters and jg_monsters_count > 0 then
                    local star_unit = big_camp_units(jg_monsters)
                    if star_unit and ml.IsValid(star_unit) and menu:get_value(clear_q) == 1 and GetManaPercent() >= menu:get_value(clear_q_mana) then
                        if ml.Ready(SLOT_Q) then
                            CastQ(star_unit)
                        end
                    else
                        star_unit = ClosestMinionToMouse(jg_monsters)
                        if ml.Ready(SLOT_Q) and ml.IsValid(star_unit) and menu:get_value(clear_q) == 1 and GetManaPercent() >= menu:get_value(clear_q_mana) then
                            CastQ(star_unit)
                        end
                    end
                    if star_unit then
                        local cast_pos, count = GetBestCircularJungPos(star_unit, spellW.range, spellW.effect_radius)
                        if cast_pos and count > 0 then
                            CastW(cast_pos)
                        end
                    end
                end
            end
        end
    end
    if menu:get_value(clear_q) == 1 and GetManaPercent() >= menu:get_value(clear_q_mana) then
        if ml.Ready(SLOT_Q) then
            local epic_monsters, epic_monsters_count = EpicMonstersAround(local_player.origin, spellQ.range)
            local solo_monsters, solo_monsters_count = SoloCampsAround(local_player.origin, spellQ.range)
            local jg_monsters, jg_monsters_count = JungleMonstersAround(local_player.origin, spellQ.range)
            if epic_monsters and epic_monsters_count > 0 then
                for i, minion in ipairs(epic_monsters) do
                    CastQ(minion)
                end
            end
            if solo_monsters and solo_monsters_count > 0 then
                for i, minion in ipairs(solo_monsters) do
                    CastQ(minion)
                end
            end
            if jg_monsters and jg_monsters_count > 0 then
                for i, minion in ipairs(jg_monsters) do
                    CastQ(minion)
                end
            end
        end
    end
    if menu:get_value(clear_e) == 1 and GetManaPercent() >= menu:get_value(clear_e_mana) then
        if ml.Ready(SLOT_E) then
            local epic_monsters, epic_monsters_count = EpicMonstersAround(local_player.origin, spellE.range)
            local solo_monsters, solo_monsters_count = SoloCampsAround(local_player.origin, spellE.range)
            local jg_monsters, jg_monsters_count = JungleMonstersAround(local_player.origin, spellE.range)
            if epic_monsters and epic_monsters_count > 0 then
                for i, minion in ipairs(epic_monsters) do
                    spellbook:cast_spell(SLOT_E, spellE.delay, minion.origin.x, minion.origin.y, minion.origin.z)
                end
            end
            if solo_monsters and solo_monsters_count > 0 then
                for i, minion in ipairs(solo_monsters) do
                    spellbook:cast_spell(SLOT_E, spellE.delay, minion.origin.x, minion.origin.y, minion.origin.z)
                end
            end
            if jg_monsters and jg_monsters_count > 0 then
                for i, minion in ipairs(jg_monsters) do
                    local count = GetLineJgMinionCount(local_player, minion.origin, spellE.delay, spellE.speed, spellE.width)
                    if count <= 1 then
                        spellbook:cast_spell(SLOT_E, spellE.delay, minion.origin.x, minion.origin.y, minion.origin.z)
                    end
                end
            end
        end
    end
end

local function KillSteal()
    local enemies, _ = ml.GetEnemyCount(local_player.origin, 2000)
    for i, enemy in pairs(enemies) do
        if enemy and ml.IsValid(enemy) then
            local dist = local_player:distance_to(enemy.origin)
            local hp = enemy.health
            local WQRange = 1300
            local WWQRange = 1900
            local r_spell = RSpell()
            if ml.Ready(SLOT_Q) and hp < QDmg(enemy) and dist < WWQRange and dist > (WQRange + 5) then
                CastQ(enemy)
            elseif ml.Ready(SLOT_Q) and hp < QDmg(enemy) and dist < 710 then
                CastQ(enemy)
            elseif ml.Ready(SLOT_Q) and ml.Ready(SLOT_W) and hp < QDmg(enemy) and dist < WQRange and dist > 710 then
                CastGPW(enemy)
                CastQ(enemy)
            elseif ml.Ready(SLOT_Q) and ml.Ready(SLOT_W) and ml.Ready(SLOT_R) and hp < QDmg(enemy) and dist < WWQRange and dist > (WQRange + 5) then
                CastGPW(enemy)
                if dist < 1900 then
                    CastGPR(enemy)
                    CastQ(enemy)
                end
            elseif ml.Ready(SLOT_W) and hp < WDmg(enemy) and dist < 750 then
                local output = arkpred:get_prediction(w_input, enemy)
                local inv = arkpred:get_invisible_duration(enemy)
                if output.hit_chance > 0.5 and inv < 0.125 then
                    local cast_pos = vec3.new(output.cast_pos.x, output.cast_pos.y, output.cast_pos.z)
                    if cast_pos and ml.Ready(SLOT_W) then
                        CastW(cast_pos)
                    end
                end
            elseif ml.Ready(SLOT_E) and hp < EDmg(enemy) and dist < 865 then
                local output = arkpred:get_prediction(e_input, enemy)
                local inv = arkpred:get_invisible_duration(enemy)
                if output.hit_chance > 0.5 and inv < 0.125 then
                    local cast_pos = vec3.new(output.cast_pos.x, output.cast_pos.y, output.cast_pos.z)
                    if cast_pos then
                        CastE(cast_pos)
                    end
                end
            elseif ml.Ready(SLOT_E) and ml.Ready(SLOT_W) and ml.Ready(SLOT_Q) and hp < (EDmg(enemy) + (1.5 * QDmg(enemy))) and dist < 750 and dist < WQRange then
                if not WReturn() then
                    CastGPW(enemy)
                end
                local output = arkpred:get_prediction(e_input, enemy)
                local inv = arkpred:get_invisible_duration(enemy)
                if output.hit_chance > 0.5 and inv < 0.125 then
                    local cast_pos = vec3.new(output.cast_pos.x, output.cast_pos.y, output.cast_pos.z)
                    if cast_pos then
                        CastE(cast_pos)
                    end
                end
                CastQ(enemy)
            elseif ml.Ready(SLOT_Q) and ml.Ready(SLOT_R) and hp < (QDmg(enemy) + RQDmg(enemy)) and dist < 710 and HasSigil(enemy) then
                CastQ(enemy)
            elseif ml.Ready(SLOT_R) and r_spell == "Q" and hp < (2 * RQDmg(enemy)) and dist < 710 then
                CastRQ(enemy)
            elseif ml.Ready(SLOT_R) and r_spell == "Q" and dist < 710 and hp < (RQDmg(enemy) + (2 * QDmg(enemy))) and HasSigil(enemy) then
                CastRQ(enemy)
            elseif ml.Ready(SLOT_R) and r_spell == "W" and hp < RWDmg(enemy) and dist < 700 then
                local output = arkpred:get_prediction(w_input, enemy)
                local inv = arkpred:get_invisible_duration(enemy)
                if output.hit_chance > 0.5 and inv < 0.125 then
                    local cast_pos = vec3.new(output.cast_pos.x, output.cast_pos.y, output.cast_pos.z)
                    local r_spell = RSpell()
                    if cast_pos and ml.Ready(SLOT_R) and r_spell == "W" then
                        CastRW(cast_pos)
                    end
                end
            elseif ml.Ready(SLOT_R) and ml.Ready(SLOT_Q) and ml.Ready(SLOT_W) and hp < ((2 * QDmg(enemy)) + RQDmg(enemy)) and dist < WQRange and dist > 700 then
                if not WReturn() then
                    CastGPW(enemy)
                end
                CastQ(enemy)
                CastRQ(enemy)
            elseif ml.Ready(SLOT_R) and ml.Ready(SLOT_Q) and ml.Ready(SLOT_W) and hp < (QDmg(enemy) + WDmg(enemy) + RWDmg(enemy)) and dist < 700 then
                CastQ(enemy)
                local output = arkpred:get_prediction(w_input, enemy)
                local inv = arkpred:get_invisible_duration(enemy)
                if output.hit_chance > 0.5 and inv < 0.125 then
                    local cast_pos = vec3.new(output.cast_pos.x, output.cast_pos.y, output.cast_pos.z)
                    if cast_pos and ml.Ready(SLOT_W) then
                        CastW(cast_pos)
                    end
                end
                if WReturn() then
                    local output = arkpred:get_prediction(w_input, enemy)
                    local inv = arkpred:get_invisible_duration(enemy)
                    if output.hit_chance > 0.5 and inv < 0.125 then
                        local cast_pos = vec3.new(output.cast_pos.x, output.cast_pos.y, output.cast_pos.z)
                        local r_spell = RSpell()
                        if cast_pos and ml.Ready(SLOT_R) and r_spell == "W" then
                            CastRW(cast_pos)
                        end
                    end
                end
            end
        end
    end
end

local function Auto()
    local Mode = combo:get_mode()
    if game:is_key_down(menu:get_value(combokey)) then
        Combo()
    elseif Mode == MODE_HARASS then
        Harass()
    elseif Mode == MODE_LANECLEAR then
        Clear()
        JgClear()
    end
end

local function on_tick()
    Auto()
    if menu:get_value(killsteal_enabled) == 1 then
        KillSteal()
    end
end

local function on_draw()
    if menu:get_value(drawings_enabled) == 1 then
        if menu:get_value(draw_dmg) == 1 then
            local enemies = ml.GetEnemyHeroes()
            for _, enemy in pairs(enemies) do
                if enemy.is_visible and ml.IsValid(enemy) and enemy.is_alive then
                    local enemy_pos = vec3.new(enemy.origin.x, enemy.origin.y, enemy.origin.z)
                    local enemy_draw = game:world_to_screen(enemy_pos.x, enemy_pos.y, enemy_pos.z)
                    local damage = ComboDmg(enemy)
                    if damage > enemy.health and enemy_draw.is_valid then
                        renderer:draw_text_big_centered(enemy_draw.x, enemy_draw.y, "Can Kill Target")
                    end
                    enemy:draw_damage_health_bar(damage)
                end
            end
        end
        if menu:get_value(draw_targets) == 1 then
            local target_range = spellE.range
            if not ml.Ready(SLOT_E) then
                if ml.Ready(SLOT_Q) then
                    target_range = spellQ.range
                else
                    target_range = spellW.range
                end
            end
            local prio_list = PriorityList(target_range)
            if prio_list then
                if #prio_list > 0 then
                    for i, champ in ipairs(prio_list) do
                        if champ and ml.IsValid(champ) and champ.is_visible and champ.is_alive then
                            local enemy_pos = vec3.new(champ.origin.x, champ.origin.y, champ.origin.z)
                            local enemy_draw = game:world_to_screen(enemy_pos.x, enemy_pos.y, enemy_pos.z)
                            renderer:draw_text_big_centered(enemy_draw.x, enemy_draw.y - 25, tostring(i), 255, 0, 0, 255)
                        end
                    end
                end
            end
        end
        if local_player.is_alive then
            if menu:get_value(draw_q) == 1 then
                if ml.Ready(SLOT_Q) then
                    renderer:draw_circle(local_player.origin.x, local_player.origin.y, local_player.origin.z, spellQ.range, tonumber(menu:get_value(draw_q_R)), tonumber(menu:get_value(draw_q_G)), tonumber(menu:get_value(draw_q_B)), 255)
                end
            end
            if menu:get_value(draw_w) == 1 then
                if ml.Ready(SLOT_W) then
                    renderer:draw_circle(local_player.origin.x, local_player.origin.y, local_player.origin.z, spellW.range, tonumber(menu:get_value(draw_w_R)), tonumber(menu:get_value(draw_w_G)), tonumber(menu:get_value(draw_w_B)), 255)
                end
            end
            if menu:get_value(draw_e) == 1 then
                if ml.Ready(SLOT_E) then
                    renderer:draw_circle(local_player.origin.x, local_player.origin.y, local_player.origin.z, spellE.range, tonumber(menu:get_value(draw_e_R)), tonumber(menu:get_value(draw_e_G)), tonumber(menu:get_value(draw_e_B)), 255)
                end
            end
            if menu:get_value(draw_r) == 1 then
                if ml.Ready(SLOT_R) then
                    local r_range = spellQ.range
                    if RSpell() == "W" then
                        r_range = spellW.range
                    elseif RSpell() == "E" then
                        r_range = spellE.range
                    end
                    renderer:draw_circle(local_player.origin.x, local_player.origin.y, local_player.origin.z, r_range, tonumber(menu:get_value(draw_r_R)), tonumber(menu:get_value(draw_r_G)), tonumber(menu:get_value(draw_r_B)), 255)
                end
            end
        end
    end
end

client:set_event_callback("on_object_created", on_object_created)
client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)