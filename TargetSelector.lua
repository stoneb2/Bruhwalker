--[[

--------------------------------------------------------------------------------------------

PLANNING

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

Functions:
- Priority targetting
- Target swap if priority is out of range
- Collision checks

--------------------------------------------------------------------------------------------

API

get_target() [unit]
- Returns the highest priority target, regardless of collision

get_prio_list() [table of units]
- Returns the list of targets, ordered by priority (1st in table is highest)

get_q_targets() [table of units]
- Returns the list of targets that can be hit by Q (if spell data is provided), ordered by 
  priority (1st in table is highest)

get_q_target() [unit]
- Returns the highest priority target that can be hit by Q (if spell data is provided), ordered
  by priority (1st in table is highest)

get_w_targets() [table of units]
- Returns the list of targets that can be hit by W (if spell data is provided), ordered by 
  priority (1st in table is highest)

get_w_target() [unit]
- Returns the highest priority target that can be hit by W (if spell data is provided), ordered
  by priority (1st in table is highest)

get_e_targets() [table of units]
- Returns the list of targets that can be hit by E (if spell data is provided), ordered by 
  priority (1st in table is highest)

get_e_target() [unit]
- Returns the highest priority target that can be hit by E (if spell data is provided), ordered
  by priority (1st in table is highest)

get_r_targets() [table of units]
- Returns the list of targets that can be hit by R (if spell data is provided), ordered by 
  priority (1st in table is highest)

get_r_target() [unit]
- Returns the highest priority target that can be hit by R (if spell data is provided), ordered
  by priority (1st in table is highest)

--------------------------------------------------------------------------------------------

EXAMPLE

Returning a priority list of targets for Ezreal Q, moving to the first target able to be hit
if Q on main priority has collisions:

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

local TS = _G.TS(range = q_input.range, q = q_input) -- might be just _G.TS who tf knows

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

--]]

--------------------------------------------------------------------------------------------

local ml = require "VectorMath"

local_player = game.local_player

local arkpred = _G.Prediction

--------------------------------------------------------------------------------------------

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
    self.range = data.range or 2000
    self.priority_list = {}
    self.priority1 = nil
    self.priority2 = nil
    self.priority3 = nil
    self.priority4 = nil
    self.priority5 = nil
    self.menu = menu:add_category("Target Selector")
    self.mode = menu:add_checkbox("Mode", self.menu, {"Damage", "Range", "Health", "Mouse Position", "Enemy Damage"}, 0)
    self.range_delta = menu:add_slider("Range Delta", self.menu, 0, 500, 0)
    self.overkill = menu:add_slider("Overkill Percent", self.menu, 0, 100, 0)
    self.draw_prio = menu:add_checkbox("Draw Priority", self.menu, 1)
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
    local priority_list = {}
    local champ_list = {}
    local distance_list = {}
    local enemies, count = ml.GetEnemyCount(local_player.origin, self.range)
    if count > 0 then
        for i, enemy in pairs(enemies) do
            if ml.IsValid(enemy) and enemy.is_alive then
                table.insert(champ_list, enemy)
                table.insert(distance_list, enemy:distance_to(local_player.origin))
            end
        end
        if #champ_list > 0 then
            local champ_list_sorted = sort_relative(distance_list, champ_list)
            for i, champ in pairs(champ_list_sorted) do
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

function TS:HealthPrio()
    local priority_list = {}
    local champ_list = {}
    local difficulty_list = {}
    local enemies, count  = ml.GetEnemyCount(local_player.origin, self.range)
    if count > 0 then
        for i, enemy in pairs(enemies) do
            if ml.IsValid(enemy) and enemy.is_alive then
                table.insert(champ_list, enemy)
                local difficulty_factor = enemy.mr * enemy.armor * enemy.health
                table.insert(difficulty_list, difficulty_factor)
            end
        end
        if #champ_list > 0 then
            local champ_list_sorted = sort_relative(difficulty_list, champ_list)
            for i, champ in pairs(champ_list_sorted) do
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

