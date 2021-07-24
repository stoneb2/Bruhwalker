if game.local_player.champ_name ~= Ezreal then
    return
end

ml = require "VectorMath"

local myHero = game.local_player
local arkpred = _G.Prediction

local q_input = {
    source = myHero,
    speed = 2000,
    range = 1150,
    delay = 0.25,
    radius = 60,
    collision = {"minion", "wind_wall"},
    type = "linear",
    hitbox = true
}

local data = {
    range = q_input.range,
    q = q_input
}

local TS = _G.TS(data) -- might be just _G.TS who tf knows

local function GetFirst(tab)
    if not next(tab) == nil then
        if tab[0] ~= nil then
            return tab[0]
        else
            return tab[1]
        end
    else
        return nil
    end
end

local function on_tick()
    if ml.Ready(SLOT_Q) then
        priority_list = TS:get_prio_list() -- total priority list (not taking collisions into account)
        q_target_list = TS:get_q_targets() -- priority list that can be hit by Q (no collisions)
        if GetFirst(priority_list) == GetFirst(q_target_list) then
            target = GetFirst(priority_list) -- uses top priority target since he can be hit by Q
            if target then
                if target.is_valid and target.is_enemy then
                    local output = arkpred:get_prediction(q_input, target)
                    local inv = arkpred:get_invisible_duration(target)
                    if output.hit_chance > 0.5 and inv < (q_input.delay / 2) then
                        local p = output.cast_pos
                        spellbook:cast_spell(SLOT_Q, q_input.delay, p.x, p.y, p.z)
                    end
                end
            end
        else
            target = GetFirst(q_target_list) -- top priority can't be hit by Q, chooses highest priority target that can be hit by Q
            if target then
                if target.is_valid and target.is_enemy then
                    local output = arkpred:get_prediction(q_input, target)
                    local inv = arkpred:get_invisible_duration(target)
                    if output.hit_chance > 0.5 and inv < (q_input.delay / 2) then
                        local p = output.cast_pos
                        spellbook:cast_spell(SLOT_Q, q_input.delay, p.x, p.y, p.z)
                    end
                end
            end
        end
    end
end

client:set_event_callback("on_tick", on_tick)
