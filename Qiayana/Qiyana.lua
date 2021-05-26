if game.local_player.champ_name ~= "Qiyana" then
    return
end

local file_name = "VectorMath.lua"
if not file_manager:file_exists(file_name) then
   local url = "https://raw.githubusercontent.com/stoneb2/Bruhwalker/main/VectorMath/VectorMath.lua"
   http:download_file(url, file_name)
   console:log("VectorMath Library Downloaded")
   console:log("Please Reload with F5")
end

local ml = require "VectorMath"

qiyana = menu:add_category("Qiyana")
combokey = menu:add_keybinder("Combo Key", qiyana, 32)

--[[
do
    local function AutoUpdate()
        local Version = 4
        local file_name = "VectorMath.lua"
        local url = "https://raw.githubusercontent.com/stoneb2/Bruhwalker/main/VectorMath/VectorMath.lua"
        local web_version = http:get("https://raw.githubusercontent.com/stoneb2/Bruhwalker/main/VectorMath/VectorMath.version.txt")
        console:log("VectorMath Version: "..Version)
        console:log("VectorMath Web Version: "..tonumber(web_version))
        if tonumber(web_version) == Version then
            console:log("VectorMath Library successfully loaded")
        else
            http:download_file(url, file_name)
            console:log("New VectorMath Library Update Available")
            console:log("Please Reload with F5")
        end
    end
    AutoUpdate()
end
--]]

local spellQ = {
    range = 650,
    width = 140,
    cast_time = 0.25,
    range2 = 710,
    effect_radius = 710
}

local spellW = {
    range = 1100,
    effect_radius = 366,
    cast_time = 0.1
}

local spellE = {
    range = 650,
    speed = 600 + local_player.move_speed,
    cast_time = 0.1
}

local spellR ={
    range = 875,
    effect_radius = 11000,
    width = 280,
    cast_time = 0.25
}

local function PassiveBuff()
    if ml.HasBuff(local_player, "qiyanawenchantedbuff") then
        return true
    else
        return false
    end
end

local function QBuff()
    local output = nil 
    if ml.HasBuff(local_player, "QiyanaQ_Rock") then
        output = "rock"
    end
    if ml.HasBuff(local_player, "QiyanaQ_Grass") then
        output = "grass"
    end
    if ml.HasBuff(local_player, "QiyanaQ_Water") then
        output = "water"
    end
    return output
end

local function ProwlerCheck()
    local prowlers = false
    local prowlers_slot = nil
    local inventory = ml.GetItems()
    for _, v in ipairs(inventory) do
        if tonumber(v) == 6693 then
            local item = local_player:get_item(tonumber(v))
            if item ~= 0 then
                prowlers = true
                prowlers_slot = ml.SlotSet("SLOT_ITEM"..tostring(item.slot))
            end
        end
    end
    return prowlers, prowlers_slot
end

prowler_range = 500
local function ProwlerCast(target)
    local prowlers, prowlers_slot = ProwlerCheck()
    if prowlers then
        if spellbook:can_cast(prowlers_slot) then
            spellbook:cast_spell(prowlers_slot, 0.1, target.origin.x, target.origin.y, target.origin.z)
        end
    end
end

local function CastQ(target)
    if PassiveBuff() then
        pred_output = pred:predict(math.huge, spellQ.cast_time, spellQ.range2, spellQ.width, target, false, true)
    else
        pred_output = pred:predict(math.huge, spellQ.cast_time, spellQ.range, spellQ.width, target, false, true)
    end
    --if ml.Ready(SLOT_Q) and pred_output.can_cast then
    if pred_output.can_cast then
        castPos = pred_output.cast_pos
        spellbook:cast_spell(SLOT_Q, spellQ.cast_time, castPos.x, castPos.y, castPos.z)
    end
end

local function CastW(pos)
    if ml.Ready(SLOT_W) then
        spellbook:cast_spell(SLOT_W, spellW.cast_time, pos.x, pos.y, pos.z)
    end
end

local function CastE(target)
    if ml.Ready(SLOT_E) then
        spellbook:cast_spell(SLOT_E, spellE.cast_time, target.origin.x, target.origin.y, target.origin.z)
    end
end

local function CastR(target)

end