function TS:MousePosPrio()
    local priority_list = {}
    local champ_list = {}
    local distance_list = {}
    local enemies, count = ml.GetEnemyCount(local_player.origin, self.range)
    if count > 0 then
        for i, enemy in pairs(enemies) do
            if ml.IsValid(enemy) and enemy.is_alive then
                table.insert(champ_list, enemy)
                table.insert(distance_list, enemy:distance_to(ml.GetMousePos()))
            end
        end
        if #champ_list > 0 then
            local champ_list_sorted = sort_relative(distance_list, champ_list)
            for i, champ in pairs(champ_list_sorted) do
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
        if #prio_list > 0 then
            local prio1 = GetFirst(prio_list)
            local start_index = nil
            for i, champ in pairs(prio_list) do
                if champ == prio1 then
                    start_index = i
                end
            end
            self.priority1 = prio_list[start_index]
            if #prio_list > 1 then
                self.priority2 = prio_list[start_index + 1]
                if #prio_list > 2 then
                    self.priority3 = prio_list[start_index + 2]
                    if #prio_list > 3 then
                        self.priority4 = prio_list[start_index + 3]
                        if #prio_list > 4 then
                            self.priority5 = prio_list[start_index + 4]
                        end
                    end
                end
            end
        end
    end

    if menu:get_value(self.mode) == 1 then
        prio_list, q_targets, w_targets, e_targets, r_targets = self:RangePrio()
        if #prio_list > 0 then
            local prio1 = GetFirst(prio_list)
            local start_index = nil
            for i, champ in pairs(prio_list) do
                if champ == prio1 then
                    start_index = i
                end
            end
            self.priority1 = prio_list[start_index]
            if #prio_list > 1 then
                self.priority2 = prio_list[start_index + 1]
                if #prio_list > 2 then
                    self.priority3 = prio_list[start_index + 2]
                    if #prio_list > 3 then
                        self.priority4 = prio_list[start_index + 3]
                        if #prio_list > 4 then
                            self.priority5 = prio_list[start_index + 4]
                        end
                    end
                end
            end
        end
    end

    if menu:get_value(self.mode) == 2 then
        prio_list, q_targets, w_targets, e_targets, r_targets = self:HealthPrio()
        if #prio_list > 0 then
            local prio1 = GetFirst(prio_list)
            local start_index = nil
            for i, champ in pairs(prio_list) do
                if champ == prio1 then
                    start_index = i
                end
            end
            self.priority1 = prio_list[start_index]
            if #prio_list > 1 then
                self.priority2 = prio_list[start_index + 1]
                if #prio_list > 2 then
                    self.priority3 = prio_list[start_index + 2]
                    if #prio_list > 3 then
                        self.priority4 = prio_list[start_index + 3]
                        if #prio_list > 4 then
                            self.priority5 = prio_list[start_index + 4]
                        end
                    end
                end
            end
        end
    end

    if menu:get_value(self.mode) == 3 then
        prio_list, q_targets, w_targets, e_targets, r_targets = self:MousePosPrio()
        if #prio_list > 0 then
            local prio1 = GetFirst(prio_list)
            local start_index = nil
            for i, champ in pairs(prio_list) do
                if champ == prio1 then
                    start_index = i
                end
            end
            self.priority1 = prio_list[start_index]
            if #prio_list > 1 then
                self.priority2 = prio_list[start_index + 1]
                if #prio_list > 2 then
                    self.priority3 = prio_list[start_index + 2]
                    if #prio_list > 3 then
                        self.priority4 = prio_list[start_index + 3]
                        if #prio_list > 4 then
                            self.priority5 = prio_list[start_index + 4]
                        end
                    end
                end
            end
        end
    end

    if menu:get_value(self.mode) == 4 then
        prio_list, q_targets, w_targets, e_targets, r_targets = self:EnemyDamagePrio()
        if #prio_list > 0 then
            local prio1 = GetFirst(prio_list)
            local start_index = nil
            for i, champ in pairs(prio_list) do
                if champ == prio1 then
                    start_index = i
                end
            end
            self.priority1 = prio_list[start_index]
            if #prio_list > 1 then
                self.priority2 = prio_list[start_index + 1]
                if #prio_list > 2 then
                    self.priority3 = prio_list[start_index + 2]
                    if #prio_list > 3 then
                        self.priority4 = prio_list[start_index + 3]
                        if #prio_list > 4 then
                            self.priority5 = prio_list[start_index + 4]
                        end
                    end
                end
            end
        end
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
    if menu:get_value(self.draw_prio) == 1 then
        if self.priority1 then
            if ml.IsValid(self.priority1) and self.priority1.is_alive and self.priority1.is_visible then
                local prio_vec = vec3.new(self.priority1.origin.x, self.priority1.origin.y, self.priority1.origin.z)
                local w2s = game:world_to_screen(prio_vec.x, prio_vec.y, prio_vec.z)
                if w2s.is_valid then
                    renderer:draw_text_big_centered(w2s.x, w2s.y, "1", 255, 0, 0, 255)
                end
            end
        end
        if self.priority2 then
            if ml.IsValid(self.priority2) and self.priority2.is_alive and self.priority2.is_visible then
                local prio_vec = vec3.new(self.priority2.origin.x, self.priority2.origin.y, self.priority2.origin.z)
                local w2s = game:world_to_screen(prio_vec.x, prio_vec.y, prio_vec.z)
                if w2s.is_valid then
                    renderer:draw_text_big_centered(w2s.x, w2s.y, "2", 255, 0, 0, 255)
                end
            end
        end
        if self.priority3 then
            if ml.IsValid(self.priority3) and self.priority3.is_alive and self.priority3.is_visible then
                local prio_vec = vec3.new(self.priority3.origin.x, self.priority3.origin.y, self.priority3.origin.z)
                local w2s = game:world_to_screen(prio_vec.x, prio_vec.y, prio_vec.z)
                if w2s.is_valid then
                    renderer:draw_text_big_centered(w2s.x, w2s.y, "3", 255, 0, 0, 255)
                end
            end
        end
        if self.priority4 then
            if ml.IsValid(self.priority4) and self.priority4.is_alive and self.priority4.is_visible then
                local prio_vec = vec3.new(self.priority4.origin.x, self.priority4.origin.y, self.priority4.origin.z)
                local w2s = game:world_to_screen(prio_vec.x, prio_vec.y, prio_vec.z)
                if w2s.is_valid then
                    renderer:draw_text_big_centered(w2s.x, w2s.y, "4", 255, 0, 0, 255)
                end
            end
        end
        if self.priority5 then
            if ml.IsValid(self.priority5) and self.priority5.is_alive and self.priority5.is_visible then
                local prio_vec = vec3.new(self.priority5.origin.x, self.priority5.origin.y, self.priority5.origin.z)
                local w2s = game:world_to_screen(prio_vec.x, prio_vec.y, prio_vec.z)
                if w2s.is_valid then
                    renderer:draw_text_big_centered(w2s.x, w2s.y, "5", 255, 0, 0, 255)
                end
            end
        end
    end
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

    get_q_target = function(self)
        target_selector:SelectTarget().q_target
    end,

    get_w_targets = function(self)
        target_selector:SelectTarget().w_targets
    end,

    get_w_target = function(self)
        target_selector:SelectTarget().w_target
    end,

    get_e_targets = function(self)
        target_selector:SelectTarget().e_targets
    end,

    get_e_target = function(self)
        target_selector:SelectTarget().e_target
    end,

    get_r_targets = function(self)
        target_selector:SelectTarget().r_targets
    end,

    get_r_target = function(self)
        target_selector:SelectTarget().r_target
    end
}
