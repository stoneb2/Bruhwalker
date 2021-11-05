if game.local_player.champ_name ~= "Teemo" then
    return
end

local_player = game.local_player

local file_name = "VectorMath.lua"
if not file_manager:file_exists(file_name) then
   local url = "https://raw.githubusercontent.com/stoneb2/Bruhwalker/main/VectorMath/VectorMath.lua"
   http:download_file(url, file_name)
   console:log("VectorMath Library Downloaded")
   console:log("Please Reload with F5")
end

local ml = require "VectorMath"

teemo = menu:add_category("Teemo")
teemo_enabled = menu:add_checkbox("Enabled", teemo, 1)
combokey = menu:add_keybinder("Combo Key", teemo, 32)

combo_settings = menu:add_subcategory("Combo Settings", teemo)
combo_q = menu:add_checkbox("Use Q", combo_settings, 1)
combo_q_after_aa_only = menu:add_checkbox("Q only after Auto", combo_settings, 1)

harass_settings = menu:add_subcategory("Harass Settings", teemo)
harass_q = menu:add_checkbox("Use Q", harass_settings, 1)
harass_q_mana = menu:add_slider("Minimum Mana to Q", harass_settings, 0, 100, 30)

killsteal_settings = menu:add_subcategory("Killsteal Settings", teemo)
ks_q = menu:add_checkbox("Use Q", killsteal_settings, 1)

drawings_menu = menu:add_subcategory("Drawings", teemo)
drawings_enabled = menu:add_checkbox("Drawings Enabled", drawings_menu, 1)
draw_combo_dmg = menu:add_checkbox("Draw Combo Dmg on Healthbar", drawings_menu, 1)
draw_targets = menu:add_checkbox("Label Targets By Priority", drawings_menu, 1)
draw_q_range = menu:add_checkbox("Draw Q Range", drawings_menu, 1)
draw_q_color = menu:add_subcategory("Draw Q Color", drawings_menu)
draw_q_R = menu:add_slider("Q RGB Red", draw_q_color, 0, 255, 255)
draw_q_G = menu:add_slider("Q RGB Green", draw_q_color, 0, 255, 0)
draw_q_B = menu:add_slider("Q RGB Blue", draw_q_color, 0, 255, 0)

do
    local function AutoUpdate()
        local Version = 1
        local file_name = "Teemo.lua"
        local url = "https://raw.githubusercontent.com/stoneb2/Bruhwalker/main/Teemo/Teemo.lua"
        local web_version = http:get("https://raw.githubusercontent.com/stoneb2/Bruhwalker/main/Teemo/Teemo.version.txt")
        console:log("Teemo Version: " .. Version)
        console:log("Teemo Web Version: " .. tonumber(web_version))
        if tonumber(web_version) == Version then
            console:log("Teemo successfully loaded")
        else
            http:download_file(url, file_name)
            console:log("New Teemo Update Available")
            console:log("Please Reload with F5")
        end
    end
    AutoUpdate()
end

spellQ = {
    range = 680,
    delay = 0.25
}

spellW = {
    delay = 0.1
}

local function CastQ(target)
    spellbook:cast_spell_targetted(SLOT_Q, target, spellQ.delay)
end

local function CastW()
    spellbook:cast_spell_targetted(SLOT_W, local_player, spellW.delay)
end

local function QDmg(target)
    local level = spellbook:get_spell_slot(SLOT_Q).level
    local dmg = ({80, 125, 170, 215, 260})[level] + (0.8 * local_player.ability_power)
    local QDmg = target:calculate_magic_damage(dmg)
    return QDmg
end

local function ComboDmg(target)
    local q_dmg = 0
    local elec_damage = 0
    local damage = 0
    local level = local_player.level
    if local_player:has_perk(Electrocute) then
        if local_player:has_buff("ASSETS/Perks/Styles/Domination/Electrocute/Electrocute.lua") then
            if level > 18 then
                level = 18
            end
            elec_damage = ({30, 38.82, 47.65, 56.47, 65.29, 74.12, 82.94, 91.76, 100.59, 109.41, 118.24, 127.06, 135.88, 144.71, 153.53, 162.35, 171.18, 180})[level] + (0.4 * local_player.bonus_attack_damage) + (0.25 * local_player.ability_power)
        end
    end
    if ml.Ready(SLOT_Q) then
        q_dmg = QDmg(target)
    end
    damage = q_dmg + elec_damage
    return damage
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
                    local difficulty_factor = enemy.armor * enemy.health
                    table.insert(one_shot_health, tonumber(difficulty_factor))
                else
                    table.insert(not_one_shot_champs, enemy)
                    local difficulty_factor = enemy.armor * enemy.health
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
    return GetFirst(PriorityList(range))