local function CastQE(target)
    if ml.Ready(SLOT_E) then
        CastE(target)
        --if not ml.Ready(SLOT_E) then
            spellbook:start_charged_spell(SLOT_Q)
            spellbook:release_charged_spell(SLOT_Q, spellQ.cast_time, target.origin.x, target.origin.y, target.origin.z)
        --end
    end
end

local function QDmg(target)
    local damage = 0
    local level = spellbook:get_spell_slot(SLOT_Q).level
    local q_buff = QBuff()
    if q_buff == "rock" then
        local health_percentage = 100 * (target.health / target.max_health)
        if health_percentage < 50 then
            local QDamage = ({60, 85, 110, 135, 160})[level] + (0.9 * local_player.bonus_attack_damage) + ({36, 51, 66, 81, 96})[level] + (0.54 * local_player.bonus_attack_damage)
        else
            local QDamage = ({60, 85, 110, 135, 160})[level] + (0.9 * local_player.bonus_attack_damage)
        end
    else
        local QDamage = ({60, 85, 110, 135, 160})[level] + (0.9 * local_player.bonus_attack_damage)
    end
    Damage = target:calculate_phys_damage(QDamage)
    return Damage 
end

local function QDmg_empowered(target)
    local damage = 0
    local QDamage = 0
    local level = spellbook:get_spell_slot(SLOT_Q).level
    local health_percentage = 100 * (target.health / target.max_health)
    if health_percentage < 50 then
        QDamage = ({60, 85, 110, 135, 160})[level] + (0.9 * local_player.bonus_attack_damage) + ({36, 51, 66, 81, 96})[level] + (0.54 * local_player.bonus_attack_damage)
    else
        QDamage = ({60, 85, 110, 135, 160})[level] + (0.9 * local_player.bonus_attack_damage)
    end
    Damage = target:calculate_phys_damage(QDamage)
    return Damage
end

local function QDmg_not_empowered(target)
    local damage = 0
    local level = spellbook:get_spell_slot(SLOT_Q).level
    local QDamage = ({60, 85, 110, 135, 160})[level] + (0.9 * local_player.bonus_attack_damage)
    Damage = target:calculate_phys_damage(QDamage)
    return Damage 
end

local function EDmg(target)
    local damage = 0
    local level = spellbook:get_spell_slot(SLOT_E).level
    local EDamage = ({60, 90, 120, 150, 180})[level] + (0.7 * local_player.bonus_attack_damage)
    Damage = target:calculate_phys_damage(EDamage)
    return Damage
end

local function RDmg(target)
    local damage = 0
    local level = spellbook:get_spell_slot(SLOT_R).level
    local RDamage = ({100, 200, 300})[level] + (1.7 * local_player.bonus_attack_damage) + (0.1 * target.max_health)
    Damage = target:calculate_phys_damage(RDamage)
    return Damage
end

local function ComboDmg(target)
    local q1_damage = 0
    local q2_damage = 0
    local e_damage = 0
    local r_damage = 0
    local prowlers_dmg = 0
    local prowlers, prowlers_slot = ProwlerCheck()
    local q_buff = QBuff()
    if prowlers then 
        if spellbook:can_cast(prowlers_slot) then
            prowlers_dmg = 65 + (0.25 * local_player.bonus_attack_damage)
        end
    end
    if ml.Ready(SLOT_Q) and q_buff == "rock" then
        q1_damage = QDmg_empowered(target)
    elseif ml.Ready(SLOT_Q) and q_buff ~= "rock" then
        q1_damage = QDmg_not_empowered(target)
    end
    if ml.Ready(SLOT_W) then
        q2_damage = QDmg_empowered(target)
    end
    if ml.Ready(SLOT_E) then
        e_damage = EDmg(target)
    end
    if ml.Ready(SLOT_R) then
        r_damage = RDmg(target)
    end
    local total_dmg = prowlers_dmg + q1_damage + q2_damage + e_damage + r_damage
    Damage = target:calculate_phys_damage(total_dmg)
    return Damage
end

local function CheckWall(from, to, distance)
    
end

local function IsUltRangeTurret(unit)

end

local function Rotate(startPos, endPos, height, theta)
    local dx, dy = endPos.x - startPos.x, endPos.z - startPos.z
    local px, py = dx * math.cos(ml.D2R(theta)) - dy * math.sin(ml.D2R(theta)), dx * math.sin(ml.D2R(theta)) + dy * math.cos(ml.D2R(theta))
    return vec3.new(px + startPos.x, height, py + startPos.z)
