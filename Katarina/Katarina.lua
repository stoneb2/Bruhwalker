if game.local_player.champ_name ~= "Katarina" then
    return
end

--[[
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
]]

BenKat_category = menu:add_category("Ben Kat")
BenKat_enabled = menu:add_checkbox("Enabled", BenKat_category, 1)
Kcombo_combokey = menu:add_keybinder("Combo Key", BenKat_category, 32)

Kcombo = menu:add_subcategory("Combo Features", BenKat_category)
combo_mode_table = {}
combo_mode_table[1] = "Q E"
combo_mode_table[2] = "E Q"
combo_mode_table[3] = "E>W>R>Q"
Kcombo_combomode = menu:add_combobox("Combo mode: ", Kcombo, combo_mode_table, 2)
Kcombo_useq = menu:add_checkbox("Use Q", Kcombo, 1)
Kcombo_usew = menu:add_checkbox("Use w", Kcombo, 1)
Kcombo_usee = menu:add_checkbox("Use E", Kcombo, 1)
Kcombo_eturret = menu:add_checkbox("Don't E under Turret", 1)
Kcombo_savee = menu:add_checkbox("Save E if no daggers", 1)
Kcombo_gapclose = menu:add_checkbox("Gapclose if Enemy in E + Q Range", Kcombo, 1)
e_mode_table = {}
e_mode_table[1] = "Infront"
e_mode_table[2] = "Behind"
e_mode_table[3] = "Logic"
Kcombo_emode = menu:add_combobox("E Mode: ", Kcombo, e_mode_table, 2)
Rsettings = menu:add_subcategory("R Settings", Kcombo)
r_usage_table = {}
r_usage_table[1] = "Always"
r_usage_table[2] = "Only if Killable"
r_usage_table[3] = "Never"
r_usage = menu:add_combobox("R Mode: ", Rsettings, r_usage_table, 1)
r_usage_dags = menu:add_slider("X R Daggers for Damage Check", Rsettings, 1, 16, 8)
r_usage_num = menu:add_slider("R only if hits X Enemies", Rsettings, 1, 5, 1)
r_usage_cancelr = menu:add_checkbox("Cancel R if no Enemies", Rsettings, 1)
r_usage_rks = menu:add_checkbox("Cancel R for Killsteal", Rsettings, 1)
r_usage_waste = menu:add_slider("Don't use R if Enemy Health <= ", Rsettings, 0, 500, 100)
--Kcombo_useitems = menu:add_checkbox("Use Items", Kcombo, 1)
Kcombo_magnet = menu:add_checkbox("Magnet to Daggers", Kcombo, 0)

Kharass = menu:add_subcategory("Harass Features", BenKat_category)
Kharass_mode_table = {}
Kharass_mode_table[1] = "Q E"
Kharass_mode_table[2] = "E Q"
Kharass_mode = menu:add_combobox("Harass Mode: ", Kharass, Kharass_mode_table, 1)
Kharass_useq = menu:add_checkbox("Use Q", Kharass, 1)
Kharass_usee = menu:add_checkbox("Use E", Kharass, 1)
Kharass_usew = menu:add_checkbox("Use W", Kharass, 1)

Kclear = menu:add_subcategory("Lane Clear", BenKat_category)
Kclear_useq = menu:add_checkbox("Use Q to Farm", Kclear, 1)
Kclear_q_lasthit = menu:add_checkbox("^- Use Q only for Last Hit", Kclear, 1)
Kclear_q_lasthit_range = menu:add_checkbox("^- Don't use Q for Last Hit if In Auto Range", Kclear, 1)
Kclear_usew = menu:add_checkbox("Use W to Farm", Kclear, 1)
Kclear_w_hits = menu:add_slider("^- Only use W if X number of minions are hit: ", Kclear, 0, 6, 3)
Kclear_usee = menu:add_checkbox("Use E  to Farm", Kclear, 1)
Kclear_e_hits = menu:add_slider("^- Only use E if X number of minions hit by Dagger: ", Kclear, 0, 6, 3)
Kclear_turret = menu:add_checkbox("Don't E under the turret", Kclear, 1)

Klast = menu:add_subcategory("Last Hit", BenKat_category)
Klast_useq = menu:add_checkbox("Use Q to Last Hit", Klast, 1)
Klast_q_lasthit = menu:add_checkbox("Don't use Q for Last Hit if In Auto Range", Klast, 1)

Kks = menu:add_subcategory("Killsteal", BenKat_category)
Kks_useq = menu:add_checkbox("Use Q to KS", Kks, 1)
Kks_usee = menu:add_checkbox("Use E to KS", Kks, 1)
KKs_edagger = menu:add_checkbox("^- Killsteal with E Dagger", Kks, 1)
Kks_egap = menu:add_checkbox("Gapclose for Killsteal", Kks, 1)

Kdrawings = menu:add_subcategory("Draw Settings", BenKat_category)

Kflee = menu:add_subcategory("Flee", BenKat_category)
Kflee_key = menu:add_keybinder("Flee Key", Kflee, 90)
Kflee_usew = menu:add_checkbox("Use W to Flee", Kflee, 1)
Kflee_usee = menu:add_checkbox("Use E to Flee", Kflee, 1)
Kflee_daggers = menu:add_checkbox("Use E on Daggers", Kflee, 1)

local ml = require "VectorMath"

local_player = game.local_player

local spellQ = {
    range = 625,
    delay = 0.25
}

local spellW = {
    range = 400,
    delay = 0.1
}

local spellE = {
    range = 725,
    delay = 0.15
}

local spellR = {
    range = 550,
    delay = 0.1
}

local objHolder = {}
local function on_object_created(object, obj_name)
    if object and obj_name == "Katarina_Base_W_Indicator_Ally" then
        if not ml.in_list(objHolder, object) then
            table.insert(objHolder, object)
        end
    end
end

local function on_object_deleted(object, obj_name)
    if object and obj_name == "Katarina_Base_W_Indicator_Ally" then
        table.insert(objHolder, nil)
    end
end

local function CastQ(target)
    spellbook:cast_spell(SLOT_Q, spellQ.delay, target.origin.x, target.origin.y, target.origin.z)
end

local function CastW()
    spellbook:cast_spell(SLOT_W, spellW.delay, local_player.origin.x, local_player.origin.y, local_player.origin.z)
end

local function CastE(target)
    spellbook:cast_spell(SLOT_E, spellE.delay, target.origin.x, target.origin.y, target.origin.z)
end

local function CastR()
    spellbook:cast_spell(SLOT_R, spellR.delay, local_player.origin.x, local_player.origin.y, local_player.origin.z)
end

local function QDamage(target)
    local damage = 0
    local level = spellbook:get_spell_slot(SLOT_Q).level
    local QDamage = ({75, 105, 135, 165, 195})[level] + (0.3 * local_player.ability_power)
    damage = target:calculate_magic_damage(QDamage)
    return damage
end

local function EDamage(target)
    local damage = 0
    local level = spellbook:get_spell_slot(SLOT_E).level
    local EDamage = ({15, 30, 45, 60, 75})[level] + (0.5 * local_player.total_attack_damage) + (0.25 * local_player.ability_power)
    local OHDamage = ml.OnHitDmg(target, 1)
    damage = target:calculate_magic_damage(EDamage) + OHDamage
    return damage
