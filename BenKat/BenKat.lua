if game.local_player.champ_name ~= "Katarina" then
    return
end

--file_manager:encrypt_file("BenKat.lua")

--[[
do 
    local function AutoUpdate()
        local Version = 1
        local file_name = "BenKat.lua"
        local url = ""
        local web_version = http:get("")
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
--]]

pred:use_prediction()

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
Kcombo_magnet = menu:add_checkbox("Magnet to Daggers", Kcombo, 1)

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

local_player = game.local_player

local spellQ = {
    range = 625
}

local spellW = {
    range = 400
}

local spellE = {
    range = 725
}

local spellR = {
    range = 550
}

local function GetMousePos()
    x, y, z = game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z
    local output = vec3.new(x, y, z)
    return output
end

local function in_list(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

local allowing = true
local objHolder = {}
function on_object_created(object, obj_name)
    if object and obj_name == "Katarina_Base_W_Indicator_Ally" then
        if not in_list(objHolder, object) then
            table.insert(objHolder, object)
        end
    end
end

function on_object_deleted(object, obj_name)
    if object and obj_name == "Katarina_Base_W_Indicator_Ally" then
        table.insert(objHolder, nil)
    end
end

local function VectorSub(vec1, vec2)
    x1, y1, z1 = vec1.x, vec1.y, vec1.z
    x2, y2, z2 = vec2.x, vec2.y, vec2.z
    new_x = x1 - x2
    new_y = y1 - y2
    new_z = z1 - z2
    output = vec3.new(new_x, new_y, new_z)
    return output
end

local function DirectionMag(vec, mag)
    x, y, z = vec.x, vec.y, vec.z
    new_x = mag * x 
    new_y = mag * y 
    new_z = mag * z 
    output = vec3.new(new_x, new_y, new_z)
    return output
end

local function Ready(spell)
    return spellbook:can_cast(spell)
end

local function IsValid(unit)
    if (unit and unit.is_targetable and unit.is_alive and unit.is_visible and unit.object_id and unit.health > 0) then
        return true
    end
    return false
end

local timer = 0
local TimeW = 0
local TimeR = 0
local function Spellsssss(slot, vec3, vec3, networkID, isInjected)

end

local function is_under_tower(target)
    local turrets = game.turrets
    local turret_range = 800
    for i, unit in ipairs(turrets) do
        if unit and unit.is_turret and unit.is_alive then
            if unit:distance_to(target.origin) <= turret_range then
                return true
            end
        end
    end
    return false
end

local function GetEnemyHeroes()
    local _EnemyHeroes = {}
	players = game.players	
	for i, unit in ipairs(players) do
		if unit and unit.is_enemy then
			table.insert(_EnemyHeroes, unit)
		end
	end	
	return _EnemyHeroes
end

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

local function GetDistanceSqr(unit, p2)
    p2 = p2 or local_player.origin
    p2x, p2y, p2z = p2.x, p2.y, p2.z
    p1 = unit.origin
    p1x, p1y, p1z = p1.x, p1.y, p1.z
    local dx = p1x - p2x
    local dz = (p1z or p1y) - (p2z or p2y)
    return dx*dx + dz*dz
end

local function GetShieldedHealth(damageType, target)
    local shield = 0
    if damageType == "AD" then
        shield = target.shield
    elseif damageType == "AP" then
        shield = target.magic_shield
    elseif damageType == "ALL" then
        shield = target.shield
    end
    return target.health + shield
end

local function count_enemies_in_range(pos, range)
    local enemies_in_range = {}
    for i = 1, #game.players do
        local enemy = game.players[i]
        if enemy:distance_to(pos) <= range and enemy.team ~= local_player.team then
            enemies_in_range[#enemies_in_range + 1] = enemy
        end
    end
    return enemies_in_range
end

local function count_minions_in_range(pos, range)
    local enemies_in_range = {}
    for i = 1, #game.minions do
        local enemy = game.minions[i]
        if enemy:distance_to(pos) <= range and enemy.team ~= local_player.team then
            enemies_in_range[#enemies_in_range + 1] = enemy
        end
    end
    return enemies_in_range
end

local function count_jungle_minions_in_range(pos, range)
    local enemies_in_range = {}
    for i = 1, #game.jungle_minions do
        local enemy = game.jungle_minions[i]
        if enemy:distance_to(pos) <= range then
            enemies_in_range[#enemies_in_range + 1] = enemy
        end
    end
    return enemies_in_range
end

local function GetEnemyCount(pos, range)
    count = 0
    local enemies_in_range = {}
	for i, hero in ipairs(GetEnemyHeroes()) do
	    Range = range * range
		if hero:distance_to(pos) < Range and IsValid(hero) then
            table.insert(enemies_in_range, enemy)
            count = count + 1
		end
	end
	return enemies_in_range, count
end

local function GetMinionCount(pos, range)
	count = 0
    local enemies_in_range = {}
	minions = game.minions
	for i, minion in ipairs(minions) do
	Range = range * range
		if minion.is_enemy and IsValid(minion) and minion:distance_to(pos) < Range then
            table.insert(enemies_in_range, minion)
			count = count + 1
		end
	end
	return enemies_in_range, count
end

local function GetJungleMinionCount(pos, range)
    count = 0
    local enemies_in_range = {}
	minions = game.jungle_minions
	for i, minion in ipairs(minions) do
	Range = range * range
		if minion.is_enemy and IsValid(minion) and minion:distance_to(pos) < Range then
            table.insert(enemies_in_range, minion)
			count = count + 1
		end
	end
	return enemies_in_range, count
end

local function GetClosestJungle()
    local mousepos = GetMousePos()
    local enemyMinions = GetJungleMinionCount(mousepos, spellE.range)
    local closestMinion = nil
    local closestMinionDistance = 9999 
    for i, minion in pairs(enemyMinions) do
        if minion and minion.object_id ~= local_player.object_id then
            if minion:distance_to(mousepos) < 200 then
                local minionDistanceToMouse = minion:distance_to(mousepos)
                if minionDistanceToMouse < closestMinionDistance then
                    closestMinion = minion
                    closestMinionDistance = minionDistanceToMouse
                end
            end
        end
    end
    return closestMinion
end

local function GetClosestMob()
    local mousepos = GetMousePos()
    local enemyMinions = GetMinionCount(mousepos, spellE.range)
    local closestMinion = nil
    local closestMinionDistance = 9999 
    for i, minion in pairs(enemyMinions) do
        if minion and minion.object_id ~= local_player.object_id then
            if minion:distance_to(mousepos) < 200 then
                local minionDistanceToMouse = minion:distance_to(mousepos)
                if minionDistanceToMouse < closestMinionDistance then
                    closestMinion = minion
                    closestMinionDistance = minionDistanceToMouse
                end
            end
        end
    end
    return closestMinion
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

local function GetClosestMobToEnemy()
    local mousepos = GetMousePos()
    local enemyMinions = GetMinionCount(mousepos, spellE.range)
    local closestMinion = nil
    local closestMinionDistance = 9999
    local enemy = GetEnemyHeroes()
    for i, enemies in ipairs(enemy) do
        if enemies and IsValid(enemies) then
            local hp = GetShieldedHealth("AP", enemies)
            for i, minion in pairs(enemyMinions) do
                if minion then
                    if minion:distance_to(enemies.origin) < spellQ.range then
                        local minionDistanceToMouse = minion:distance_to(enemies.origin)
                        if minionDistanceToMouse < closestMinionDistance then
                            closestMinion = minion
                            closestMinionDistance = minionDistanceToMouse
                        end
                    end
                end
            end
        end
    end
    return closestMinion
end

local function GetClosestJungleEnemy()
    local mousepos = GetMousePos()
    local enemyMinions = GetJungleMinionCount(mousepos, spellE.range)
    local closestMinion = nil
    local closestMinionDistance = 9999
    local enemy = GetEnemyHeroes()
    for i, enemies in ipairs(enemy) do
        if enemies and IsValid(enemies) then
            local hp = GetShieldedHealth("AP", enemies)
            for i, minion in pairs(enemyMinions) do
                if minion then
                    if minion:distance_to(enemies.origin) < spellQ.range then
                        local minionDistanceToMouse = minion:distance_to(enemies.origin)
                        if minionDistanceToMouse < closestMinionDistance then
                            closestMinion = minion
                            closestMinionDistance = minionDistanceToMouse
                        end
                    end
                end
            end
        end
    end
    return closestMinion
end

local function on_draw()

end

--local function on_level(level)
    --if level > MyHeroLvl then
        --MyHeroLvl = level
    --end
--end

--local GameTimer = game:get_gametime()
--local QLastCast = game:get_gametime()
local MyHeroLvl = 1
local DaggerObjGround = "Katarina_Base_Dagger_Ground_Indicator"
local DaggerObjQ = "Katarina_base_Q_tar"
local DaggerObjW = "Katarina_Base_W_Indicator_Ally"

local function CastQ(target)

end

local function CastW(target)

end

local function CastE(target)

end

local function CastR(target)

end

local TargetSelectionQ = function(res, obj, dist)
    if dist < spellQ.range then
        res.obj = obj
        return true
    end
end

local TargetSelectionE = function(res, obj, dist)
    if dist < spellE.range then
        res.obj = obj
        return true
    end
end

local TargetSelectionW = function(res, obj, dist)
    if dist < spellW.range then
        res.obj = obj
        return true
    end
end

local TargetSelectionR = function(res, obj, dist)
    if dist < spellR.range then
        res.obj = obj
        return true
    end
end

function size()
    local count = 0
    for _ in pairs(objHolder) do
        count = count + 1
    end
    return count
end

local GetTargetQ = function()
    return selector:find_target(spellQ.range, health)
end

local GetTargetW = function()
    return selector:find_target(spellW.range, health)
end

local GetTargetE = function()
    return selector:find_target(spellE.range, health)
end

local GetTargetR = function()
    return selector:find_target(spellR.range, health)
end

local uhhfarm = false
local somethingfarm = 0

local uhh = false
local something = 0

local function ToggleFarm()
    if (uhhfarm == false and os.clock() > somethingfarm) then
        uhhfarm = true
        somethingfarm = os.clock() + 0.3
    end
    if (uhhfarm == true and os.clock() > somethingfarm) then
        uhhfarm = false
        somethingfarm = os.clock() + 0.3
    end
end

local function ToggleHarass()
    if (uhh == false and os.clock() > something) then
        uhh = true
        something = os.clock() + 0.3
    end
    if (uhh == true and os.clock() > something) then
        uhh = false
        something = os.clock() + 0.3
    end
end

local function GetItems()
    local inventory = {}
    for _, v in ipairs(local_player.items) do
        if v and not in_list(inventory, v) then
            table.insert(inventory, v.item_id)
        end
    end
    return inventory
end

--THIS MAY BE A PROBLEM
local function SlotSet(slot_str)
    local output = 0
    if slot_str == "SLOT_ITEM1" then
        output = SLOT_ITEM1
    elseif slot_str == "SLOT_ITEM2" then
        output = SLOT_ITEM2
    elseif slot_str == "SLOT_ITEM3" then
        output = SLOT_ITEM3
    elseif slot_str == "SLOT_ITEM4" then
        output = SLOT_ITEM4
    elseif slot_str == "SLOT_ITEM5" then
        output = SLOT_ITEM5
    elseif slot_str == "SLOT_ITEM6" then
        output = SLOT_ITEM6
    end
    return output
end

local function OnHitDmg(target, effectiveness)
    local OH_AP = 0
    local OH_AD = 0
    local OH_TD = 0
    local damage = 0
    local inventory = GetItems()
    for _, v in ipairs(inventory) do
        --BORK
        if tonumber(v) == 3153 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    OH_AD = OH_AD + 0.1*target.health
                end
            end
        --Dead Man's Plate
        elseif tonumber(v) == 3742 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    --spell_slot.count, spell_slot.effect_amount, spell_slot.ammo_used for stacks?
                    local stacks = 100
                    OH_AP = OH_AP + (stacks)
                end
            end
        --Duskblade
        elseif tonumber(v) == 6691 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    OH_AD = OH_AD + 65 + (0.25 * local_player.bonus_attack_damage)
                end
            end
        --Eclipse
        elseif tonumber(v) == 6692 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    OH_AD = OH_AD + (0.06 * target.max_health)
                end
            end
        --Guinsoo's
        elseif tonumber(v) == 3124 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    --This damage is affected by crit modifiers
                    --Confirm if this is decimal or percent
                    OH_AD = OH_AD + (2 * 100 * local_player.crit_chance)
                end
            end
        --Kircheis Shard
        elseif tonumber(v) == 2015 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    OH_AP = OH_AP + 80
                end
            end
        --Nashor's
        elseif tonumber(v) == 3115 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    OH_AP = OH_AP + 15 + (0.2 * local_player.ability_power)
                end
            end
        --Noonquiver
        elseif tonumber(v) == 6670 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    OH_AD = OH_AD + 20
                end
            end
        --Rageknife
        elseif tonumber(v) == 6677 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    --Confirm if this is decimal or percent
                    OH_AD = OH_AD + (1.75 * 100 * local_player.crit_chance)
                end
            end
        --RFC
        elseif tonumber(v) == 3094 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    OH_AP = OH_AP + 120
                end
            end
        --Recurve Bow
        elseif tonumber(v) == 1043 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    OH_AD = OH_AD + 15
                end
            end
        --Stormrazor
        elseif tonumber(v) == 3095 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    OH_AP = OH_AP + 120
                end
            end
        --Tiamat
        elseif tonumber(v) == 3077 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    OH_AD = OH_AD + (0.6 * local_player.total_attack_damage)
                end
            end
        --Titanic Hydra
        elseif tonumber(v) == 3748 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    OH_AD = OH_AD + 5 + (0.015 * local_player.max_health)
                end
            end
        --Trinity Force
        elseif tonumber(v) == 3078 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    OH_AD = OH_AD + (2 * local_player.base_attack_damage)
                end 
            end
        --Wit's End
        elseif tonumber(v) == 3091 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    local level = local_player.level
                    OH_AP = OH_AP + ({15, 18.82, 22.65, 26.47, 30.29, 34.12, 37.94, 41.76, 45.59, 49.41, 53.24, 57.06, 60.88, 64.71, 68.53, 72.35, 76.18, 80})[level]
                end 
            end
        --Divine Sunderer
        elseif tonumber(v) == 6632 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    OH_AD = OH_AD + math.max((1.5 * local_player.base_attack_damage), (0.1 * target.max_health))
                end
            end
        --Essence Reaver
        elseif tonumber(v) == 3508 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    OH_AD = OH_AD + (local_player.base_attack_damage) + (0.4 * local_player.bonus_attack_damage)
                end
            end
        --Lich Bane
        elseif tonumber(v) == 3100 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    OH_AP = OH_AP + (1.5 * local_player.base_attack_damage) + (0.4 * local_player.ability_power)
                end   
            end
        --Sheen
        elseif tonumber(v) == 3057 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    OH_AD = OH_AD + (local_player.base_attack_damage)
                end
            end
        --Kraken Slayer
        elseif tonumber(v) == 6672 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    --Confirm this can only be cast when third shot is up
                    OH_TD = OH_TD + 60 + (0.45 * local_player.bonus_attack_damage)
                end
            end
        end
    end
    damage = effectiveness*(target:calculate_phys_damage(OH_AD) + target:calculate_magic_damage(OH_AP) + OH_TD)
    return damage
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
    local OHDamage = OnHitDmg(target, 1)
    damage = target:calculate_magic_damage(EDamage) + OHDamage
    return damage
end

local function RDamage(target)
    local damage = 0
    local level = spellbook:get_spell_slot(SLOT_R).level
    local daggers = menu:get_value(r_usage_dags)
    local RDamage_AD = (0.16 + (0.658 * local_player.bonus_attack_speed * 0.128)) * local_player.bonus_attack_damage
    local RDamage_AP = ({25, 37.5, 50})[level] + (0.19 * local_player.ability_power)
    local OHDamage = OnHitDmg(target, ({0.25, 0.3, 0.35})[level])
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
    local OHDamage = OnHitDmg(target, 1)
    damage = target:calculate_magic_damage(PDamage) + OHDamage
    return damage
end

local function is_invulnerable(target)
    if target:has_buff_type(18) then
        return true
    end
    return false
end

--Doesn't ult if Q on cooldown
--Doesn't Q half the time
--Last combo mode stops working at level 6
--Ult positioning needs work
--Confirm R only when killable
local function Combo()
    if menu:get_value(r_usage_cancelr) == 1 then
        if local_player:has_buff("katarinarsound") then
            _, count = GetEnemyCount(local_player.origin, spellR.range + 10)
            if (count == 0) then
                orbwalker:move_to()
            end
        end
    end
    if menu:get_value(r_usage_rks) == 1 then
        local target = GetTargetE()
        if target and target.is_visible then
            if IsValid(target) then
                if (local_player:distance_to(target.origin) <= spellE.range) then
                    if not is_invulnerable(target) then
                        if local_player:has_buff("katarinarsound") then
                            if (local_player:distance_to(target.origin) >= spellR.range - 100 and Ready(SLOT_E)) then
                                if (size() > 0) then
                                    for _, objs in pairs(objHolder) do
                                        if objs then
                                            if (target:distance_to(objs.origin) < 450 and target:distance_to(local_player.origin) < spellE.range and Ready(SLOT_E)) then
                                                if menu:get_value(Kcombo_eturret) == 1 then
                                                    if not is_under_tower(objs) then
                                                        allowing = true
                                                        --local direction = (objs.origin - target.origin):normalized()
                                                        --local extendedPos = objs.origin - direction * 200
                                                        local direction = VectorSub(objs.origin, target.origin):normalized()
                                                        local extendedPos = VectorSub(objs.origin, DirectionMag(direction, 200))
                                                        if Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            orbwalker:reset_aa()
                                                        end
                                                    end
                                                else
                                                    allowing = true
                                                    --local direction = (objs.origin - target.origin):normalized()
                                                    --local extendedPos = objs.pos - direction * 200
                                                    local direction = VectorSub(objs.origin, target.origin):normalized()
                                                    local extendedPos = VectorSub(objs.origin, DirectionMag(direction, 200))
                                                    if Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        orbwalker:reset_aa()
                                                    end
                                                end
                                            end
                                            if (local_player:distance_to(objs.origin) > spellE.range and local_player:distance_to(target.origin) < spellE.range and Ready(SLOT_E)) then
                                                if menu:get_value(Kcombo_eturret) == 1 then
                                                    if not is_under_tower(target) then
                                                        allowing = true
                                                        --local direction = (target.origin - local_player.origin).normalized()
                                                        --local extendedPos = target.origin - direction * -50
                                                        local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                        if Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            orbwalker:reset_aa()
                                                        end
                                                    end
                                                else
                                                    allowing = true
                                                    --local direction = (target.origin - local_player.origin).normalized()
                                                    --local extendedPos = target.origin - direction * -50
                                                    local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                    local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                    if Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        orbwalker:reset_aa()
                                                    end
                                                end
                                            end
                                            if (target:distance_to(objs.origin) > 450 and target:distance_to(local_player.origin) < spellE.range and Ready(SLOT_E)) then
                                                if menu:get_value(Kcombo_eturret) == 1 then
                                                    if not is_under_tower(target) then
                                                        allowing = true
                                                        --local direction = (target.origin - local_player.origin):normalized()
                                                        --local extendedPos = target.origin - direction * -50
                                                        local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                        if Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            orbwalker:reset_aa()
                                                        end
                                                    end
                                                else
                                                    allowing = true
                                                    --local direction = (target.origin - local_player.origin).normalized()
                                                    --local extendedPos = target.origin - direction * -50
                                                    local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                    local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                    if Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        orbwalker:reset_aa()
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                                if (size() == 0) then
                                    if Ready(SLOT_E) then
                                        if menu:get_value(Kcombo_eturret) == 1 then
                                            if not is_under_tower(target) then
                                                allowing = true
                                                --local direction = (target.origin - local_player.origin).normalized()
                                                --local extendedPos = target.origin - direction * -50
                                                local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                if Ready(SLOT_E) then
                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                    orbwalker:reset_aa()
                                                end
                                            end
                                        else
                                            allowing = true
                                            --local direction = (target.origin - local_player.origin).normalized()
                                            --local extendedPos = target.origin - direction * -50
                                            local direction = VectorSub(target.origin, local_player.origin):normalized()
                                            local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                            if Ready(SLOT_E) then
                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                orbwalker:reset_aa()
                                            end
                                        end
                                    end
                                end
                            end
                            if (EDamage(target) >= target.health and Ready(SLOT_E)) then --damage calculations COME BACK AND ADD THIS (EXAMPLE LUA LINE 788)
                                if (size() > 0) then
                                    for _, objs in pairs(objHolder) do
                                        if objs then
                                            if (target:distance_to(objs.origin) < 450) then
                                                if menu:get_value(Kcombo_eturret) == 1 then
                                                    if not is_under_tower(objs.origin) then
                                                        allowing = true
                                                        --local direction = (objs.origin - target.origin).normalized()
                                                        --local extendedPos = objs.origin - direction * 200
                                                        local direction = VectorSub(objs.origin, target.origin):normalized()
                                                        local extendedPos = VectorSub(objs.origin, DirectionMag(direction, 200))
                                                        if Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            orbwalker:reset_aa()
                                                        end
                                                    end
                                                else
                                                    allowing = true
                                                    --local direction = (objs.origin - target.origin):normalized()
                                                    --local extendedPos = objs.origin - direction * 200
                                                    local direction = VectorSub(objs.origin, target.origin):normalized()
                                                    local extendedPos = VectorSub(target.origin, DirectionMag(direction, 200))
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        orbwalker:reset_aa()
                                                end
                                            end
                                            if (objs:distance_to(local_player.origin) > spellE.range) then
                                                if menu:get_value(Kcombo_eturret) == 1 then
                                                    if not is_under_tower(target) then
                                                        allowing = true
                                                        --local direction = (target.origin - local_player.origin).normalized()
                                                        --local extendedPos = target.origin - direction * -50
                                                        local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                        if Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            orbwalker:reset_aa()
                                                        end
                                                    end
                                                else
                                                    allowing = true
                                                    --local direction = (target.origin - local_player.origin).normalized()
                                                    --local extendedPos = target.origin - direction * -50
                                                    local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                    local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                    if Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        orbwalker:reset_aa()
                                                    end
                                                end
                                            end
                                            if (target:distance_to(objs.origin) > 450) then
                                                if menu:get_value(Kcombo_eturret) == 1 then
                                                    if not is_under_tower(target) then
                                                        allowing = true
                                                        --local direction = (target.origin - local_player.origin).normalized()
                                                        --local extendedPos = target.origin - direction * -50
                                                        local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                        if Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            orbwalker:reset_aa()
                                                        end
                                                    end
                                                else
                                                    allowing = true
                                                    --local direction = (target.origin - local_player.origin).normalized()
                                                    --local extendedPos = target.origin - direction * -50
                                                    local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                    local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                    if Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        orbwalker:reset_aa()
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                                if (size() == 0 and Ready(SLOT_E)) then
                                    if menu:get_value(Kcombo_eturret) == 1 then
                                        if not is_under_tower(target) then
                                            allowing = true
                                            --local direction = (target.origin - local_player.origin).normalized()
                                            --local extendedPos = target.origin - direction * -50
                                            local direction = VectorSub(target.origin, local_player.origin):normalized()
                                            local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                            if Ready(SLOT_E) then
                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                orbwalker:reset_aa()
                                            end
                                        end
                                    else
                                        allowing = true
                                        --local direction = (target.origin - local_player.origin).normalized()
                                        --local extendedPos = target.origin - direction * -50
                                        local direction = VectorSub(target.origin, local_player.origin):normalized()
                                        local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                        if Ready(SLOT_E) then
                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                            orbwalker:reset_aa()
                                        end
                                    end
                                end
                                if (target:distance_to(local_player.origin) < spellQ.range and Ready(SLOT_Q)) then
                                    allowing = true
                                    if Ready(SLOT_E) then
                                        spellbook:cast_spell(SLOT_E, 0.25, target.origin.x, target.origin.y, target.origin.z)
                                        orbwalker:reset_aa()
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
        if IsValid(target) then
            if not local_player:has_buff("katarinarsound") then
                --if menu:get_value(Kcombo_useitems) == 1 then NO ITEMS ANYMORE, DON'T NEED THIS SECTION
                if menu:get_value(Kcombo_combomode) == 0 then 
                    if menu:get_value(Kcombo_useq) == 1 then
                        if (target:distance_to(local_player.origin) <= spellQ.range) then
                            if Ready(SLOT_E) then
                                spellbook:cast_spell(SLOT_E, 0.25, target.origin.x, target.origin.y, target.origin.z)
                                orbwalker:reset_aa()
                            end
                        end
                    end
                    if menu:get_value(Kcombo_usee) == 1 and Ready(SLOT_Q) then
                        if (size() > 0) then
                            for _, objs in pairs(objHolder) do
                                if objs then
                                    if menu:get_value(Kcombo_savee) == 0 then
                                        if (target:distance_to(objs.origin) < 450) then
                                            if menu:get_value(Kcombo_eturret) == 1 then
                                                if not is_under_tower(objs) then
                                                    --local direction = (objs.origin - target.origin):normalized()
                                                    --local extendedPos = objs.origin - direction * 200
                                                    local direction = VectorSub(objs.origin, target.origin):normalized()
                                                    local extendedPos = VectorSub(objs.origin, DirectionMag(direction, 200))
                                                    if Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        orbwalker:reset_aa()
                                                    end
                                                end
                                            else
                                                --local direction = (objs.origin - target.origin):normalized()
                                                --local extendedPos = objs.origin - direction * 200
                                                local direction = VectorSub(objs.origin, target.origin):normalized()
                                                local extendedPos = VectorSub(objs.origin, DirectionMag(direction, 200))
                                                if Ready(SLOT_E) then
                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                    orbwalker:reset_aa()
                                                end
                                            end
                                        end
                                        if menu:get_value(Kcombo_emode) == 0 then --CONFIRM THIS, VALUE IS DIFFERENT THAN KORNIS (KORNIS - 1)
                                            if objs:distance_to(local_player.origin) > spellE.range then
                                                if menu:get_value(Kcombo_eturret) == 1 then
                                                    if not is_under_tower(target) then
                                                        --local direction = (target.origin - local_player.origin):normalized()
                                                        --local extendedPos = target.origin - direction * 50
                                                        local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                                        if Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            orbwalker:reset_aa()
                                                        end
                                                    end
                                                else
                                                    --local direction = (target.origin - local_player.origin):normalized()
                                                    --local extendedPos = target.origin - direction * 50
                                                    local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                    local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                                    if Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        orbwalker:reset_aa()
                                                    end
                                                end
                                            end
                                            if (objs:distance_to(target.origin) > 450) then
                                                if menu:get_value(Kcombo_eturret) == 1 then
                                                    if not is_under_tower(target) then
                                                        --local direction = (target.origin - local_player.origin):normalized()
                                                        --local extendedPos = target.origin - direction * 50
                                                        local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                                        if Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            orbwalker:reset_aa()
                                                        end
                                                    end
                                                else
                                                    --local direction = (target.origin - local_player.origin):normalized()
                                                    --local extendedPos = target.origin - direction * 50
                                                    local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                    local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                                    if Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        orbwalker:reset_aa()
                                                    end
                                                end
                                            end
                                        end
                                        if menu:get_value(Kcombo_emode) == 1 then
                                            if objs:distance_to(local_player.origin) > spellE.range then
                                                if menu:get_value(Kcombo_eturret) == 1 then
                                                    if not is_under_tower(target) then
                                                        --local direction = (target.origin - local_player.origin):normalized()
                                                        --local extendedPos = target.origin - direction * -50
                                                        local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                        if Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            orbwalker:reset_aa()
                                                        end
                                                    end
                                                    --local direction = (target.origin - local_player.origin):normalized()
                                                    --local extendedPos = target.origin - direction * -50
                                                    local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                    local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                    if Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        orbwalker:reset_aa()
                                                    end
                                                end
                                            end
                                            if (objs:distance_to(target.origin) > 450) then
                                                if menu:get_value(Kcombo_eturret) == 1 then
                                                    if not is_under_tower(target) then
                                                        --local direction = (target.origin - local_player.origin):normalized()
                                                        --local extendedPos = target.origin - direction * -50
                                                        local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                        if Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            orbwalker:reset_aa()
                                                        end
                                                    end
                                                else
                                                    --local direction = (target.origin - local_player.origin):normalized()
                                                    --local extendedPos = target.origin - direction * -50
                                                    local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                    local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                    if Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        orbwalker:reset_aa()
                                                    end
                                                end
                                            end
                                        end
                                        if menu:get_value(Kcombo_emode) == 2 then
                                            if not Ready(SLOT_R) or spellbook:get_spell_slot(SLOT_R).level == 0 then --CONFIRM THIS LINE WORKS
                                                if objs:distance_to(local_player.origin) > spellE.range then
                                                    if menu:get_value(Kcombo_eturret) == 1 then
                                                        if not is_under_tower(target) then
                                                            --local direction = (target.origin - local_player.origin).normalized()
                                                            --local extendedPos = target.origin - direction * 50
                                                            local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                            local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                                            if Ready(SLOT_E) then
                                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                                orbwalker:reset_aa()
                                                            end
                                                        end
                                                    else
                                                        --local direction = (target.origin - local_player.origin).normalized()
                                                        --local extendedPos = target.origin - direction * 50
                                                        local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                                        if Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            orbwalker:reset_aa()
                                                        end
                                                    end
                                                end
                                                if (objs:distance_to(target.origin) > 450) then
                                                    if menu:get_value(Kcombo_eturret) == 1 then
                                                        if not is_under_tower(target) then
                                                            --local direction = (target.origin - local_player.origin).normalized()
                                                            --local extendedPos = target.origin - direction * 50
                                                            local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                            local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                                            if Ready(SLOT_E) then
                                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                                orbwalker:reset_aa()
                                                            end
                                                        end
                                                    else
                                                        --local direction = (target.origin - local_player.origin).normalized()
                                                        --local extendedPos = target.origin - direction * 50
                                                        local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                                        if Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            orbwalker:reset_aa()
                                                        end
                                                    end
                                                end
                                            end
                                            if Ready(SLOT_R) then
                                                if objs:distance_to(local_player.origin) > spellE.range then
                                                    if menu:get_value(Kcombo_eturret) == 1 then
                                                        if not is_under_tower(target) then
                                                            --local direction = (target.origin - local_player.origin):normalized()
                                                            --local extendedPos = target.origin - direction * -50
                                                            local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                            local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                            if Ready(SLOT_E) then
                                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                                orbwalker:reset_aa()
                                                            end
                                                        end
                                                    else
                                                        --local direction = (target.origin - local_player.origin):normalized()
                                                        --local extendedPos = target.origin - direction * -50
                                                        local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                        if Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            orbwalker:reset_aa()
                                                        end
                                                    end
                                                end
                                                if (objs:distance_to(target.origin) > 450) then
                                                    if menu:get_value(Kcombo_eturret) == 1 then
                                                        if not is_under_tower(target) then
                                                            --local direction = (target.origin - local_player.origin):normalized()
                                                            --local extendedPos = target.origin - direction * -50
                                                            local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                            local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                            if Ready(SLOT_E) then
                                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                                orbwalker:reset_aa()
                                                            end
                                                        end
                                                    else
                                                        --local direction = (target.origin - local_player.origin):normalized()
                                                        --local extendedPos = target.origin - direction * -50
                                                        local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                        if Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            orbwalker:reset_aa()
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                    if menu:get_value(Kcombo_savee) == 1 then
                                        if menu:get_value(Kcombo_eturret) == 1 then
                                            if not is_under_tower(target) then
                                                --local direction = (target.origin - local_player.origin):normalized()
                                                --local extendedPos = target.origin - direction * 200
                                                local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                local extendedPos = VectorSub(target.origin, DirectionMag(direction, 200))
                                                if Ready(SLOT_E) then
                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                    orbwalker:reset_aa()
                                                end
                                            end
                                        else
                                            --local direction = (target.origin - local_player.origin):normalized()
                                            --local extendedPos = target.origin - direction * 200
                                            local direction = VectorSub(target.origin, local_player.origin):normalized()
                                            local extendedPos = VectorSub(target.origin, DirectionMag(direction, 200))
                                            if Ready(SLOT_E) then
                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                orbwalker:reset_aa()
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if (size() == 0) then
                        if menu:get_value(Kcombo_savee) == 0 then
                            if menu:get_value(Kcombo_emode) == 0 then
                                if menu:get_value(Kcombo_eturret) == 1 then
                                    if not is_under_tower(target) then
                                        --local direction = (target.origin - local_player.origin):normalized()
                                        --local extendedPos = target.origin - direction * 50
                                        local direction = VectorSub(target.origin, local_player.origin):normalized()
                                        local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                        if Ready(SLOT_E) then
                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                            orbwalker:reset_aa()
                                        end
                                    end
                                else
                                    --local direction = (target.origin - local_player.origin):normalized()
                                    --local extendedPos = target.origin - direction * 50
                                    local direction = VectorSub(target.origin, local_player.origin):normalized()
                                    local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                    if Ready(SLOT_E) then
                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                        orbwalker:reset_aa()
                                    end
                                end
                            end
                            if menu:get_value(Kcombo_emode) == 1 then
                                if menu:get_value(Kcombo_eturret) == 1 then
                                    if not is_under_tower(target) then
                                        --local direction = (target.origin - local_player.origin):normalized()
                                        --local extendedPos = target.origin - direction * -50
                                        local direction = VectorSub(target.origin, local_player.origin):normalized()
                                        local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                        if Ready(SLOT_E) then
                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                            orbwalker:reset_aa()
                                        end
                                    end
                                else
                                    --local direction = (target.origin - local_player.origin):normalized()
                                    --local extendedPos = target.origin - direction * -50
                                    local direction = VectorSub(target.origin, local_player.origin):normalized()
                                    local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                    if Ready(SLOT_E) then
                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                        orbwalker:reset_aa()
                                    end
                                end
                            end
                            if menu:get_value(Kcombo_emode) == 2 then
                                if not Ready(SLOT_R) or spellbook:get_spell_slot(SLOT_R).level == 0 then
                                    if menu:get_value(Kcombo_eturret) == 1 then
                                        if not is_under_tower(target) then
                                            if not is_under_tower(target) then
                                                --local direction = (target.origin - local_player.origin):normalized()
                                                --local extendedPos = target.origin - direction * 50
                                                local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                                if Ready(SLOT_E) then
                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                    orbwalker:reset_aa()
                                                end
                                            end
                                        else
                                            --local direction = (target.origin - local_player.origin):normalized()
                                            --local extendedPos = target.origin - direction * 50
                                            local direction = VectorSub(target.origin, local_player.origin):normalized()
                                            local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                            if Ready(SLOT_E) then
                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                orbwalker:reset_aa()
                                            end
                                        end
                                    end
                                    if Ready(SLOT_R) then
                                        if menu:get_value(Kcombo_eturret) == 1 then
                                            if not is_under_tower(target) then
                                                --local direction = (target.origin - local_player.origin):normalized()
                                                --local extendedPos = target.origin - direction * -50
                                                local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                if Ready(SLOT_E) then
                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                    orbwalker:reset_aa()
                                                end
                                            end
                                        else
                                            --local direction = (target.origin - local_player.origin):normalized()
                                            --local extendedPos = target.origin - direction * -50
                                            local direction = VectorSub(target.origin, local_player.origin):normalized()
                                            local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                            if Ready(SLOT_E) then
                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                orbwalker:reset_aa()
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if menu:get_value(Kcombo_usew) == 1 then
                        _, count = GetEnemyCount(local_player.origin, spellW.range)
                        if (count > 0) then
                            local target = GetTargetW()
                            if target and target.is_visible then
                                if IsValid(target) then
                                    if (target:distance_to(local_player.origin) <= spellW.range) then
                                        if Ready(SLOT_W) then
                                            spellbook:cast_spell(SLOT_W, 0.1, target.origin.x, target.origin.y, target.origin.z)
                                        end
                                    end
                                end
                            end
                        end
                    end
                    --If closest enemy is close to edge case, don't R
                    if menu:get_value(r_usage) == 0 and Ready(SLOT_R) then
                        if (target:distance_to(local_player.origin) <= spellR.range - 50) then
                            _, count = GetEnemyCount(local_player.origin, spellR.range - 100)
                            if (count >= menu:get_value(r_usage_num)) then
                                if (target.health >= menu:get_value(r_usage_waste) and not Ready(SLOT_Q)) then
                                    if not Ready(SLOT_W) then
                                        if Ready(SLOT_E) then
                                            spellbook:cast_spell(SLOT_E, 0.15, target.origin.x, target.origin.y, target.origin.z)
                                        end
                                        spellbook:cast_spell(SLOT_R, 0.1, local_player.origin.x, local_player.origin.y, local_player.origin.z)
                                    elseif Ready(SLOT_W) then
                                        if Ready(SLOT_E) then
                                            spellbook:cast_spell(SLOT_E, 0.15, target.origin.x, target.origin.y, target.origin.z)
                                        end
                                        spellbook:cast_spell(SLOT_W, 0.1, local_player.origin.x, local_player.origin.y, local_player.origin.z)
                                        spellbook:cast_spell(SLOT_R, 0.1, local_player.origin.x, local_player.origin.y, local_player.origin.z)
                                    end
                                end
                            end
                        end
                    end
                    if menu:get_value(r_usage) == 1 and Ready(SLOT_R) then
                        if (target:distance_to(local_player.origin) <= spellR.range - 50) then
                            --Line 1132, adds in dmglib getspelldamage at the end, what is this?
                            if (target.health <= RDamage(target) + EDamage(target) + PDamage(target)) then 
                                if (target.health >= menu:get_value(r_usage_waste) and not Ready(SLOT_Q)) then
                                    if not Ready(SLOT_W) then
                                        if Ready(SLOT_E) then
                                            spellbook:cast_spell(SLOT_E, 0.15, target.origin.x, target.origin.y, target.origin.z)
                                        end
                                        spellbook:cast_spell(SLOT_R, 0.1, local_player.origin.x, local_player.origin.y, local_player.origin.z)
                                    elseif Ready(SLOT_W) then
                                        if Ready(SLOT_E) then
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
                        if (size() > 0) then
                            for _, objs in pairs(objHolder) do
                                if objs then
                                    if menu:get_value(Kcombo_savee) == 0 then
                                        if target:distance_to(objs.origin) < 450 then
                                            if menu:get_value(Kcombo_eturret) == 1 then
                                                if not is_under_tower(objs) then
                                                    --local direction = (objs.origin - target.origin):normalized()
                                                    --local extendedPos = objs.origin - direction * 200
                                                    local direction = VectorSub(objs.origin, target.origin):normalized()
                                                    local extendedPos = VectorSub(objs.origin, DirectionMag(direction, 200))
                                                    if Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        orbwalker:reset_aa()
                                                    end
                                                end
                                            else
                                                --local direction = (objs.origin - target.origin):normalized()
                                                --local extendedPos = objs.origin - direction * 200
                                                local direction = VectorSub(objs.origin, target.origin):normalized()
                                                local extendedPos = VectorSub(objs.origin, DirectionMag(direction, 200))
                                                if Ready(SLOT_E) then
                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                    orbwalker:reset_aa()
                                                end
                                            end
                                        end
                                        if menu:get_value(Kcombo_emode) == 0 then
                                            if objs:distance_to(local_player.origin) > spellE.range then
                                                if menu:get_value(Kcombo_eturret) == 1 then
                                                    if not is_under_tower(target) then
                                                        --local direction = (target.origin - local_player.origin):normalized()
                                                        --local extendedPos = target.origin - direction * 50
                                                        local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                                        if Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            orbwalker:reset_aa()
                                                        end
                                                    end
                                                else
                                                    --local direction = (target.origin - local_player.origin):normalized()
                                                    --local extendedPos = target.origin - direction * 50
                                                    local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                    local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                                    if Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        orbwalker:reset_aa()
                                                    end
                                                end
                                            end
                                            if (objs:distance_to(target.origin) > 450) then
                                                if menu:get_value(Kcombo_eturret) == 1 then
                                                    if not is_under_tower(target) then
                                                        --local direction = (target.origin - local_player.origin):normalized()
                                                        --local extendedPos = target.origin - direction * 50
                                                        local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                                        if Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            orbwalker:reset_aa()
                                                        end
                                                    end
                                                else
                                                    --local direction = (target.origin - local_player.origin):normalized()
                                                    --local extendedPos = target.origin - direction * 50
                                                    local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                    local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                                    if Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        orbwalker:reset_aa()
                                                    end
                                                end
                                            end
                                        end
                                        if menu:get_value(Kcombo_emode) == 1 then
                                            if objs:distance_to(local_player.origin) > spellE.range then
                                                if menu:get_value(Kcombo_eturret) == 1 then
                                                    if not is_under_tower(target) then
                                                        --local direction = (target.origin - local_player.origin):normalized()
                                                        --local extendedPos = target.origin - direction * -50
                                                        local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                        if Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            orbwalker:reset_aa()
                                                        end
                                                    end
                                                else
                                                    --local direction = (target.origin - local_player.origin):normalized()
                                                    --local extendedPos = target.origin - direction * -50
                                                    local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                    local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                    if Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        orbwalker:reset_aa()
                                                    end
                                                end
                                            end
                                            if (objs:distance_to(target.origin) > 450) then
                                                if menu:get_value(Kcombo_eturret) == 1 then
                                                    if not is_under_tower(target) then
                                                        --local direction = (target.origin - local_player.origin):normalized()
                                                        --local extendedPos = target.origin - direction * -50
                                                        local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                        if Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            orbwalker:reset_aa()
                                                        end
                                                    end
                                                else
                                                    --local direction = (target.origin - local_player.origin):normalized()
                                                    --local extendedPos = target.origin - direction * -50
                                                    local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                    local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        orbwalker:reset_aa()
                                                end
                                            end
                                        end
                                        if menu:get_value(Kcombo_emode) == 2 then
                                            if not Ready(SLOT_R) or spellbook:get_spell_slot(SLOT_R).level == 0 then
                                                if objs:distance_to(local_player.origin) > spellE.range then
                                                    if menu:get_value(Kcombo_eturret) == 1 then
                                                        if not is_under_tower(target) then
                                                            --local direction = (target.origin - local_player.origin):normalized()
                                                            --local extendedPos = target.origin - direction * 50
                                                            local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                            local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                                            if Ready(SLOT_E) then
                                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                                orbwalker:reset_aa()
                                                            end
                                                        end
                                                    else
                                                        --local direction = (target.origin - local_player.origin):normalized()
                                                        --local extendedPos = target.origin - direction * 50
                                                        local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                                        if Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            orbwalker:reset_aa()
                                                        end
                                                    end
                                                end
                                                if (objs:distance_to(target.origin) > 450) then
                                                    if menu:get_value(Kcombo_eturret) == 1 then
                                                        if not is_under_tower(target) then
                                                            --local direction = (target.origin - local_player.origin):normalized()
                                                            --local extendedPos = target.origin - direction * 50
                                                            local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                            local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                                            if Ready(SLOT_E) then
                                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                                orbwalker:reset_aa()
                                                            end
                                                        end
                                                    else
                                                        --local direction = (target.origin - local_player.origin):normalized()
                                                        --local extendedPos = target.origin - direction * 50
                                                        local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                                        if Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            orbwalker:reset_aa()
                                                        end
                                                    end
                                                end
                                            end
                                            if Ready(SLOT_R) then
                                                if objs:distance_to(local_player.origin) > spellE.range then
                                                    if menu:get_value(Kcombo_eturret) == 1 then
                                                        if not is_under_tower(target) then
                                                            --local direction = (target.origin - local_player.origin):normalized()
                                                            --local extendedPos = target.origin - direction * -50
                                                            local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                            local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                            if Ready(SLOT_E) then
                                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                                orbwalker:reset_aa()
                                                            end
                                                        end
                                                    else
                                                        --local direction = (target.origin - local_player.origin):normalized()
                                                        --local extendedPos = target.origin - direction * -50
                                                        local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                        if Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            orbwalker:reset_aa()
                                                        end
                                                    end
                                                end
                                                if (objs:distance_to(target.origin) > 450) then
                                                    if menu:get_value(Kcombo_eturret) == 1 then
                                                        if not is_under_tower(target) then
                                                            --local direction = (target.origin - local_player.origin):normalized()
                                                            --local extendedPos = target.origin - direction * -50
                                                            local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                            local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                            if Ready(SLOT_E) then
                                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                                orbwalker:reset_aa()
                                                            end
                                                        end
                                                    else
                                                        --local direction = (target.origin - local_player.origin):normalized()
                                                        --local extendedPos = target.origin - direction * -50
                                                        local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                        if Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            orbwalker:reset_aa()
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                    if menu:get_value(Kcombo_savee) == 1 then
                                        if (target:distance_to(objs.origin) < 450) then
                                            if menu:get_value(Kcombo_eturret) == 1 then
                                                if not is_under_tower(objs) then
                                                    --local direction = (objs.origin - target.origin):normalized()
                                                    --local extendedPos = objs.origin - direction * 200
                                                    local direction = VectorSub(objs.origin, target.origin):normalized()
                                                    local extendedPos = VectorSub(objs.origin, DirectionMag(direction, 200))
                                                    if Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        orbwalker:reset_aa()
                                                    end
                                                end
                                            else
                                                --local direction = (objs.origin - target.origin):normalized()
                                                --local extendedPos = objs.origin - direction * 200
                                                local direction = VectorSub(objs.origin, target.origin):normalized()
                                                local extendedPos = VectorSub(objs.origin, DirectionMag(direction, 200))
                                                if Ready(SLOT_E) then
                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                    orbwalker:reset_aa()
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        if (size() == 0) then
                            if menu:get_value(Kcombo_savee) == 0 then
                                if menu:get_value(Kcombo_emode) == 0 then
                                    if menu:get_value(Kcombo_eturret) == 1 then
                                        if not is_under_tower(target) then
                                            --local direction = (target.origin - local_player.origin):normalized()
                                            --local extendedPos = target.origin - direction * 50
                                            local direction = VectorSub(target.origin, local_player.origin):normalized()
                                            local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                            if Ready(SLOT_E) then
                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                orbwalker:reset_aa()
                                            end
                                        end
                                    else
                                        --local direction = (target.origin - local_player.origin):normalized()
                                        --local extendedPos = target.origin - direction * 50
                                        local direction = VectorSub(target.origin, local_player.origin):normalized()
                                        local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                        if Ready(SLOT_E) then
                                            pellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                            orbwalker:reset_aa()
                                        end
                                    end
                                end
                                if menu:get_value(Kcombo_emode) == 1 then
                                    if menu:get_value(Kcombo_eturret) == 1 then
                                        if not is_under_tower(target) then
                                            --local direction = (target.origin - local_player.origin):normalized()
                                            --local extendedPos = target.origin - direction * -50
                                            local direction = VectorSub(target.origin, local_player.origin):normalized()
                                            local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                            if Ready(SLOT_E) then
                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                orbwalker:reset_aa()
                                            end
                                        end
                                    else
                                        --local direction = (target.origin - local_player.origin):normalized()
                                        --local extendedPos = target.origin - direction * -50
                                        local direction = VectorSub(target.origin, local_player.origin):normalized()
                                        local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                        if Ready(SLOT_E) then
                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                            orbwalker:reset_aa()
                                        end
                                    end
                                end
                                if menu:get_value(Kcombo_emode) == 2 then
                                    if not Ready(SLOT_R) or spellbook:get_spell_slot(SLOT_R).level == 0 then
                                        if menu:get_value(Kcombo_eturret) == 1 then
                                            if not is_under_tower(target) then
                                                --local direction = (target.origin - local_player.origin):normalized()
                                                --local extendedPos = target.origin - direction * 50
                                                local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                                if Ready(SLOT_E) then
                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                    orbwalker:reset_aa()
                                                end
                                            end
                                        else
                                            --local direction = (target.origin - local_player.origin):normalized()
                                            --local extendedPos = target.origin - direction * 50
                                            local direction = VectorSub(target.origin, local_player.origin):normalized()
                                            local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                            if Ready(SLOT_E) then
                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                orbwalker:reset_aa()
                                            end
                                        end
                                    end
                                    if Ready(SLOT_R) then
                                        if menu:get_value(Kcombo_eturret) == 1 then
                                            if not is_under_tower(target) then
                                                --local direction = (target.origin - local_player.origin):normalized()
                                                --local extendedPos = target.origin - direction * -50
                                                local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                if Ready(SLOT_E) then
                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                    orbwalker:reset_aa()
                                                end
                                            end
                                        else
                                            --local direction = (target.origin - local_player.origin):normalized()
                                            --local extendedPos = target.origin - direction * -50
                                            local direction = VectorSub(target.origin, local_player.origin):normalized()
                                            local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                            if Ready(SLOT_E) then
                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                orbwalker:reset_aa()
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if menu:get_value(Kcombo_usew) == 1 then
                        _, count = GetEnemyCount(local_player.origin, spellW.range)
                        if (count > 0) then
                            local target = GetTargetW()
                            if target and target.is_visible then
                                if IsValid(target) then
                                    if target:distance_to(local_player.origin) <= spellW.range then
                                        if Ready(SLOT_E) then
                                            spellbook:cast_spell(SLOT_W, 0.1, target.origin.x, target.origin.y, target.origin.z)
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if (menu:get_value(Kcombo_useq) == 1) then
                        if (target:distance_to(local_player.origin) <= spellQ.range) and Ready(SLOT_Q) then
                            if Ready(SLOT_Q) then
                                spellbook:cast_spell(SLOT_Q, 0.25, target.origin.x, target.origin.y, target.origin.z)
                            end
                        end
                    end
                    if menu:get_value(r_usage) == 0 and Ready(SLOT_R) then
                        if (target:distance_to(local_player.origin) <= spellR.range - 50) then
                            _, count = GetEnemyCount(local_player.origin, spellR.range - 100)
                            if (count >= menu:get_value(r_usage_num)) then
                                if (target.health >= menu:get_value(r_usage_waste) and not Ready(SLOT_Q)) then
                                    if not Ready(SLOT_W) then
                                        spellbook:cast_spell(SLOT_R, 0.1, local_player.origin.x, local_player.origin.y, local_player.origin.z)
                                    end
                                end
                            end
                        end
                    end
                    if menu:get_value(r_usage) == 1 and Ready(SLOT_R) then
                        if (target:distance_to(local_player.origin) <= spellR.range - 50) then
                            --Line 1132, adds in dmglib getspelldamage at the end, what is this?
                            if (target.health <= RDamage(target) + EDamage(target) + PDamage(target)) then 
                                if (target.health >= menu:get_value(r_usage_waste) and not Ready(SLOT_Q)) then
                                    if not Ready(SLOT_W) then
                                        spellbook:cast_spell(SLOT_R, 0.1, local_player.origin.x, local_player.origin.y, local_player.origin.z)
                                    end
                                end
                            end
                        end
                    end
                end
                if menu:get_value(Kcombo_combomode) == 2 then
                    --if menu:get_value(Kcombo_useq) == 1 and not Ready(SLOT_R) and TimeR < os.clock() then
                    if menu:get_value(Kcombo_useq) == 1 then
                        if target:distance_to(local_player.origin) <= spellQ.range then
                            if Ready(SLOT_Q) then
                                spellbook:cast_spell(SLOT_Q, 0.25, target.origin.x, target.origin.y, target.origin.z)
                            end
                        end
                        if menu:get_value(Kcombo_usee) == 1 then
                            if (size() > 0) then
                                for _, objs in pairs(objHolder) do
                                    if objs then
                                        if menu:get_value(Kcombo_savee) == 0 then
                                            if target:distance_to(objs.origin) < 450 then
                                                if menu:get_value(Kcombo_eturret) == 1 then
                                                    if not is_under_tower(objs) then
                                                        local direction = VectorSub(objs.origin, target.origin):normalized()
                                                        local extendedPos = VectorSub(objs.origin, DirectionMag(direction, 200))
                                                        if Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            orbwalker:reset_aa()
                                                        end
                                                    end
                                                else
                                                    local direction = VectorSub(objs.origin, target.origin):normalized()
                                                    local extendedPos = VectorSub(objs.origin, DirectionMag(direction, 200))
                                                    if Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        orbwalker:reset_aa()
                                                    end
                                                end
                                                if menu:get_value(Kcombo_emode) == 0 then
                                                    if objs:distance_to(local_player.origin) > spellE.range then
                                                        if menu:get_value(Kcombo_eturret) == 1 then
                                                            if not is_under_tower(target) then
                                                                local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                                local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                                                if Ready(SLOT_E) then
                                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                                    orbwalker:reset_aa()
                                                                end
                                                            end
                                                        else
                                                            local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                            local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                                            if Ready(SLOT_E) then
                                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                                orbwalker:reset_aa()
                                                            end
                                                        end
                                                    end
                                                    if objs:distance_to(target.origin) > 450 then
                                                        if menu:get_value(Kcombo_eturret) == 1 then
                                                            if not is_under_tower(target) then
                                                                local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                                local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                                                if Ready(SLOT_E) then
                                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                                    orbwalker:reset_aa()
                                                                end
                                                            end
                                                        else
                                                            local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                            local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                                            if Ready(SLOT_E) then
                                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                                orbwalker:reset_aa()
                                                            end
                                                        end
                                                    end
                                                end
                                                if menu:get_value(Kcombo_emode) == 1 then
                                                    if objs:distance_to(local_player.origin) > spellE.range then
                                                        if menu:get_value(Kcombo_eturret) == 1 then
                                                            if not is_under_tower(target) then
                                                                local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                                local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                                if Ready(SLOT_E) then
                                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                                    orbwalker:reset_aa()
                                                                end
                                                            end
                                                        else
                                                            local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                            local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                            if Ready(SLOT_E) then
                                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                                orbwalker:reset_aa()
                                                            end
                                                        end
                                                    end
                                                    if objs:distance_to(target.origin) > 450 then
                                                        if menu:get_value(Kcombo_eturret) == 1 then
                                                            if not is_under_tower(target) then
                                                                local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                                local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                                if Ready(SLOT_E) then
                                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                                    orbwalker:reset_aa()
                                                                end
                                                            end
                                                            local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                            local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                            if Ready(SLOT_E) then
                                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                                orbwalker:reset_aa()
                                                            end
                                                        end
                                                    end
                                                end
                                                if menu:get_value(Kcombo_emode) == 2 then
                                                    if not Ready(SLOT_R) or spellbook:get_spell_slot(SLOT_R).level == 0 then
                                                        if objs:distance_to(local_player.origin) > spellE.range then
                                                            if menu:get_value(Kcombo_eturret) == 1 then
                                                                if not is_under_tower(target) then
                                                                    local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                                    local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                                                    if Ready(SLOT_E) then
                                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                                        orbwalker:reset_aa()
                                                                    end
                                                                end
                                                            else
                                                                local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                                local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                                                if Ready(SLOT_E) then
                                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                                    orbwalker:reset_aa()
                                                                end
                                                            end
                                                        end
                                                        if objs:distance_to(local_player.origin) > 450 then
                                                            if menu:get_value(Kcombo_eturret) == 1 then
                                                                if not is_under_tower(target) then
                                                                    local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                                    local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                                                    if Ready(SLOT_E) then
                                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                                        orbwalker:reset_aa()
                                                                    end
                                                                end
                                                            else
                                                                local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                                local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                                                if Ready(SLOT_E) then
                                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                                    orbwalker:reset_aa()
                                                                end
                                                            end
                                                        end
                                                    end
                                                    if Ready(SLOT_R) then
                                                        if objs:distance_to(local_player.origin) > spellE.range then
                                                            if menu:get_value(Kcombo_eturret) == 1 then
                                                                if not is_under_tower(target) then
                                                                    local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                                    local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                                    if Ready(SLOT_E) then
                                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                                        orbwalker:reset_aa()
                                                                    end
                                                                end
                                                            else
                                                                local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                                local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                                if Ready(SLOT_E) then
                                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                                    orbwalker:reset_aa()
                                                                end
                                                            end
                                                        end
                                                        if objs:distance_to(target.origin) > 450 then
                                                            if menu:get_value(Kcombo_eturret) == 1 then
                                                                if not is_under_tower(target) then
                                                                    local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                                    local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                                    if Ready(SLOT_E) then
                                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                                        orbwalker:reset_aa()
                                                                    end
                                                                end
                                                            else
                                                                local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                                local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                                if Ready(SLOT_E) then
                                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                                    orbwalker:reset_aa()
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                            if menu:get_value(Kcombo_savee) == 1 then
                                                if target:distance_to(objs.origin) < 450 then
                                                    if menu:get_value(Kcombo_eturret) == 1 then
                                                        if not is_under_tower(objs) then
                                                            local direction = VectorSub(objs.origin, target.origin):normalized()
                                                            local extendedPos = VectorSub(objs.origin, DirectionMag(direction, 200))
                                                            if Ready(SLOT_E) then
                                                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                                orbwalker:reset_aa()
                                                            end
                                                        end
                                                    else
                                                        local direction = VectorSub(objs.origin, target.origin):normalized()
                                                        local extendedPos = VectorSub(objs.origin, DirectionMag(direction, 200))
                                                        if Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            orbwalker:reset_aa()
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                                if (size() == 0) then
                                    if menu:get_value(Kcombo_savee) == 0 then
                                        if menu:get_value(Kcombo_emode) == 0 then
                                            if menu:get_value(Kcombo_eturret) == 1 then
                                                if not is_under_tower(target) then
                                                    local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                    local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                                    if Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        orbwalker:reset_aa()
                                                    end
                                                end
                                            else
                                                local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                                if Ready(SLOT_E) then
                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                    orbwalker:reset_aa()
                                                end
                                            end
                                        end
                                        if menu:get_value(Kcombo_emode) == 1 then
                                            if menu:get_value(Kcombo_eturret) == 1 then
                                                if not is_under_tower(target) then
                                                    local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                    local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                    if Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        orbwalker:reset_aa()
                                                    end
                                                end
                                            else
                                                local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                if Ready(SLOT_E) then
                                                    spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                    orbwalker:reset_aa()
                                                end
                                            end
                                        end
                                        if menu:get_value(Kcombo_emode) == 2 then
                                            if not Ready(SLOT_R) or spellbook:get_spell_slot(SLOT_R).level == 0 then
                                                if menu:get_value(Kcombo_eturret) == 1 then
                                                    if not is_under_tower(target) then
                                                        local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                                        if Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            orbwalker:reset_aa()
                                                        end
                                                    end
                                                else
                                                    local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                    local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                                    if Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        orbwalker:reset_aa()
                                                    end
                                                end
                                            end
                                            if Ready(SLOT_R) then
                                                if menu:get_value(Kcombo_eturret) == 1 then
                                                    if not is_under_tower(target) then
                                                        local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                        local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                        if Ready(SLOT_E) then
                                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                            orbwalker:reset_aa()
                                                        end
                                                    end
                                                else
                                                    local direction = VectorSub(target.origin, local_player.origin):normalized()
                                                    local extendedPos = VectorSub(target.origin, DirectionMag(direction, -50))
                                                    if Ready(SLOT_E) then
                                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                                        orbwalker:reset_aa()
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            if menu:get_value(Kcombo_usew) == 1 then
                                _, count = GetEnemyCount(local_player.origin, spellW.range)
                                if (count > 0) then
                                    local target = GetTargetW()
                                    if target and target.is_visible then
                                        if IsValid(target) then
                                            if target:distance_to(local_player.origin) <= spellW.range then
                                                if Ready(SLOT_W) then
                                                    spellbook:cast_spell(SLOT_W, 0.1, target.origin.x, target.origin.y, target.origin.z)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            if (target:distance_to(local_player.origin) <= spellR.range - 50) then
                                if not Ready(SLOT_W) then
                                    if Ready(SLOT_R) then
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
    local target = GetTargetE()
    if target and target.is_visible then
        if IsValid(target) then
            if menu:get_value(Kharass_mode) == 0 then
                if menu:get_value(Kharass_usew) == 1 then
                    _, count = GetEnemyCount(local_player.origin, spellW.range)
                    if (count > 0) then
                        local target = GetTargetW()
                        if target and target.is_visible then
                            if IsValid(target) then
                                if target:distance_to(local_player.origin) <= spellW.range then
                                    if Ready(SLOT_W) then
                                        spellbook:cast_spell(SLOT_W, 0.1, target.origin.x, target.origin.y, target.origin.z)
                                    end
                                end
                            end
                        end
                    end
                end
                if menu:get_value(Kharass_useq) == 1 then
                    if target:distance_to(local_player.origin) <= spellQ.range then
                        if Ready(SLOT_Q) then
                            spellbook:cast_spell(SLOT_Q, 0.25, target.origin.x, target.origin.y, target.origin.z)
                        end
                    end
                end
                if menu:get_value(Kharass_usee) == 1 and not Ready(SLOT_Q) then
                    if target:distance_to(local_player.origin) <= spellE.range then
                        for _, objs in pairs(objHolder) do
                            if objs then
                                if target:distance_to(objs.origin) < 450 then
                                    local direction = VectorSub(objs.origin, target.origin):normalized()
                                    local extendedPos = VectorSub(objs.origin, DirectionMag(direction, 200))
                                    if Ready(SLOT_E) then
                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                        orbwalker:reset_aa()
                                    end
                                end
                                if objs:distance_to(local_player.origin) > spellE.range then
                                    local direction = VectorSub(target.origin, local_player.origin):normalized()
                                    local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                    if Ready(SLOT_E) then
                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                        orbwalker:reset_aa()
                                    end
                                end
                                if target:distance_to(objs.origin) > 450 then
                                    if Ready(SLOT_Q) then
                                        spellbook:cast_spell(SLOT_Q, 0.25, target.origin.x, target.origin.y, target.origin.z)
                                    end
                                end
                            end
                        end
                        if (size() == 0) then
                            local direction = VectorSub(target.origin, local_player.origin):normalized()
                            local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                            if Ready(SLOT_E) then
                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                orbwalker:reset_aa()
                            end
                        end
                    end
                end
            end
            if menu:get_value(Kharass_mode) == 1 then
                if menu:get_value(Kharass_usew) == 1 then
                    _, count = GetEnemyCount(local_player.origin, spellW.range)
                    if (count > 0) then
                        local target = GetTargetW()
                        if target and target.is_visible then
                            if IsValid(target) then
                                if target:distance_to(local_player.origin) <= spellW.range then
                                    if Ready(SLOT_W) then
                                        spellbook:cast_spell(SLOT_W, 0.1, target.origin.x, target.origin.y, target.origin.z)
                                    end
                                end
                            end
                        end
                    end
                end
                if menu:get_value(Kharass_usee) == 1 then
                    if target:distance_to(local_player.origin) <= spellE.range then
                        for _, objs in pairs(objHolder) do
                            if objs then
                                if target:distance_to(objs.origin) < 450 then
                                    local direction = VectorSub(objs.origin, target.origin):normalized()
                                    local extendedPos = VectorSub(objs.origin, DirectionMag(direction, 200))
                                    if Ready(SLOT_E) then
                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                        orbwalker:reset_aa()
                                    end
                                end
                                if objs:distance_to(local_player.origin) > spellE.range then
                                    local direction = VectorSub(target.origin, local_player.origin):normalized()
                                    local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                                    if Ready(SLOT_E) then
                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                        orbwalker:reset_aa()
                                    end
                                end
                                if target:distance_to(objs.origin) > 450 then
                                    if Ready(SLOT_Q) then
                                        spellbook:cast_spell(SLOT_Q, 0.25, target.origin.x, target.origin.y, target.origin.z)
                                    end
                                end
                            end
                        end
                        if (size() == 0) then
                            local direction = VectorSub(target.origin, local_player.origin):normalized()
                            local extendedPos = VectorSub(target.origin, DirectionMag(direction, 50))
                            if Ready(SLOT_E) then
                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                orbwalker:reset_aa()
                            end
                        end
                    end
                end
                if menu:get_value(Kharass_useq) == 1 then
                    if target:distance_to(local_player.origin) <= spellQ.range then
                        if Ready(SLOT_E) then
                            spellbook:cast_spell(SLOT_Q, 0.25, target.origin.x, target.origin.y, target.origin.z)
                        end
                    end
                end
            end
        end
    end
end

local function LaneClear()
    --[[
    if uhhfarm == true then
        if menu:get_value(Kclear_useq) == 1 and menu:get_value(Kclear_q_lasthit) == 1 then
            enemyMinionsE, _ = GetMinionCount(local_player.origin, spellQ.range)
            for i, minion in pairs(enemyMinionsE) do
                if minion and minion.is_alive and IsValid(minion) then
                    if QDamage(minion) >= minion.health then
                        if menu:get_value(Kclear_q_lasthit_range) == 0 then
                            if Ready(SLOT_Q) then
                                spellbook:cast_spell(SLOT_Q, 0.25, minion.origin.x, minion.origin.y, minion.origin.z)
                            end
                        end
                        if menu:get_value(Kclear_q_lasthit_range) == 1 and minion:distance_to(local_player.origin) > 250 then
                            if Ready(SLOT_Q) then
                                spellbook:cast_spell(SLOT_Q, 0.25, minion.origin.x, minion.origin.y, minion.origin.z)
                            end
                        end
                    end
                end
            end
        end
        if (menu:get_value(Kclear_useq) == 1 and menu:get_value(Kclear_q_lasthit) == 0) then
            enemyMinionsQ, _ = GetMinionCount(local_player.origin, spellQ.range)
            for i, minion in pairs(enemyMinionsQ) do
                if minion and minion.is_alive and IsValid(minion) then
                    if minion:distance_to(local_player.origin) <= spellQ.range then
                        if Ready(SLOT_Q) then
                            spellbook:cast_spell(SLOT_Q, 0.25, minion.origin.x, minion.origin.y, minion.origin.z)
                        end
                    end
                end
            end
        end
        if menu:get_value(Kclear_usew) == 1 then
            enemyMinionsE, count = GetMinionCount(local_player.origin, 450)
            for i, minion in pairs(enemyMinionsE) do
                if minion and minion.is_alive and IsValid(minion) then
                    if count >= menu:get_value(Kclear_w_hits) and Ready(SLOT_W) then
                        spellbook:cast_spell(SLOT_W, 0.1, minion.origin.x, minion.origin.y, minion.origin.z)
                    end
                end
            end
        end
        if menu:get_value(Kclear_usee) == 1 and TimeW < os.clock() then
            enemyMinionsE, count = GetMinionCount(local_player.origin, spellE.range)
            for i, minion in pairs(enemyMinionsE) do
                if minion and minion.is_alive and IsValid(minion) then
                    for _, objs in pairs(objHolder) do
                        if objs then
                            local direction = VectorSub(objs.origin, minion.origin):normalized()
                            local extendedPos = VectorSub(objs.origin, DirectionMag(direction, 200))
                            if count >= menu:get_value(Kclear_e_hits) then
                                local direction = VectorSub(objs.origin, minion.origin):normalized()
                                local extendedPos = VectorSub(objs.origin, DirectionMag(direction, 200))
                                if menu:get_value(Kclear_turret) == 1 then
                                    if not is_under_tower(objs) then
                                        if Ready(SLOT_E) then
                                            spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                            orbwalker:reset_aa()
                                        end
                                    end
                                else
                                    if Ready(SLOT_E) then
                                        spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                        orbwalker:reset_aa()
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    ]]
end

local function JungleClear()
    --[[
    if (uhhfarm) then
        if menu:get_value(Kclear_useq) == 1 then  
            enemyMinionsQ, _ = GetJungleMinionCount(local_player.origin, spellQ.range)
            for i, minion in pairs(enemyMinionsQ) do
                if minion and minion.is_alive and IsValid(minion) then
                    if minion:distance_to(local_player.origin) <= spellQ.range then
                        if Ready(SLOT_Q) then
                            spellbook:cast_spell(SLOT_Q, 0.25, minion.origin.x, minion.origin.y, minion.origin.z)
                        end
                    end
                end
            end
        end
        if menu:get_value(Kclear_usew) == 1 then
            enemyMinionsE, _ = GetJungleMinionCount(local_player.origin, 250)
            for i, minion in pairs(enemyMinionsE) do
                if minion and minion.is_alive and IsValid(minion) then
                    if minion:distance_to(local_player.origin) <= 300 then
                        if Ready(SLOT_W) then
                            spellbook:cast_spell(SLOT_W, 0.1, minion.origin.x, minion.origin.y, minion.origin.z)
                        end
                    end
                end
            end
        end
    end
    ]]
end

--Overkill slider
local function KillSteal()
    local enemy = GetEnemyHeroes()
    for i, enemies in ipairs(enemy) do
        if enemies and enemies.is_visible and IsValid(enemies) and not enemies:has_buff_type(18) then
            local hp = GetShieldedHealth("AP", enemies)
            if menu:get_value(KKs_edagger) == 1 then
                for _, objs in pairs(objHolder) do
                    if objs then
                        if (enemies:distance_to(local_player.origin) <= spellE.range and objs:distance_to(enemies.origin) < 450 and PDamage(enemies) > hp) then
                            allowing = true
                            local direction = VectorSub(objs.origin, enemies.origin):normalized()
                            local extendedPos = VectorSub(objs.origin, DirectionMag(direction, 200))
                            if Ready(SLOT_E) then
                                spellbook:cast_spell(SLOT_E, 0.15, extendedPos.x, extendedPos.y, extendedPos.z)
                                orbwalker:reset_aa()
                            end
                        end
                    end
                end
            end
            if menu:get_value(Kks_useq) == 1 then
                if (Ready(SLOT_Q) and enemies:distance_to(local_player.origin) < spellQ.range and QDamage(enemies) > hp) then
                    allowing = true
                    if Ready(SLOT_Q) then
                        spellbook:cast_spell(SLOT_Q, 0.25, enemies.origin.x, enemies.origin.y, enemies.origin.z)
                    end
                end
            end
            if menu:get_value(Kks_usee) == 1 then
                if Ready(SLOT_E) and enemies:distance_to(local_player.origin) < spellQ.range and EDamage(enemies) > hp then
                    allowing = true
                    spellbook:cast_spell(SLOT_E, 0.15, enemies.origin.x, enemies.origin.y, enemies.origin.z)
                end
            end
            if menu:get_value(Kks_egap) == 1 then
                if (Ready(SLOT_Q) and enemies:distance_to(local_player.origin) > spellQ.range and enemies:distance_to(local_player.origin) < spellQ.range + spellR.range - 70 and PDamage(enemies) > hp) then
                    allowing = true
                    --Pass in target to this?
                    local minion = GetClosestMobToEnemy()
                    if minion then
                        if Ready(SLOT_E) then
                            spellbook:cast_spell(SLOT_E, 0.15, minion.origin.x, minion.origin.y, minion.origin.z)
                            if Ready(SLOT_W) then
                                spellbook:cast_spell(SLOT_W, 0.1, minion.origin.x, minion.origin.y, minion.origin.z)
                            end
                        end
                    end
                    --Pass in target to this?
                    local jungle = GetClosestJungleEnemy()
                    if jungle then
                        if Ready(SLOT_E) then
                            spellbook:cast_spell(SLOT_E, 0.15, jungle.origin.x, jungle.origin.y, jungle.origin.z)
                            if Ready(SLOT_W) then
                                spellbook:cast_spell(SLOT_W, 0.1, minion.origin.x, minion.origin.y, minion.origin.z)
                            end
                        end
                    end
                end
            end
        end
    end
end

local function LastHit()
    --[[
    if menu:get_value(Klast_useq) == 1 then
        enemyMinionsQ, _ = GetMinionCount(local_player.origin, spellQ.range)
        for i, minion in pairs(enemyMinionsQ) do
            if minion and minion.is_alive and IsValid(minion) then
                if QDamage(minion) >= target.health then
                    if menu:get_value(Klast_q_lasthit) == 1 and minion:distance_to(local_player.origin) > 300 then
                        spellbook:cast_spell(SLOT_Q, 0.25, minion.origin.x, minion.origin.y, minion.origin.z)
                    end
                    if menu:get_value(Klast_q_lasthit) == 0 then
                        spellbook:cast_spell(SLOT_Q, 0.25, minion.origin.x, minion.origin.y, minion.origin.z)
                    end
                end
            end
        end
    end
    ]]
end

local function Flee()
    if game:is_key_down(menu:get_value(Kflee_key)) then
        orbwalker:move_to()
        if menu:get_value(Kflee_usew) == 1 then
            if Ready(SLOT_W) then
                spellbook:cast_spell(SLOT_W, 0.1, local_player.origin.x, local_player.origin.y, local_player.origin.z)
            end
        end
        if menu:get_value(Kflee_usee) == 1 then
            local minion = GetClosestMob()
            if minion then
                if Ready(SLOT_E) then
                    spellbook:cast_spell(SLOT_E, 0.15, minion.origin.x, minion.origin.y, minion.origin.z)
                end
            end
            local jungle = GetClosestJungle()
            if jungle then
                if Ready(SLOT_E) then
                    spellbook:cast_spell(SLOT_E, 0.15, jungle.origin.x, jungle.origin.y, jungle.origin.z)
                end
            end
        end
        if menu:get_value(Kflee_daggers) == 1 then
            for _, objs in pairs(objHolder) do
                if objs then
                    local mousepos = GetMousePos()
                    if objs:distance_to(mousepos) < 200 then
                        if Ready(SLOT_E) then
                            spellbook:cast_spell(SLOT_E, 0.15, objs.origin.x, objs.origin.y, objs.origin.z)
                        end
                    end
                end
            end
        end
    end
end
--Target selector logic:
--- Prio to targets you can kill in one rotation
--- Prio one-hittable squishies over low health tanks
--- 
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
    if not local_player:has_buff("katarinarsound") then
        allowing = true
        orbwalker:enable_move()
    end
    if (size() == 0) then
        orbwalker:enable_move()
    end
    if menu:get_value(Kcombo_magnet) == 1 then
        local enemy = GetEnemyHeroes()
        for i, enemies in ipairs(enemy) do
            if (enemies and IsValid(enemies) and local_player:distance_to(enemies.origin) < 1000 and not enemies:has_buff_type(18)) then
                if not local_player:has_buff("katarinarsound") and size() > 0 then
                    closestDagger = GetClosestDagger()
                    if closestDagger and enemies:distance_to(local_player.origin) < 500 then
                        local direction = VectorSub(closestDagger.origin, enemies.origin):normalized()
                        local extendedPos = VectorSub(closestDagger.origin, DirectionMag(direction, 150))
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
    --ToggleFarm()
    KillSteal()
    --ToggleHarass()
    if uhh then
        local target = GetTargetQ()
        if target and target.is_visible then
            if IsValid(target) then
                if target:distance_to(local_player.origin) <= spellQ.range then
                    if Ready(SLOT_Q) then
                        spellbook:cast_spell(SLOT_Q, 0.25, target.origin.x, target.origin.y, target.origin.z)
                    end
                end
            end
        end
    end
    Auto()
end

local function updatebuff(buff)
    if buff.name == "katarinarsound" then
        allowing = false

        --If evade is enabled, disable
        _, count = GetEnemyCount(local_player.origin, spellR.range - 50)
        if count > 0 then
            orbwalker:disable_auto_attacks()
            orbwalker:disable_move()
        else
            orbwalker:enable_auto_attacks()
            orbwalker:enable_move()
        end
    end
end

local function removebuff(buff)
    if buff.name == "katarinarsound" then
        allowing = true

        --If evade is disabled, enable

        orbwalker:enable_auto_attacks()
        orbwalker:enable_move()
    end
end

client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
client:set_event_callback("on_object_created", on_object_created)
client:set_event_callback("on_object_deleted", on_object_deleted)
client:set_event_callback("updatebuff", updatebuff)
client:set_event_callback("removebuff", removebuff)