end

local Objects = {[1] = WATER, [2] = GRASS, [3] = WALL, [4] = ANY}

local function FindBestQiyanaWPos(mode)
    mode = mode or Objects.ANY
    local startPos, mPos, height = local_player.origin, ml.GetMousePos(), local_player.origin.y
    --local startPos, mPos, height = local_player.origin, target.origin, local_player.origin.y
    for i = 100, 2000, 100 do
        local endPos = ml.Extend(startPos, mPos, i)
        for j = 20, 360, 20 do
            local testPos = Rotate(startPos, endPos, height, j)
            if game:world_to_screen(testPos.x, testPos.y, testPos.z).is_valid then
                if nav_mesh:is_river(testPos.x, testPos.y, testPos.z) then
                    if mode == Objects.WATER or mode == Objects.ANY then
                        return testPos
                    end
                end
                if nav_mesh:is_wall(testPos.x, testPos.y, testPos.z) then
                    if mode == Objects.WALL or mode == Objects.ANY then
                        return testPos
                    end
                end
                if nav_mesh:is_grass(testPos.x, testPos.y, testPos.z) then
                    if mode == Objects.GRASS or mode == Objects.ANY then
                        return testPos
                    end
                end
            end
        end
    end
    return nil
end

local function CastUlt(target)
    local checks = 4
    local CheckD = math.ceil(tonumber(400 + (0.25 * local_player.bounding_radius) / checks))
    for i = 1, checks, 1 do
        local direction = ml.Sub(target.origin, local_player.origin):normalized()
        local CheckWallPos = ml.Add(target.origin, ml.VectorMag(direction, (CheckD * i)))
        if nav_mesh:is_wall(CheckWallPos.x, CheckWallPos.y, CheckWallPos.z) and ml.Ready(SLOT_R) then
            spellbook:cast_spell(SLOT_R, spellR.cast_time, target.origin.x, target.origin.y, target.origin.z)
        end
    end
    local prowlers, prowlers_slot = ProwlerCheck()
    local prowler_delta = 100
    if prowlers then
        if ml.Ready(SLOT_R) and spellbook:can_cast(prowlers_slot) then
            local extended_pos = ml.Extend(local_player.origin, target.origin, prowler_delta)
            for i = 1, checks, 1 do
                local direction = ml.Sub(target.origin, extended_pos):normalized()
                local CheckWallPos = ml.Add(target.origin, ml.VectorMag(direction, (CheckD * i)))
                if nav_mesh:is_wall(CheckWallPos.x, CheckWallPos.y, CheckWallPos.z) then
                    ProwlerCast(target)
                    spellbook:cast_spell(SLOT_R, spellR.cast_time, target.origin.x, target.origin.y, target.origin.z)
                end
            end
        end
    end
    local delta = 400 + 200 - local_player:distance_to(target.origin)
    if delta > 0 and ml.Ready(SLOT_E) and ml.Ready(SLOT_R) then
        local extended_pos = ml.Extend(local_player.origin, target.origin, delta)
        for i = 1, checks, 1 do
            local direction = ml.Sub(target.origin, extended_pos):normalized()
            local CheckWallPos = ml.Add(target.origin, ml.VectorMag(direction, (CheckD * i)))
            if nav_mesh:is_wall(CheckWallPos.x, CheckWallPos.y, CheckWallPos.z) then
                spellbook:cast_spell(SLOT_E, spellE.cast_time, target.origin.x, target.origin.y, target.origin.z)
                spellbook:cast_spell(SLOT_R, spellR.cast_time, target.origin.x, target.origin.y, target.origin.z)
            end
        end
    end
    if ml.Ready(SLOT_W) and ml.Ready(SLOT_R) then
        local startPos, mPos, height = local_player.origin, target.origin, local_player.origin.y
        for i = 0, 400, 200 do
            local endPos = ml.Extend(startPos, mPos, i)
            for j = 20, 360, 20 do
                local extended_pos = Rotate(startPos, endPos, height, j)
                for i = 1, checks, 1 do
                    local direction = ml.Sub(target.origin, extended_pos):normalized()
                    local CheckWallPos = ml.Add(target.origin, ml.VectorMag(direction, (CheckD * i)))
                    if nav_mesh:is_wall(CheckWallPos.x, CheckWallPos.y, CheckWallPos.z) and target:distance_to(CheckWallPos) < spellR.range then
                        local delta = target:distance_to(CheckWallPos)
                        local cast_pos = ml.Extend(CheckWallPos, target.origin, delta)
                        renderer:draw_circle(cast_pos.x, cast_pos.y, cast_pos.z, 50, 255, 0, 0, 255)
                        spellbook:cast_spell(SLOT_W, spellW.cast_time, cast_pos.x, cast_pos.y, cast_pos.z)
                        spellbook:cast_spell(SLOT_R, spellR.cast_time, target.origin.x, target.origin.y, target.origin.z)
                        return
                    end
                end
            end
        end
    end