end

local function RDamage(target)
    local damage = 0
    local level = spellbook:get_spell_slot(SLOT_R).level
    local daggers = menu:get_value(r_usage_dags)
    local RDamage_AD = (0.16 + (0.658 * local_player.bonus_attack_speed * 0.128)) * local_player.bonus_attack_damage
    local RDamage_AP = ({25, 37.5, 50})[level] + (0.19 * local_player.ability_power)
    local OHDamage = ml.OnHitDmg(target, ({0.25, 0.3, 0.35})[level])
    damage = daggers * (target:calculate_magic_damage(RDamage_AP) + target:calculate_phys_damage(RDamage_AD) + OHDamage)
    return damage
end

local function PDamage(target)
    local damage = 0
    local level = local_player.level
    local ap_mult = 0
    if level < 6 then
        ap_mult = 0.55
    elseif level >= 6 and level < 11 then
        ap_mult = 0.66
    elseif level >= 11 and level < 16 then
        ap_mult = 0.77
    elseif level >= 16 then
        ap_mult = 0.88 
    end
    local PDamage = ({68, 72, 77, 82, 89, 96, 103, 112, 121, 131, 142, 154, 166, 180, 194, 208, 224, 240})[level] + (0.75 * local_player.bonus_attack_damage) + (ap_mult * local_player.ability_power)
    local OHDamage = ml.OnHitDmg(target, 1)
    damage = target:calculate_magic_damage(PDamage) + OHDamage
    return damage
end

local function ComboDmg(target)
    local p_dmg = 0
    local q_dmg = 0
    local e_dmg = 0
    local r_dmg = 0
    local damage = 0
    local elec_dmg = 0
    if local_player:has_perk(Electrocute) then
        if local_player:has_buff("ASSETS/Perks/Styles/Domination/Electrocute/Electrocute.lua") then
            elec_damage = ({30, 38.82, 47.65, 56.47, 65.29, 74.12, 82.94, 91.76, 100.59, 109.41, 118.24, 127.06, 135.88, 144.71, 153.53, 162.35, 171.18, 180})[level] + (0.4 * local_player.bonus_attack_damage) + (0.25 * local_player.bonus_attack_damage)
        end
    end
    if ml.Ready(SLOT_Q) then
        q_dmg = QDamage(target)
    end
    if ml.Ready(SLOT_W) and ml.Ready(SLOT_E) then
        e_dmg = 2 * EDamage(target)
        p_dmg = 2 * PDamage(target)
    elseif not ml.Ready(SLOT_W) and ml.Ready(SLOT_E) then
        e_dmg = 2 * EDamage(target)
        p_dmg = PDamage(target)
    end
    if ml.Ready(SLOT_R) then
        r_dmg = RDamage(target)
    end
    damage = p_dmg + q_dmg + e_dmg + r_dmg + elec_dmg
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

local function SelectTarget(range)
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
                local shielded_health = ml.GetShieldedHealth("AD", enemy)
                if combo_dmg > (enemy.health + shielded_health) then
                    table.insert(one_shot_champs, enemy)
                    local difficulty_factor = enemy.mr * enemy.health
                    table.insert(one_shot_health, tonumber(difficulty_factor))
                else
                    table.insert(not_one_shot_champs, enemy)
                    local difficulty_factor = enemy.mr * enemy.health
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

local function GetFirst(tab)
    if tab[0] ~= nil then
        return tab[0]
    else
        return tab[1]
    end
end

local function GetTargetQ()
    local target = GetFirst(SelectTarget(2000))
    return target
end

local function GetTargetW()
    local target = GetFirst(SelectTarget(2000))
    return target
end

local function GetTargetE()
    local target = GetFirst(SelectTarget(2000))
    return target
end

local function GetTargetR()
    local target = GetFirst(SelectTarget(2000))
    return target
end

local function GetClosestDagger()
    local closestDagger = nil
    local closestDaggerDistance = 9999
    for _, objs in pairs(objHolder) do
        if objs then
            if objs:distance_to(local_player.origin) < 360 then
                local DaggerDist = objs:distance_to(local_player.origin)
                if DaggerDist < closestDaggerDistance then
                    closestDagger = objs
                    closestDaggerDistance = DaggerDist
                end
            end
        end
    end
    return closestDagger
end

function GetMinionCount(pos, range)
	count = 0
    local enemies_in_range = {}
	minions = game.minions
	for i, minion in ipairs(minions) do
	    Range = range * range
		if minion and ml.IsValid(minion) and ml.GetDistanceSqr(minion, pos) < Range then
            table.insert(enemies_in_range, minion)
			count = count + 1
		end
	end
	return enemies_in_range, count
end

local function GetClosestMinionToTarget(target)
    local enemyMinions, _ = GetMinionCount(local_player.origin, spellE.range)
    local closestMinion = nil
    local closestMinionDistance = 9999
    if target and ml.IsValid(target) then
        for i, minion in ipairs(enemyMinions) do
            if minion:distance_to(local_player.origin) < spellE.range then
                local minionDistance = minion:distance_to(target.origin)
                if minionDistance < closestMinionDistance then
                    closestMinion = minion
                    closestMinionDistance = minionDistance
                end
            end
        end
    end
    return closestMinion
end

local function GetClosestJungleToTarget(target)
    local enemyMinions, _ = ml.GetJungleMinionCount(local_player.origin, spellE.range)
    local closestMinion = nil
    local closestMinionDistance = 9999
    if target and ml.IsValid(target) then
        for i, minion in ipairs(enemyMinions) do
            if minion:distance_to(local_player.origin) < spellE.range then
                local minionDistance = minion:distance_to(target.origin)
                if minionDistance < closestMinionDistance then
                    closestMinion = minion
                    closestMinionDistance = minionDistance
                end
            end
        end
    end
    return closestMinion
end

local function GetClosestChampionToTarget(target)
    local enemyChamps, _ = ml.GetEnemyCount(local_player.origin, spellE.range)
    local closestChamp = nil
    local closestChampDistance = 9999
    if target and ml.IsValid(target) then
        for i, champ in ipairs(enemyChamps) do
            if champ:distance_to(local_player.origin) < spellE.range then
                local champDistance = champ:distance_to(target.origin)
                if champDistance < closestChampDistance then
                    closestChamp = champ
                    closestChampDistance = champDistance
                end
            end
        end
    end
    return closestChamp
end

