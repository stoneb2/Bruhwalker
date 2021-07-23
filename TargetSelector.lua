--[[

Modes:
- One shot
- Range
- Health
- Damage
- DPS
- Mouse Pos

Settings:
- Range extension / shorten
- Overkill
- 

Functions:
- Priority targetting
- Target swap if priority is out of range
- Collision checks

--]]

local ml = require "VectorMath"

local_player = game.local_player

local arkpred = _G.Prediction

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

local function SelectTarget()
    local priority_list = {}
    local one_shot_champs = {}
    local one_shot_health = {}
    local not_one_shot_champs = {}
    local not_one_shot_health = {}
    local enemies, count  = ml.GetEnemyCount(local_player.origin, 2000)
    if count > 0 then
        for i, enemy in pairs(enemies) do
            if ml.IsValid(enemy) and enemy.is_alive then
                local combo_dmg = ComboDmg(enemy)
                local shielded_health = ml.GetShieldedHealth("AD", enemy)
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

--------------------------------------------------------------------------------------------

local Class = function(...)
	local cls = {}; cls.__index = cls
	cls.__call = function(_, ...) return cls:New(...) end
	function cls:New(...)
		local instance = setmetatable({}, cls)
		cls.__init(instance, ...)
		return instance
	end
	return setmetatable(cls, {__call = cls.__call})
end

--------------------------------------------------------------------------------------------

local TSInput = Class()

function TSInput:__init(data)
    self.damage = data.damage or nil
    self.overkill = data.overkill or nil
    self.mode = data.mode or "ComboDmg" --ComboDmg, range, mousepos, dps, health
    self.prio = data.prio or "dynamic" --Dynamic / Static
    self.q = data.q or {}
    self.w = data.w or {}
    self.e = data.e or {}
    self.r = data.r or {}
end

--------------------------------------------------------------------------------------------

local TSOutput = Class()

function TSOutput:__init()
    self.priority_list = {}
    self.target = nil
    self.q_targets = {}
    self.q_target = nil
    self.w_targets = {}
    self.w_target = nil
    self.e_targets = {}
    self.e_target = nil
    self.r_targets = {}
    self.r_target = nil
end

--------------------------------------------------------------------------------------------

local TS = Class()

function TS:__init(data)
    self.range = data.range
    self.priority_list = {}
    self.priority1 = nil
    self.priority2 = nil
    self.priority3 = nil
    self.priority4 = nil
    self.priority5 = nil
    self.menu = menu:add_category("Target Selector")
    self.mode = menu:add_checkbox("Mode", self.menu, {"Damage", "Range", "Health", "Mouse Position", "Enemy Damage"}, 0)
    self.range_delta = menu:add_slider("Range Delta", self.menu, 0, 500, 0)
    client:set_event_callback("on_tick", function(...) self:OnTick(...) end)
    client:set_event_callback("on_draw", function(...) self:OnDraw(...) end)
    self.loaded = true
end

function TS:DamagePrio()
    local priority_list = {}
    local one_shot_champs = {}
    local one_shot_health = {}
    local not_one_shot_champs = {}
    local not_one_shot_health = {}
    local enemies, count  = ml.GetEnemyCount(local_player.origin, self.range)
    if count > 0 then
        for i, enemy in pairs(enemies) do
            if ml.IsValid(enemy) and enemy.is_alive then
                local combo_dmg = TSInput.damage
                local shielded_health = ml.GetShieldedHealth("ALL", enemy)
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

    local q_targets = {}
    local q_data = TSInput.q
    if not next(q_data) == nil then
        for _, enemy in ipairs(priority_list) do
            local endPos = vec3.new(enemy.origin)
            q_collisions = arkpred:get_collision(TSInput.q, endPos, enemy)
            if next(q_collisions) == nil then
                table.insert(q_targets, enemy)
            end
        end
    end

    local w_targets = {}
    local w_data = TSInput.w
    if not next(w_data) == nil then
        for _, enemy in ipairs(priority_list) do
            local endPos = vec3.new(enemy.origin)
            w_collisions = arkpred:get_collision(TSInput.w, endPos, enemy)
            if next(w_collisions) == nil then
                table.insert(w_targets, enemy)
            end
        end
    end

    local e_targets = {}
    local e_data = TSInput.e
    if not next(e_data) == nil then
        for _, enemy in ipairs(priority_list) do
            local endPos = vec3.new(enemy.origin)
            e_collisions = arkpred:get_collision(TSInput.e, endPos, enemy)
            if next(e_collisions) == nil then
                table.insert(e_targets, enemy)
            end
        end
    end

    local r_targets = {}
    local r_data = TSInput.r
    if not next(r_data) == nil then
        for _, enemy in ipairs(priority_list) do
            local endPos = vec3.new(enemy.origin)
            r_collisions = arkpred:get_collision(TSInput.r, endPos, enemy)
            if next(r_collisions) == nil then
                table.insert(r_targets, enemy)
            end
        end
    end
    return priority_list, q_targets, w_targets, e_targets, r_targets
end

function TS:RangePrio()

end

function TS:HealthPrio()

end

function TS:MousePosPrio()

end

function TS:EnemyDamagePrio()

end

function TS:SelectTarget()
    local prio_list = {}
    local q_targets = {}
    local q_target = nil
    local w_targets = {}
    local w_target = nil
    local e_targets = {}
    local e_target = nil
    local r_targets = {}
    local r_target = nil
    local output = TSOutput:New()

    if menu:get_value(self.mode) == 0 then
        prio_list, q_targets, w_targets, e_targets, r_targets = self:DamagePrio()
    end

    if menu:get_value(self.mode) == 1 then
        prio_list, q_targets, w_targets, e_targets, r_targets = self:RangePrio()
    end

    if menu:get_value(self.mode) == 2 then
        prio_list, q_targets, w_targets, e_targets, r_targets = self:HealthPrio()
    end

    if menu:get_value(self.mode) == 3 then
        prio_list, q_targets, w_targets, e_targets, r_targets = self:MousePosPrio()
    end

    if menu:get_value(self.mode) == 4 then
        prio_list, q_targets, w_targets, e_targets, r_targets = self:EnemyDamagePrio()
    end

    output.priority_list = prio_list
    output.target = GetFirst(prio_list)
    output.q_targets = q_targets
    output.q_target = GetFirst(q_targets)
    output.w_targets = w_targets
    output.w_target = GetFirst(w_targets)
    output.e_targets = e_targets
    output.e_target = GetFirst(e_targets)
    output.r_targets = r_targets
    output.r_target = GetFirst(r_targets)

    return output
end

function TS:OnTick()

end

function TS:OnDraw()

end

--------------------------------------------------------------------------------------------

local target_selector = TS:New(2000)

_G.TS = {
    get_target = function(self)
        return target_selector:SelectTarget().target
    end,

    get_prio_list = function(self)
        return target_selector:SelectTarget().priority_list
    end,

    get_q_targets = function(self)
        target_selector:SelectTarget().q_targets
    end,

    get_w_targets = function(self)
        target_selector:SelectTarget().w_targets
    end,

    get_e_targets = function(self)
        target_selector:SelectTarget().e_targets
    end,

    get_r_targets = function(self)
        target_selector:SelectTarget().r_targets
    end
}