end

--[[
local function Combo()
    local QCast = false
    target = selector:find_target(1100, mode_health)
    local prowlers, prowlers_slot = ProwlerCheck()
    local shielded_health = ml.GetShieldedHealth("AD", target)
    local combo_dmg = ComboDmg(target)
    if prowlers then
        if spellbook:can_cast(prowlers_slot) then
            combo_dmg = (1.15 * combo_dmg)
        end
    end
    if combo_dmg > (target.health + shielded_health) then
        if local_player:distance_to(target.origin) < 1100 and ml.IsValid(target) and ml.Ready(SLOT_R) then
            CastUlt(target)
        end
    end
    if prowlers then
        if spellbook:can_cast(prowlers_slot) and local_player:distance_to(target.origin) < prowler_range then
            ProwlerCast(target)
        end
    end
    --Check if a minion can be e'd or prowlers'd through to get into Q range
    if local_player:distance_to(target.origin) < spellE.range and ml.Ready(SLOT_E) and not ml.Ready(SLOT_Q) then
        CastE(target)
    elseif local_player:distance_to(target.origin) < spellE.range and ml.Ready(SLOT_E) and ml.Ready(SLOT_Q) then
        if CastE(target) then
            QCast = true
        end
        if QCast then
            CastQ(target)
        end
    end
    if ml.Ready(SLOT_Q) then
        if local_player:distance_to(target.origin) < spellQ.range then
            CastQ(target)
        end
    end
    if not ml.Ready(SLOT_Q) and ml.Ready(SLOT_W) then
        local castPos = FindBestQiyanaWPos()
        if castPos then
            if target:distance_to(castPos) < local_player:distance_to(castPos) then
                CastW(castPos)
            end
        end
    end
    if PassiveBuff() and ml.Ready(SLOT_Q) then
        if local_player:distance_to(target.origin) < spellQ.range2 then
            CastQ(target)
        end
    end
end
--]]

local QFire = false
local WFire = false
local q_cast = nil
local e_cast = nil
local w_cast = nil