local GapClose = false
local e_cast = nil
local function Combo()
    if menu:get_value(Kcombo_gapclose) == 1 then
        local target = GetFirst(SelectTarget(spellE.range + spellQ.range))
        if target then
            local minionDistance = 9999
            local jungleDistance = 9999
            local champDistance = 9999
            local DistanceCheck = nil
            if (ml.Ready(SLOT_Q) and ml.Ready(SLOT_E) and ml.Ready(SLOT_W) and target:distance_to(local_player.origin) > spellQ.range and target:distance_to(local_player.origin) < spellQ.range + spellE.range - 50) then
                allowing = true
                local minion = GetClosestMinionToTarget(target)
                if minion then
                    DistanceCheck = target:distance_to(minion.origin)
                    if DistanceCheck < spellE.range then
                        minionDistance = DistanceCheck
                    end
                end
                local jungle = GetClosestJungleToTarget(target)
                if jungle then
                    DistanceCheck = target:distance_to(jungle.origin)
                    if DistanceCheck < spellE.range then
                        jungleDistance = DistanceCheck
                    end
                end
                local champ = GetClosestChampionToTarget(target)
                if champ then
                    DistanceCheck = target:distance_to(champ.origin)
                    if DistanceCheck < spellE.range then
                        champDistance = DistanceCheck
                    end
                end
                if minionDistance < jungleDistance and minionDistance < champDistance then
                    spellbook:cast_spell(SLOT_E, 0.15, minion.origin.x, minion.origin.y, minion.origin.z)
                    GapClose = true
                    e_cast = client:get_tick_count() + 1
                end
                if jungleDistance < minionDistance and jungleDistance < champDistance then
                    spellbook:cast_spell(SLOT_E, 0.15, jungle.origin.x, jungle.origin.y, jungle.origin.z)
                    GapClose = true
                    e_cast = client:get_tick_count() + 1
                end
                if champDistance < minionDistance and champDistance < jungleDistance then
                    spellbook:cast_spell(SLOT_E, 0.15, champ.origin.x, champ.origin.y, champ.origin.z)
                    GapClose = true
                    e_cast = client:get_tick_count() + 1
                end
            end
            if GapClose and e_cast and spellbook:get_spell_slot(SLOT_W).can_cast and not ml.Ready(SLOT_E) then
                if client:get_tick_count() >= e_cast then
                    spellbook:cast_spell(SLOT_W, 0.1, local_player.origin.x, local_player.origin.y, local_player.origin.z)
                end
            end
        end
    end
    if menu:get_value(r_usage_cancelr) == 1 then
        if local_player:has_buff("katarinarsound") then
            _, count = ml.GetEnemyCount(local_player.origin, spellR.range + 10)
            if (count == 0) then
                orbwalker:move_to()
            end
        end
    end
    if menu:get_value(r_usage_rks) == 1 then
        local target = GetTargetE()
        if target and target.is_visible then
            if ml.IsValid(target) then
                if (local_player:distance_to(target.origin) <= spellE.range) then
                    if not ml.is_invulnerable(target) then
                        if local_player:has_buff("katarinarsound") then
                            if (local_player:distance_to(target.origin) >= spellR.range - 100 and ml.Ready(SLOT_E)) then
                                if (size(objHolder) > 0) then
                                    for _, objs in pairs(objHolder) do
                                        if objs then
                                            if (target:distance_to(objs.origin) < 450 and target:distance_to(local_player.origin) < spellE.range and ml.Ready(SLOT_E)) then
                                                if menu:get_value(Kcombo_eturret) == 1 then
                                                    if not ml.is_under_enemy_tower(objs) then
                                                        allowing = true
                                                        local direction = ml.Sub(objs.origin, target.origin):normalized()
                                                        local extendedPos = ml.Sub(objs.origin, ml.VectorMag(direction, 200))
                                                        if ml.Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        end
                                                    end
                                                else
                                                    allowing = true
                                                    local direction = ml.Sub(objs.origin, target.origin):normalized()
                                                    local extendedPos = ml.Sub(objs.origin, ml.VectorMag(direction, 200))
                                                    if ml.Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                    end
                                                end
                                            end
                                            if (local_player:distance_to(objs.origin) > spellE.range and local_player:distance_to(target.origin) < spellE.range and ml.Ready(SLOT_E)) then
                                                if menu:get_value(Kcombo_eturret) == 1 then
                                                    if not ml.is_under_enemy_tower(target) then
                                                        allowing = true
                                                        local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                        if ml.Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        end
                                                    end
                                                else
                                                    allowing = true
                                                    local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                    local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                    if ml.Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                    end
                                                end
                                            end
                                            if (target:distance_to(objs.origin) > 450 and target:distance_to(local_player.origin) < spellE.range and ml.Ready(SLOT_E)) then
                                                if menu:get_value(Kcombo_eturret) == 1 then
                                                    if not ml.is_under_enemy_tower(target) then
                                                        allowing = true
                                                        local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                        if ml.Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        end
                                                    end
                                                else
                                                    allowing = true
                                                    local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                    local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                    if ml.Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                                if (size(objHolder) == 0) then
                                    if ml.Ready(SLOT_E) then
                                        if menu:get_value(Kcombo_eturret) == 1 then
                                            if not ml.is_under_enemy_tower(target) then
                                                allowing = true
                                                local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                if ml.Ready(SLOT_E) then
                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                end
                                            end
                                        else
                                            allowing = true
                                            local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                            local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                            if ml.Ready(SLOT_E) then
                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                            end
                                        end
                                    end
                                end
                            end
                            if (EDamage(target) >= target.health and ml.Ready(SLOT_E)) then
                                if (size(objHolder) > 0) then
                                    for _, objs in pairs(objHolder) do
                                        if objs then
                                            if (target:distance_to(objs.origin) < 450) then
                                                if menu:get_value(Kcombo_eturret) == 1 then
                                                    if not ml.is_under_enemy_tower(objs.origin) then
                                                        allowing = true
                                                        local direction = ml.Sub(objs.origin, target.origin):normalized()
                                                        local extendedPos = ml.Sub(objs.origin, ml.VectorMag(direction, 200))
                                                        if ml.Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        end
                                                    end
                                                else
                                                    allowing = true
                                                    local direction = ml.Sub(objs.origin, target.origin):normalized()
                                                    local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 200))
                                                    if ml.Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                    end
                                                end
                                            end
                                            if (objs:distance_to(local_player.origin) > spellE.range) then
                                                if menu:get_value(Kcombo_eturret) == 1 then
                                                    if not ml.is_under_enemy_tower(target) then
                                                        allowing = true
                                                        local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                        if ml.Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        end
                                                    end
                                                else
                                                    allowing = true
                                                    local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                    local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                    if ml.Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                    end
                                                end
                                            end
                                            if (target:distance_to(objs.origin) > 450) then
                                                if menu:get_value(Kcombo_eturret) == 1 then
                                                    if not ml.is_under_enemy_tower(target) then
                                                        allowing = true
                                                        local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                        if ml.Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        end
                                                    end
                                                else
                                                    allowing = true
                                                    local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                    local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                    if ml.Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                                if (size(objHolder) == 0 and ml.Ready(SLOT_E)) then
                                    if menu:get_value(Kcombo_eturret) == 1 then
                                        if not ml.is_under_enemy_tower(target) then
                                            allowing = true
                                            local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                            local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                            if ml.Ready(SLOT_E) then
                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                            end
                                        end
                                    else
                                        allowing = true
                                        local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                        local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                        if ml.Ready(SLOT_E) then
                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                        end
                                    end
                                end
                                if (target:distance_to(local_player.origin) < spellQ.range and ml.Ready(SLOT_Q)) then
                                    allowing = true
                                    if ml.Ready(SLOT_E) then
                                        spellbook:cast_spell(SLOT_E, 0.25, target.origin.x, target.origin.y, target.origin.z)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    local target = GetTargetE()
    if target and target.is_visible then
        if ml.IsValid(target) then
            if not local_player:has_buff("katarinarsound") then
                if menu:get_value(Kcombo_combomode) == 0 then 
                    if menu:get_value(Kcombo_useq) == 1 then
                        if (target:distance_to(local_player.origin) <= spellQ.range) then
                            if ml.Ready(SLOT_E) then
                                spellbook:cast_spell(SLOT_E, 0.25, target.origin.x, target.origin.y, target.origin.z)
                            end
                        end
                    end
                    if menu:get_value(Kcombo_usee) == 1 and ml.Ready(SLOT_Q) then
                        if (size(objHolder) > 0) then
                            for _, objs in pairs(objHolder) do
                                if objs then
                                    if menu:get_value(Kcombo_savee) == 0 then
                                        if (target:distance_to(objs.origin) < 450) then
                                            if menu:get_value(Kcombo_eturret) == 1 then
                                                if not ml.is_under_enemy_tower(objs) then
                                                    local direction = ml.Sub(objs.origin, target.origin):normalized()
                                                    local extendedPos = ml.Sub(objs.origin, ml.VectorMag(direction, 200))
                                                    if ml.Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                    end
                                                end
                                            else
                                                local direction = ml.Sub(objs.origin, target.origin):normalized()
                                                local extendedPos = ml.Sub(objs.origin, ml.VectorMag(direction, 200))
                                                if ml.Ready(SLOT_E) then
                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                end
                                            end
                                        end
                                        if menu:get_value(Kcombo_emode) == 0 then --CONFIRM THIS, VALUE IS DIFFERENT THAN KORNIS (KORNIS - 1)
                                            if objs:distance_to(local_player.origin) > spellE.range then
                                                if menu:get_value(Kcombo_eturret) == 1 then
                                                    if not ml.is_under_enemy_tower(target) then
                                                        local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 50))
                                                        if ml.Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        end
                                                    end
                                                else
                                                    local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                    local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 50))
                                                    if ml.Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                    end
                                                end
                                            end
                                            if (objs:distance_to(target.origin) > 450) then
                                                if menu:get_value(Kcombo_eturret) == 1 then
                                                    if not ml.is_under_enemy_tower(target) then
                                                        local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 50))
                                                        if ml.Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        end
                                                    end
                                                else
                                                    local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                    local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 50))
                                                    if ml.Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                    end
                                                end
                                            end
                                        end
                                        if menu:get_value(Kcombo_emode) == 1 then
                                            if objs:distance_to(local_player.origin) > spellE.range then
                                                if menu:get_value(Kcombo_eturret) == 1 then
                                                    if not ml.is_under_enemy_tower(target) then
                                                        local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                        if ml.Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        end
                                                    end
                                                    local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                    local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                    if ml.Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                    end
                                                end
                                            end
                                            if (objs:distance_to(target.origin) > 450) then
                                                if menu:get_value(Kcombo_eturret) == 1 then
                                                    if not ml.is_under_enemy_tower(target) then
                                                        local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                        if ml.Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        end
                                                    end
                                                else
                                                    local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                    local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                    if ml.Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                    end
                                                end
                                            end
                                        end
                                        if menu:get_value(Kcombo_emode) == 2 then
                                            if not ml.Ready(SLOT_R) or spellbook:get_spell_slot(SLOT_R).level == 0 then --CONFIRM THIS LINE WORKS
                                                if objs:distance_to(local_player.origin) > spellE.range then
                                                    if menu:get_value(Kcombo_eturret) == 1 then
                                                        if not ml.is_under_enemy_tower(target) then
                                                            local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                            local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 50))
                                                            if ml.Ready(SLOT_E) then
                                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            end
                                                        end
                                                    else
                                                        local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 50))
                                                        if ml.Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        end
                                                    end
                                                end
                                                if (objs:distance_to(target.origin) > 450) then
                                                    if menu:get_value(Kcombo_eturret) == 1 then
                                                        if not ml.is_under_enemy_tower(target) then
                                                            local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                            local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 50))
                                                            if ml.Ready(SLOT_E) then
                                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            end
                                                        end
                                                    else
                                                        local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 50))
                                                        if ml.Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        end
                                                    end
                                                end
                                            end
                                            if ml.Ready(SLOT_R) then
                                                if objs:distance_to(local_player.origin) > spellE.range then
                                                    if menu:get_value(Kcombo_eturret) == 1 then
                                                        if not ml.is_under_enemy_tower(target) then
                                                            local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                            local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                            if ml.Ready(SLOT_E) then
                                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            end
                                                        end
                                                    else
                                                        local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                        if ml.Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        end
                                                    end
                                                end
                                                if (objs:distance_to(target.origin) > 450) then
                                                    if menu:get_value(Kcombo_eturret) == 1 then
                                                        if not ml.is_under_enemy_tower(target) then
                                                            local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                            local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                            if ml.Ready(SLOT_E) then
                                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            end
                                                        end
                                                    else
                                                        local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                        if ml.Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                    if menu:get_value(Kcombo_savee) == 1 then
                                        if menu:get_value(Kcombo_eturret) == 1 then
                                            if not ml.is_under_enemy_tower(target) then
                                                local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 200))
                                                if ml.Ready(SLOT_E) then
                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                end
                                            end
                                        else
                                            local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                            local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 200))
                                            if ml.Ready(SLOT_E) then
                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if (size(objHolder) == 0) then
                        if menu:get_value(Kcombo_savee) == 0 then
                            if menu:get_value(Kcombo_emode) == 0 then
                                if menu:get_value(Kcombo_eturret) == 1 then
                                    if not ml.is_under_enemy_tower(target) then
                                        local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                        local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 50))
                                        if ml.Ready(SLOT_E) then
                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                        end
                                    end
                                else
                                    local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                    local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 50))
                                    if ml.Ready(SLOT_E) then
                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                    end
                                end
                            end
                            if menu:get_value(Kcombo_emode) == 1 then
                                if menu:get_value(Kcombo_eturret) == 1 then
                                    if not ml.is_under_enemy_tower(target) then
                                        local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                        local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                        if ml.Ready(SLOT_E) then
                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                        end
                                    end
                                else
                                    local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                    local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                    if ml.Ready(SLOT_E) then
                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                    end
                                end
                            end
                            if menu:get_value(Kcombo_emode) == 2 then
                                if not ml.Ready(SLOT_R) or spellbook:get_spell_slot(SLOT_R).level == 0 then
                                    if menu:get_value(Kcombo_eturret) == 1 then
                                        if not ml.is_under_enemy_tower(target) then
                                            if not ml.is_under_enemy_tower(target) then
                                                local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 50))
                                                if ml.Ready(SLOT_E) then
                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                end
                                            end
                                        else
                                            local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                            local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 50))
                                            if ml.Ready(SLOT_E) then
                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                            end
                                        end
                                    end
                                    if ml.Ready(SLOT_R) then
                                        if menu:get_value(Kcombo_eturret) == 1 then
                                            if not ml.is_under_enemy_tower(target) then
                                                local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                if ml.Ready(SLOT_E) then
                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                end
                                            end
                                        else
                                            local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                            local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                            if ml.Ready(SLOT_E) then
                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if menu:get_value(Kcombo_usew) == 1 then
                        _, count = ml.GetEnemyCount(local_player.origin, spellW.range)
                        if (count > 0) then
                            local target = GetTargetW()
                            if target and target.is_visible then
                                if ml.IsValid(target) then
                                    if (target:distance_to(local_player.origin) <= spellW.range) then
                                        if ml.Ready(SLOT_W) then
                                            spellbook:cast_spell(SLOT_W, 0.1, target.origin.x, target.origin.y, target.origin.z)
                                        end
                                    end
                                end
                            end
                        end
                    end
                    --If closest enemy is close to edge case, don't R
                    if menu:get_value(r_usage) == 0 and ml.Ready(SLOT_R) then
                        if (target:distance_to(local_player.origin) <= spellR.range - 50) then
                            _, count = ml.GetEnemyCount(local_player.origin, spellR.range - 100)
                            if (count >= menu:get_value(r_usage_num)) then
                                if (target.health >= menu:get_value(r_usage_waste) and not ml.Ready(SLOT_Q)) then
                                    if not ml.Ready(SLOT_W) then
                                        if ml.Ready(SLOT_E) then
                                            spellbook:cast_spell(SLOT_E, 0.15, target.origin.x, target.origin.y, target.origin.z)
                                        end
                                        spellbook:cast_spell(SLOT_R, 0.1, local_player.origin.x, local_player.origin.y, local_player.origin.z)
                                    elseif ml.Ready(SLOT_W) then
                                        if ml.Ready(SLOT_E) then
                                            spellbook:cast_spell(SLOT_E, 0.15, target.origin.x, target.origin.y, target.origin.z)
                                        end
                                        spellbook:cast_spell(SLOT_W, 0.1, local_player.origin.x, local_player.origin.y, local_player.origin.z)
                                        spellbook:cast_spell(SLOT_R, 0.1, local_player.origin.x, local_player.origin.y, local_player.origin.z)
                                    end
                                end
                            end
                        end
                    end
                    if menu:get_value(r_usage) == 1 and ml.Ready(SLOT_R) then
                        if (target:distance_to(local_player.origin) <= spellR.range - 50) then
                            --Line 1132, adds in dmglib getspelldamage at the end, what is this?
                            if (target.health <= RDamage(target) + EDamage(target) + PDamage(target)) then 
                                if (target.health >= menu:get_value(r_usage_waste) and not ml.Ready(SLOT_Q)) then
                                    if not ml.Ready(SLOT_W) then
                                        if ml.Ready(SLOT_E) then
                                            spellbook:cast_spell(SLOT_E, 0.15, target.origin.x, target.origin.y, target.origin.z)
                                        end
                                        spellbook:cast_spell(SLOT_R, 0.1, local_player.origin.x, local_player.origin.y, local_player.origin.z)
                                    elseif ml.Ready(SLOT_W) then
                                        if ml.Ready(SLOT_E) then
                                            spellbook:cast_spell(SLOT_E, 0.15, target.origin.x, target.origin.y, target.origin.z)
                                        end
                                        spellbook:cast_spell(SLOT_W, 0.1, local_player.origin.x, local_player.origin.y, local_player.origin.z)
                                        spellbook:cast_spell(SLOT_R, 0.1, local_player.origin.x, local_player.origin.y, local_player.origin.z)
                                    end
                                end
                            end
                        end
                    end
                end
                if menu:get_value(Kcombo_combomode) == 1 then
                    if menu:get_value(Kcombo_usee) == 1 then
                        if (size(objHolder) > 0) then
                            for _, objs in pairs(objHolder) do
                                if objs then
                                    if menu:get_value(Kcombo_savee) == 0 then
                                        if target:distance_to(objs.origin) < 450 then
                                            if menu:get_value(Kcombo_eturret) == 1 then
                                                if not ml.is_under_enemy_tower(objs) then
                                                    local direction = ml.Sub(objs.origin, target.origin):normalized()
                                                    local extendedPos = ml.Sub(objs.origin, ml.VectorMag(direction, 200))
                                                    if ml.Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                    end
                                                end
                                            else
                                                local direction = ml.Sub(objs.origin, target.origin):normalized()
                                                local extendedPos = ml.Sub(objs.origin, ml.VectorMag(direction, 200))
                                                if ml.Ready(SLOT_E) then
                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                end
                                            end
                                        end
                                        if menu:get_value(Kcombo_emode) == 0 then
                                            if objs:distance_to(local_player.origin) > spellE.range then
                                                if menu:get_value(Kcombo_eturret) == 1 then
                                                    if not ml.is_under_enemy_tower(target) then
                                                        local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 50))
                                                        if ml.Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        end
                                                    end
                                                else
                                                    local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                    local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 50))
                                                    if ml.Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                    end
                                                end
                                            end
                                            if (objs:distance_to(target.origin) > 450) then
                                                if menu:get_value(Kcombo_eturret) == 1 then
                                                    if not ml.is_under_enemy_tower(target) then
                                                        local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 50))
                                                        if ml.Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        end
                                                    end
                                                else
                                                    local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                    local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 50))
                                                    if ml.Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                    end
                                                end
                                            end
                                        end
                                        if menu:get_value(Kcombo_emode) == 1 then
                                            if objs:distance_to(local_player.origin) > spellE.range then
                                                if menu:get_value(Kcombo_eturret) == 1 then
                                                    if not ml.is_under_enemy_tower(target) then
                                                        local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                        if ml.Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        end
                                                    end
                                                else
                                                    local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                    local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                    if ml.Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                    end
                                                end
                                            end
                                            if (objs:distance_to(target.origin) > 450) then
                                                if menu:get_value(Kcombo_eturret) == 1 then
                                                    if not ml.is_under_enemy_tower(target) then
                                                        local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                        if ml.Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        end
                                                    end
                                                else
                                                    local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                    local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                    if ml.Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                    end
                                                end
                                            end
                                        end
                                        if menu:get_value(Kcombo_emode) == 2 then
                                            if not ml.Ready(SLOT_R) or spellbook:get_spell_slot(SLOT_R).level == 0 then
                                                if objs:distance_to(local_player.origin) > spellE.range then
                                                    if menu:get_value(Kcombo_eturret) == 1 then
                                                        if not ml.is_under_enemy_tower(target) then
                                                            local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                            local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 50))
                                                            if ml.Ready(SLOT_E) then
                                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            end
                                                        end
                                                    else
                                                        local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 50))
                                                        if ml.Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        end
                                                    end
                                                end
                                                if (objs:distance_to(target.origin) > 450) then
                                                    if menu:get_value(Kcombo_eturret) == 1 then
                                                        if not ml.is_under_enemy_tower(target) then
                                                            local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                            local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 50))
                                                            if ml.Ready(SLOT_E) then
                                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            end
                                                        end
                                                    else
                                                        local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 50))
                                                        if ml.Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        end
                                                    end
                                                end
                                            end
                                            if ml.Ready(SLOT_R) then
                                                if objs:distance_to(local_player.origin) > spellE.range then
                                                    if menu:get_value(Kcombo_eturret) == 1 then
                                                        if not ml.is_under_enemy_tower(target) then
                                                            local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                            local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                            if ml.Ready(SLOT_E) then
                                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            end
                                                        end
                                                    else
                                                        local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                        if ml.Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        end
                                                    end
                                                end
                                                if (objs:distance_to(target.origin) > 450) then
                                                    if menu:get_value(Kcombo_eturret) == 1 then
                                                        if not ml.is_under_enemy_tower(target) then
                                                            local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                            local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                            if ml.Ready(SLOT_E) then
                                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            end
                                                        end
                                                    else
                                                        local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                        if ml.Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                    if menu:get_value(Kcombo_savee) == 1 then
                                        if (target:distance_to(objs.origin) < 450) then
                                            if menu:get_value(Kcombo_eturret) == 1 then
                                                if not ml.is_under_enemy_tower(objs) then
                                                    local direction = ml.Sub(objs.origin, target.origin):normalized()
                                                    local extendedPos = ml.Sub(objs.origin, ml.VectorMag(direction, 200))
                                                    if ml.Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                    end
                                                end
                                            else
                                                local direction = ml.Sub(objs.origin, target.origin):normalized()
                                                local extendedPos = ml.Sub(objs.origin, ml.VectorMag(direction, 200))
                                                if ml.Ready(SLOT_E) then
                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        if (size(objHolder) == 0) then
                            if menu:get_value(Kcombo_savee) == 0 then
                                if menu:get_value(Kcombo_emode) == 0 then
                                    if menu:get_value(Kcombo_eturret) == 1 then
                                        if not ml.is_under_enemy_tower(target) then
                                            local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                            local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 50))
                                            if ml.Ready(SLOT_E) then
                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                            end
                                        end
                                    else
                                        local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                        local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 50))
                                        if ml.Ready(SLOT_E) then
                                            pellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                        end
                                    end
                                end
                                if menu:get_value(Kcombo_emode) == 1 then
                                    if menu:get_value(Kcombo_eturret) == 1 then
                                        if not ml.is_under_enemy_tower(target) then
                                            local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                            local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                            if ml.Ready(SLOT_E) then
                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                            end
                                        end
                                    else
                                        local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                        local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                        if ml.Ready(SLOT_E) then
                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                        end
                                    end
                                end
                                if menu:get_value(Kcombo_emode) == 2 then
                                    if not ml.Ready(SLOT_R) or spellbook:get_spell_slot(SLOT_R).level == 0 then
                                        if menu:get_value(Kcombo_eturret) == 1 then
                                            if not ml.is_under_enemy_tower(target) then
                                                local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 50))
                                                if ml.Ready(SLOT_E) then
                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                end
                                            end
                                        else
                                            local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                            local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 50))
                                            if ml.Ready(SLOT_E) then
                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                            end
                                        end
                                    end
                                    if ml.Ready(SLOT_R) then
                                        if menu:get_value(Kcombo_eturret) == 1 then
                                            if not ml.is_under_enemy_tower(target) then
                                                local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                if ml.Ready(SLOT_E) then
                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                end
                                            end
                                        else
                                            local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                            local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                            if ml.Ready(SLOT_E) then
                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if menu:get_value(Kcombo_usew) == 1 then
                        _, count = ml.GetEnemyCount(local_player.origin, spellW.range)
                        if (count > 0) then
                            local target = GetTargetW()
                            if target and target.is_visible then
                                if ml.IsValid(target) then
                                    if target:distance_to(local_player.origin) <= spellW.range then
                                        if ml.Ready(SLOT_E) then
                                            spellbook:cast_spell(SLOT_W, 0.1, target.origin.x, target.origin.y, target.origin.z)
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if (menu:get_value(Kcombo_useq) == 1) then
                        if (target:distance_to(local_player.origin) <= spellQ.range) and ml.Ready(SLOT_Q) then
                            if ml.Ready(SLOT_Q) then
                                spellbook:cast_spell(SLOT_Q, 0.25, target.origin.x, target.origin.y, target.origin.z)
                            end
                        end
                    end
                    if menu:get_value(r_usage) == 0 and ml.Ready(SLOT_R) then
                        if (target:distance_to(local_player.origin) <= spellR.range - 50) then
                            _, count = ml.GetEnemyCount(local_player.origin, spellR.range - 100)
                            if (count >= menu:get_value(r_usage_num)) then
                                if (target.health >= menu:get_value(r_usage_waste) and not ml.Ready(SLOT_Q)) then
                                    if not ml.Ready(SLOT_W) then
                                        spellbook:cast_spell(SLOT_R, 0.1, local_player.origin.x, local_player.origin.y, local_player.origin.z)
                                    end
                                end
                            end
                        end
                    end
                    if menu:get_value(r_usage) == 1 and ml.Ready(SLOT_R) then
                        if (target:distance_to(local_player.origin) <= spellR.range - 50) then
                            --Line 1132, adds in dmglib getspelldamage at the end, what is this?
                            if (target.health <= RDamage(target) + EDamage(target) + PDamage(target)) then 
                                if (target.health >= menu:get_value(r_usage_waste) and not ml.Ready(SLOT_Q)) then
                                    if not ml.Ready(SLOT_W) then
                                        spellbook:cast_spell(SLOT_R, 0.1, local_player.origin.x, local_player.origin.y, local_player.origin.z)
                                    end
                                end
                            end
                        end
                    end
                end
                if menu:get_value(Kcombo_combomode) == 2 then
                    if menu:get_value(Kcombo_useq) == 1 then
                        if target:distance_to(local_player.origin) <= spellQ.range then
                            if ml.Ready(SLOT_Q) then
                                spellbook:cast_spell(SLOT_Q, 0.25, target.origin.x, target.origin.y, target.origin.z)
                            end
                        end
                        if menu:get_value(Kcombo_usee) == 1 then
                            if (size(objHolder) > 0) then
                                for _, objs in pairs(objHolder) do
                                    if objs then
                                        if menu:get_value(Kcombo_savee) == 0 then
                                            if target:distance_to(objs.origin) < 450 then
                                                if menu:get_value(Kcombo_eturret) == 1 then
                                                    if not ml.is_under_enemy_tower(objs) then
                                                        local direction = ml.Sub(objs.origin, target.origin):normalized()
                                                        local extendedPos = ml.Sub(objs.origin, ml.VectorMag(direction, 200))
                                                        if ml.Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        end
                                                    end
                                                else
                                                    local direction = ml.Sub(objs.origin, target.origin):normalized()
                                                    local extendedPos = ml.Sub(objs.origin, ml.VectorMag(direction, 200))
                                                    if ml.Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                    end
                                                end
                                                if menu:get_value(Kcombo_emode) == 0 then
                                                    if objs:distance_to(local_player.origin) > spellE.range then
                                                        if menu:get_value(Kcombo_eturret) == 1 then
                                                            if not ml.is_under_enemy_tower(target) then
                                                                local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                                local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 50))
                                                                if ml.Ready(SLOT_E) then
                                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                                end
                                                            end
                                                        else
                                                            local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                            local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 50))
                                                            if ml.Ready(SLOT_E) then
                                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            end
                                                        end
                                                    end
                                                    if objs:distance_to(target.origin) > 450 then
                                                        if menu:get_value(Kcombo_eturret) == 1 then
                                                            if not ml.is_under_enemy_tower(target) then
                                                                local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                                local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 50))
                                                                if ml.Ready(SLOT_E) then
                                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                                end
                                                            end
                                                        else
                                                            local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                            local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 50))
                                                            if ml.Ready(SLOT_E) then
                                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            end
                                                        end
                                                    end
                                                end
                                                if menu:get_value(Kcombo_emode) == 1 then
                                                    if objs:distance_to(local_player.origin) > spellE.range then
                                                        if menu:get_value(Kcombo_eturret) == 1 then
                                                            if not ml.is_under_enemy_tower(target) then
                                                                local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                                local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                                if ml.Ready(SLOT_E) then
                                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                                end
                                                            end
                                                        else
                                                            local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                            local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                            if ml.Ready(SLOT_E) then
                                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            end
                                                        end
                                                    end
                                                    if objs:distance_to(target.origin) > 450 then
                                                        if menu:get_value(Kcombo_eturret) == 1 then
                                                            if not ml.is_under_enemy_tower(target) then
                                                                local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                                local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                                if ml.Ready(SLOT_E) then
                                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                                end
                                                            end
                                                            local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                            local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                            if ml.Ready(SLOT_E) then
                                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            end
                                                        end
                                                    end
                                                end
                                                if menu:get_value(Kcombo_emode) == 2 then
                                                    if not ml.Ready(SLOT_R) or spellbook:get_spell_slot(SLOT_R).level == 0 then
                                                        if objs:distance_to(local_player.origin) > spellE.range then
                                                            if menu:get_value(Kcombo_eturret) == 1 then
                                                                if not ml.is_under_enemy_tower(target) then
                                                                    local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                                    local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 50))
                                                                    if ml.Ready(SLOT_E) then
                                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                                    end
                                                                end
                                                            else
                                                                local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                                local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 50))
                                                                if ml.Ready(SLOT_E) then
                                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                                end
                                                            end
                                                        end
                                                        if objs:distance_to(local_player.origin) > 450 then
                                                            if menu:get_value(Kcombo_eturret) == 1 then
                                                                if not ml.is_under_enemy_tower(target) then
                                                                    local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                                    local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 50))
                                                                    if ml.Ready(SLOT_E) then
                                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                                    end
                                                                end
                                                            else
                                                                local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                                local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 50))
                                                                if ml.Ready(SLOT_E) then
                                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                                end
                                                            end
                                                        end
                                                    end
                                                    if ml.Ready(SLOT_R) then
                                                        if objs:distance_to(local_player.origin) > spellE.range then
                                                            if menu:get_value(Kcombo_eturret) == 1 then
                                                                if not ml.is_under_enemy_tower(target) then
                                                                    local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                                    local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                                    if ml.Ready(SLOT_E) then
                                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                                    end
                                                                end
                                                            else
                                                                local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                                local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                                if ml.Ready(SLOT_E) then
                                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                                end
                                                            end
                                                        end
                                                        if objs:distance_to(target.origin) > 450 then
                                                            if menu:get_value(Kcombo_eturret) == 1 then
                                                                if not ml.is_under_enemy_tower(target) then
                                                                    local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                                    local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                                    if ml.Ready(SLOT_E) then
                                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                                    end
                                                                end
                                                            else
                                                                local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                                local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                                if ml.Ready(SLOT_E) then
                                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                            if menu:get_value(Kcombo_savee) == 1 then
                                                if target:distance_to(objs.origin) < 450 then
                                                    if menu:get_value(Kcombo_eturret) == 1 then
                                                        if not ml.is_under_enemy_tower(objs) then
                                                            local direction = ml.Sub(objs.origin, target.origin):normalized()
                                                            local extendedPos = ml.Sub(objs.origin, ml.VectorMag(direction, 200))
                                                            if ml.Ready(SLOT_E) then
                                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            end
                                                        end
                                                    else
                                                        local direction = ml.Sub(objs.origin, target.origin):normalized()
                                                        local extendedPos = ml.Sub(objs.origin, ml.VectorMag(direction, 200))
                                                        if ml.Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                                if (size(objHolder) == 0) then
                                    if menu:get_value(Kcombo_savee) == 0 then
                                        if menu:get_value(Kcombo_emode) == 0 then
                                            if menu:get_value(Kcombo_eturret) == 1 then
                                                if not ml.is_under_enemy_tower(target) then
                                                    local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                    local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 50))
                                                    if ml.Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                    end
                                                end
                                            else
                                                local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 50))
                                                if ml.Ready(SLOT_E) then
                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                end
                                            end
                                        end
                                        if menu:get_value(Kcombo_emode) == 1 then
                                            if menu:get_value(Kcombo_eturret) == 1 then
                                                if not ml.is_under_enemy_tower(target) then
                                                    local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                    local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                    if ml.Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                    end
                                                end
                                            else
                                                local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                if ml.Ready(SLOT_E) then
                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                end
                                            end
                                        end
                                        if menu:get_value(Kcombo_emode) == 2 then
                                            if not ml.Ready(SLOT_R) or spellbook:get_spell_slot(SLOT_R).level == 0 then
                                                if menu:get_value(Kcombo_eturret) == 1 then
                                                    if not ml.is_under_enemy_tower(target) then
                                                        local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 50))
                                                        if ml.Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        end
                                                    end
                                                else
                                                    local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                    local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, 50))
                                                    if ml.Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                    end
                                                end
                                            end
                                            if ml.Ready(SLOT_R) then
                                                if menu:get_value(Kcombo_eturret) == 1 then
                                                    if not ml.is_under_enemy_tower(target) then
                                                        local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                        if ml.Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        end
                                                    end
                                                else
                                                    local direction = ml.Sub(target.origin, local_player.origin):normalized()
                                                    local extendedPos = ml.Sub(target.origin, ml.VectorMag(direction, -50))
                                                    if ml.Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            if menu:get_value(Kcombo_usew) == 1 then
                                _, count = ml.GetEnemyCount(local_player.origin, spellW.range)
                                if (count > 0) then
                                    local target = GetTargetW()
                                    if target and target.is_visible then
                                        if ml.IsValid(target) then
                                            if target:distance_to(local_player.origin) <= spellW.range then
                                                if ml.Ready(SLOT_W) then
                                                    spellbook:cast_spell(SLOT_W, 0.1, target.origin.x, target.origin.y, target.origin.z)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            if (target:distance_to(local_player.origin) <= spellR.range - 50) then
                                if not ml.Ready(SLOT_W) then
                                    if ml.Ready(SLOT_R) then
                                        spellbook:cast_spell(SLOT_R, 0.1, local_player.origin.x, local_player.origin.y, local_player.origin.z)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