end

local function Combo()
    if menu:get_value(combo_q) == 1 and menu:get_value(combo_q_after_aa_only) == 0 and ml.Ready(SLOT_Q) then
        local target = SelectTarget(spellQ.range)
        if selector:get_focus_target() and ml.IsValid(selector:get_focus_target()) then
            target = selector:get_focus_target()
        end
        if target and ml.IsValid(target) and not target:has_buff("sionpassivezombie") then
            if target:distance_to(local_player.origin) < spellQ.range then
                CastQ(target)
            end
        end
    end
end

local function GetMana()
    return local_player.mana
end

local function GetManaPercent()
    local mana_percent = (local_player.mana / local_player.max_mana) * 100
    return mana_percent
end

local function Harass()
    if menu:get_value(harass_q) == 1 and GetManaPercent() > menu:get_value(harass_q_mana) then
        if ml.Ready(SLOT_Q) then
            local target = SelectTarget(spellQ.range)
            if selector:get_focus_target() and ml.IsValid(selector:get_focus_target()) then
                target = selector:get_focus_target()
            end
            if target then
                if target:distance_to(local_player.origin) < spellQ.range and target:distance_to(local_player.origin) > (local_player.attack_range + local_player.bounding_radius) then
                    CastQ(target)
                end
            end
        end
    end
end

local function on_post_attack()
    if menu:get_value(combo_q_after_aa_only) == 1 and game:is_key_down(menu:get_value(combokey)) then
        if ml.Ready(SLOT_Q) then
            local target = SelectTarget(spellQ.range)
            if selector:get_focus_target() and ml.IsValid(selector:get_focus_target()) then
                target = selector:get_focus_target()
            end
            CastQ(target)
        end
    end
    local Mode = combo:get_mode()
    if Mode == MODE_HARASS then
        if ml.Ready(SLOT_Q) then
            if menu:get_value(harass_q) == 1 and GetManaPercent() > menu:get_value(harass_q_mana) then
                local target = SelectTarget(spellQ.range)
                if selector:get_focus_target() and ml.IsValid(selector:get_focus_target()) then
                    target = selector:get_focus_target()
                end
                if target then
                    if ml.IsValid(target) and target:distance_to(local_player.origin) and not target:has_buff("sionpassivezombie") then
                        CastQ(target)
                    end
                end
            end
        end
    end
end

local function Flee()
    if ml.Ready(SLOT_W) then
        CastW()
    end
end

local function Killsteal()
    local enemies, _ = ml.GetEnemyCount(local_player.origin, spellQ.range)
    for i, enemy in pairs(enemies) do
        if ml.Ready(SLOT_Q) then
            if QDmg(enemy) > enemy.health and enemy:distance_to(local_player.origin) < spellQ.range then
                CastQ(enemy)
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
    elseif Mode == MODE_FLEE then
        Flee()
    end
end

local function on_tick()
    Auto()
    Killsteal()
end

local function on_draw()
    if menu:get_value(drawings_enabled) == 1 then
        if menu:get_value(draw_combo_dmg) == 1 then
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
            local prio_list = PriorityList(spellQ.range)
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
            if menu:get_value(draw_q_range) == 1 then
                if ml.Ready(SLOT_Q) then
                    renderer:draw_circle(local_player.origin.x, local_player.origin.y, local_player.origin.z, spellQ.range, tonumber(menu:get_value(draw_q_R)), tonumber(menu:get_value(draw_q_G)), tonumber(menu:get_value(draw_q_B)), 255)
                end
            end
        end
    end
end

client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
client:set_event_callback("on_post_attack", on_post_attack)