local function Combo()
    --early level combo, dont waste ult if possible, check for turrets
    local q_cd = spellbook:get_spell_slot(SLOT_Q).cooldown
    target = selector:find_target(1100, mode_health)
    local prowlers, prowlers_slot = ProwlerCheck()
    local shielded_health = ml.GetShieldedHealth("AD", target)
    local combo_dmg = ComboDmg(target)
    if prowlers then
        if spellbook:can_cast(prowlers_slot) then
            combo_dmg = (1.15 * combo_dmg)
        end
    end
    if combo_dmg > (target.health + shielded_health) then
        if local_player:distance_to(target.origin) < 1100 and ml.IsValid(target) and ml.Ready(SLOT_R) then
            CastUlt(target)
        end
    end
    if prowlers then
        if spellbook:can_cast(prowlers_slot) and local_player:distance_to(target.origin) < prowler_range then
            ProwlerCast(target)
        end
    end
    if ml.Ready(SLOT_Q) and not ml.Ready(SLOT_W) and not ml.Ready(SLOT_E) then
        CastQ(target)
    end
    if ml.Ready(SLOT_E) and ml.Ready(SLOT_Q) then
        if local_player:distance_to(target.origin) < spellE.range then
            CastE(target)
            QFire = true
            e_cast = client:get_tick_count() + 1
        end
    end
    if QFire and e_cast and spellbook:get_spell_slot(SLOT_Q).can_cast then
        if client:get_tick_count() >= e_cast then
            spellbook:cast_spell(SLOT_Q, spellQ.cast_time, target.origin.x, target.origin.y, target.origin.z)
            q_cast = os.time()
        end
    end
    if local_player:distance_to(target.origin) < spellE.range and not ml.Ready(SLOT_Q) then
        if q_cast then
            if (os.time() < (q_cast + q_cd) - 1) then
                CastE(target)
            else
                console:log("waiting for Q to E")
            end
        else
            CastE(target)
        end
    end
    if ml.Ready(SLOT_Q) and ml.Ready(SLOT_W) then
        CastQ(target)
        WFire = true
        q_cast = os.time()
    end
    if WFire and not ml.Ready(SLOT_Q) then
        if q_cast then
            if (os.time() < (q_cast + q_cd) - 1) then
                local castPos = FindBestQiyanaWPos()
                if castPos then
                    if target:distance_to(castPos) < local_player:distance_to(castPos) then
                        CastW(castPos)
                        QFire = true
                        w_cast = client:get_tick_count() + 1
                    end
                end
            end
        else
            local castPos = FindBestQiyanaWPos()
            if castPos then
                if target:distance_to(castPos) < local_player:distance_to(castPos) then
                    CastW(castPos)
                    QFire = true
                    w_cast = client:get_tick_count() + 1
                end
            end
        end
    end
    if not ml.Ready(SLOT_Q) and ml.Ready(SLOT_W) then
        if q_cast then
            if (os.time() < (q_cast + q_cd) - 1) then
                local castPos = FindBestQiyanaWPos()
                if castPos then
                    if target:distance_to(castPos) < local_player:distance_to(castPos) then
                        CastW(castPos)
                        QFire = true
                        w_cast = client:get_tick_count() + 1
                    end
                end
            else
                console:log("waiting for Q to W")
            end
        else
            local castPos = FindBestQiyanaWPos()
            if castPos then
                if target:distance_to(castPos) < local_player:distance_to(castPos) then
                    CastW(castPos)
                    QFire = true
                    w_cast = client:get_tick_count() + 1
                end
            end
        end
    end
    if QFire and w_cast and spellbook:get_spell_slot(SLOT_Q).can_cast then
        if client:get_tick_count() >= w_cast then
            spellbook:cast_spell(SLOT_Q, spellQ.cast_time, target.origin.x, target.origin.y, target.origin.z)
        end
    end
    if PassiveBuff() and ml.Ready(SLOT_Q) then
        if local_player:distance_to(target.origin) < spellQ.range2 then
            CastQ(target)
        end
    end
end

local function Harass()

end

local function on_tick()
    if game:is_key_down(menu:get_value(combokey)) then
        Combo()
    end
    if not spellbook:get_spell_slot(SLOT_Q).can_cast then
        QFire = false
        WFire = false
        e_cast = nil
        q_cast = nil
        w_cast = nil
    end
end

local function on_draw()
    --[[
    local target = selector:find_target(1100, mode_distance)
    local delta = 400 + 200 - local_player:distance_to(target.origin)
    if delta > 0 then
        local extended_pos = ml.Extend(local_player.origin, target.origin, delta)
        local local_w2s = game:world_to_screen(local_player.origin.x, local_player.origin.y, local_player.origin.z)
        local extended_w2s = game:world_to_screen(extended_pos.x, extended_pos.y, extended_pos.z)
        if local_w2s.is_valid then
            renderer:draw_line(local_w2s.x, local_w2s.y, extended_w2s.x, extended_w2s.y, 3, 255, 0, 0, 255)
        end
        renderer:draw_circle(extended_pos.x, extended_pos.y, extended_pos.z, 100, 255, 0, 0, 255)
    end
    --]]
end

local function on_object_created(object, obj_name)
    --if string.find(obj_name, "Qiyana_Base_E_Dash") and ml.Ready(SLOT_Q) then
        --spellbook:key_down(SLOT_Q)
        --spellbook:key_up(SLOT_Q)
        --spellbook:start_charged_spell(SLOT_Q)
        --spellbook:release_charged_spell(SLOT_Q, spellQ.cast_time, target.origin.x, target.origin.y, target.origin.z)
        --CastQ(target)
    --end
end

client:set_event_callback("on_object_created", on_object_created)
client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)