local function Harass()

end

local function LaneClear()

end

local function JungleClear()

end

--CHECK FOR GUARDIAN ANGEL
local function KillSteal()
    local enemy = ml.GetEnemyHeroes()
    for i, enemies in ipairs(enemy) do
        if enemies and enemies.is_visible and ml.IsValid(enemies) and not enemies:has_buff_type(invulnerability) then
            local hp = ml.GetShieldedHealth("AP", enemies)
            if menu:get_value(KKs_edagger) == 1 then
                for _, objs in pairs(objHolder) do
                    if objs then
                        if (enemies:distance_to(local_player.origin) <= spellE.range and objs:distance_to(enemies.origin) < 450 and PDamage(enemies) > hp) then
                            allowing = true
                            local direction = ml.Sub(objs.origin, enemies.origin):normalized()
                            local extendedPos = ml.Sub(objs.origin, ml.VectorMag(direction, 200))
                            if ml.Ready(SLOT_E) then
                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                            end
                        end
                    end
                end
            end
            if menu:get_value(Kks_useq) == 1 then
                if (ml.Ready(SLOT_Q) and enemies:distance_to(local_player.origin) < spellQ.range and QDamage(enemies) > hp) then
                    allowing = true
                    if ml.Ready(SLOT_Q) then
                        spellbook:cast_spell(SLOT_Q, 0.25, enemies.origin.x, enemies.origin.y, enemies.origin.z)
                    end
                end
            end
            if menu:get_value(Kks_usee) == 1 then
                if ml.Ready(SLOT_E) and enemies:distance_to(local_player.origin) < spellQ.range and EDamage(enemies) > hp then
                    allowing = true
                    spellbook:cast_spell(SLOT_E, 0.15, enemies.origin.x, enemies.origin.y, enemies.origin.z)
                end
            end
            if menu:get_value(Kks_egap) == 1 then
                local minionDistance = 9999
                local jungleDistance = 9999
                local champDistance = 9999
                local DistanceCheck = nil
                if (ml.Ready(SLOT_Q) and ml.Ready(SLOT_E) and ml.Ready(SLOT_W) and enemies:distance_to(local_player.origin) > spellQ.range and enemies:distance_to(local_player.origin) < spellQ.range + spellE.range - 50 and PDamage(enemies) > hp) then
                    allowing = true
                    local minion = GetClosestMinionToTarget(enemies)
                    if minion then
                        DistanceCheck = enemies:distance_to(minion.origin)
                        if DistanceCheck < spellE.range then
                            minionDistance = DistanceCheck
                        end
                    end
                    local jungle = GetClosestJungleToTarget(enemies)
                    if jungle then
                        DistanceCheck = enemies:distance_to(jungle.origin)
                        if DistanceCheck < spellE.range then
                            jungleDistance = DistanceCheck
                        end
                    end
                    local champ = GetClosestChampionToTarget(enemies)
                    if champ then
                        DistanceCheck = enemies:distance_to(champ.origin)
                        if DistanceCheck < spellE.range then
                            champDistance = DistanceCheck
                        end
                    end
                    if minionDistance < jungleDistance and minionDistance < champDistance then
                        spellbook:cast_spell(SLOT_E, 0.15, minion.origin.x, minion.origin.y, minion.origin.z)
                        GapClose = true
                        e_cast = client:get_tick_count() + 1
                    end
                    if jungleDistance < minionDistance and jungleDistance < champDistance then
                        spellbook:cast_spell(SLOT_E, 0.15, jungle.origin.x, jungle.origin.y, jungle.origin.z)
                        GapClose = true
                         e_cast = client:get_tick_count() + 1
                    end
                    if champDistance < minionDistance and champDistance < jungleDistance then
                        spellbook:cast_spell(SLOT_E, 0.15, champ.origin.x, champ.origin.y, champ.origin.z)
                        GapClose = true
                        e_cast = client:get_tick_count() + 1
                    end
                end
                if GapClose and e_cast and spellbook:get_spell_slot(SLOT_W).can_cast and not ml.Ready(SLOT_E) then
                    if client:get_tick_count() >= e_cast then
                        spellbook:cast_spell(SLOT_W, 0.1, local_player.origin.x, local_player.origin.y, local_player.origin.z)
                    end
                end
            end
        end
    end
end

local function LastHit()

end

local function Flee()

end

local function Auto()
    local Mode = combo:get_mode()
    if game:is_key_down(menu:get_value(Kcombo_combokey)) then
        Combo()
    elseif Mode == MODE_HARASS then
        Harass()
    elseif Mode == MODE_LANECLEAR then
        LaneClear()
        JungleClear()
    elseif Mode == MODE_LASTHIT then
        LastHit()
    elseif Mode == MODE_FLEE then
        Flee()
    end
end

local function on_tick()
    if not local_player:has_buff("karatinarsound") then
        orbwalker:enable_move()
    else
        local _, count = ml.GetEnemyCount(local_player.origin, (spellR.range - 50))
        if count > 0 then
            orbwalker:disable_auto_attacks()
            orbwalker:disable_move()
        else
            orbwalker:enable_auto_attacks()
            orbwalker:enable_move()
        end
    end
    --Is this necesary?
    if (size(objHolder) == 0) then
        orbwalker:enable_move()
    end
    if not spellbook:get_spell_slot(SLOT_W).can_cast then
        GapClose = false
    end
    if menu:get_value(Kcombo_magnet) == 1 then
        local enemies = ml.GetEnemyHeroes()
        for i, enemy in ipairs(enemies) do
            if enemy and ml.IsValid(enemy) and local_player:distance_to(enemy.origin) < 1000 and not ml.is_invulnerable(enemy) then
                if not local_player:has_buff("katarinarsound") and size(objHolder) > 0 then
                    local closestDagger = GetClosestDagger()
                    if closestDagger and enemy:distance_to(local_player.origin) < 500 then
                        local direction = ml.Sub(closestDagger.origin, enemy.origin):normalized()
                        local extendedPos = ml.Sub(closestDagger.origin, ml.VectorMag(direction, 150))
                        if (game:is_key_down(menu:get_value(Kcombo_combokey)) and closestDagger:distance_to(local_player.origin) >= 160) then
                            orbwalker:disable_move()
                            orbwalker:move_to(extendedPos.x, extendedPos.y, extendedPos.z)
                        else
                            orbwalker:enable_move()
                        end
                    end
                end
            end
        end
    end
    KillSteal()
    Auto()
end

local function on_buff_active(obj, buff_name)
    if buff_name == "katarinarsound" then
        local _, count = ml.GetEnemyCount(local_player.origin, (spellR.range - 50))
        if count > 0 then
            orbwalker:disable_auto_attacks()
            orbwalker:disable_move()
        else
            orbwalker:enable_auto_attacks()
            orbwalker:enable_move()
        end
    end
end

local function on_buff_end(obj, buff_name)
    if buff_name == "katarinarsound" then
        orbwalker:enable_auto_attacks()
        orbwalker:enable_move()
    end
end

local function on_draw()

end

client:set_event_callback("on_object_created", on_object_created)
client:set_event_callback("on_object_deleted", on_object_deleted)
client:set_event_callback("on_draw", on_draw)
client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_buff_active", on_buff_active)
client:set_event_callback("on_buff_end", on_buff_end)