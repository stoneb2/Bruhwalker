if game.local_player.champ_name ~= "Veigar" then
    return
end

local file_name = "VectorMath.lua"
if not file_manager:file_exists(file_name) then
   local url = "https://raw.githubusercontent.com/stoneb2/Bruhwalker/main/VectorMath/VectorMath.lua"
   http:download_file(url, file_name)
   console:log("VectorMath Library Downloaded")
   console:log("Please Reload with F5")
end

local file_name = "Prediction.lib"
if not file_manager:file_exists(file_name) then
   local url = "https://raw.githubusercontent.com/Ark223/Bruhwalker/main/Prediction.lib"
   http:download_file(url, file_name)
   console:log("Ark Prediction Downloaded")
   console:log("Please Reload with F5")
end

local ml = require "VectorMath"

local_player = game.local_player

local arkpred = _G.Prediction

local function close(a, b, eps)
    eps = eps or 1e-9
    return math.abs(a - b) <= eps
end

local lengthOf, pow, sqrt, cos, sin, acos, deg, atan, abs, min, max, huge = math.lengthOf, math.pow, math.sqrt, math.cos, math.sin, math.acos, math.deg, math.atan, math.abs, math.min, math.max, math.huge
local insert = table.insert 

local function class()
local cls = {}
cls.__index = cls
return setmetatable(cls, {__call = function (c, ...)
    local instance = setmetatable({}, cls)
    if cls.__init then
        cls.__init(instance, ...)
    end
    return instance
end})
end

local function getY(p)
return (p.y == 0 or p.z ~= 0) and p.z or p.y
end

function VectorType(v)
v = v.position or v
return v and v.x and type(v.x) == "number" and ((v.y and type(v.y) == "number") or (v.z and type(v.z) == "number"))
end

function VectorDirection(v1, v2, v)    
return ((v.z or v.y) - (v1.z or v1.y)) * (v2.x - v1.x) - ((v2.z or v2.y) - (v1.z or v1.y)) * (v.x - v1.x)
end

--[[http://thirdpartyninjas.com/blog/2008/10/07/line-segment-intersection/]]
function VectorIntersection(a1, b1, a2, b2) --returns a 2D point where two lines intersect (assuming they have an infinite length)
assert(VectorType(a1) and VectorType(b1) and VectorType(a2) and VectorType(b2), "VectorIntersection: wrong argument types (4 <Vector> expected)")    
local x1, y1, x2, y2, x3, y3, x4, y4 = a1.x, a1.z or a1.y, b1.x, b1.z or b1.y, a2.x, a2.z or a2.y, b2.x, b2.z or b2.y
local r, s, u, v, k, l = x1 * y2 - y1 * x2, x3 * y4 - y3 * x4, x3 - x4, x1 - x2, y3 - y4, y1 - y2
local px, py, divisor = r * u - v * s, r * k - l * s, v * k - l * u

return divisor ~= 0 and Vector(px / divisor, py / divisor)
end

function VectorPointProjectionOnLine(v1, v2, v)
assert(VectorType(v1) and VectorType(v2) and VectorType(v), "VectorPointProjectionOnLine: wrong argument types (3 <Vector> expected)")
local line = Vector(v2) - v1
local t = ((-(v1.x * line.x - line.x * v.x + (v1.z - v.z) * line.z)) / line:len2())
return (line * t) + v1
end

--[[
VectorPointProjectionOnLineSegment: Extended VectorPointProjectionOnLine in 2D Space
v1 and v2 are the start and end point of the linesegment
v is the point next to the line
return:
    pointSegment = the point closest to the line segment (table with x and y member)
    pointLine = the point closest to the line (assuming infinite extent in both directions) (table with x and y member), same as VectorPointProjectionOnLine
    isOnSegment = if the point closest to the line is on the segment
]]
function VectorPointProjectionOnLineSegment(v1, v2, v)
assert(v1 and v2 and v, "VectorPointProjectionOnLineSegment: wrong argument types (3 <Vector> expected)")
local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) ^ 2 + (by - ay) ^ 2)
local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
local isOnSegment = rS == rL
local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
return pointSegment, pointLine, isOnSegment
end

--[[
Example: 
    VectorMovementCollision(spellPos, spellEndPos, spellProjectileSpeed, heroPos, heroMoveSpeed)
--]]

function VectorMovementCollision(startPoint1, endPoint1, v1, startPoint2, v2, delay)
local sP1x, sP1y, eP1x, eP1y, sP2x, sP2y = startPoint1.x, startPoint1.z or startPoint1.y, endPoint1.x, endPoint1.z or endPoint1.y, startPoint2.x, startPoint2.z or startPoint2.y
--v2 * t = Distance(P, A + t * v1 * (B-A):Norm())
--(v2 * t)^2 = (r+S*t)^2+(j+K*t)^2 and v2 * t >= 0
--0 = (S*S+K*K-v2*v2)*t^2+(-r*S-j*K)*2*t+(r*r+j*j) and v2 * t >= 0
local d, e = eP1x-sP1x, eP1y-sP1y
local dist, t1, t2 = sqrt(d*d+e*e), nil, nil
local S, K = dist~=0 and v1*d/dist or 0, dist~=0 and v1*e/dist or 0
local function GetCollisionPoint(t) return t and {x = sP1x+S*t, y = sP1y+K*t} or nil end
if delay and delay~=0 then sP1x, sP1y = sP1x+S*delay, sP1y+K*delay end
local r, j = sP2x-sP1x, sP2y-sP1y
local c = r*r+j*j
if dist>0 then
    if v1 == huge then
        local t = dist/v1
        t1 = v2*t>=0 and t or nil
    elseif v2 == huge then
        t1 = 0
    else
        local a, b = S*S+K*K-v2*v2, -r*S-j*K
        if a==0 then 
            if b==0 then --c=0->t variable
                t1 = c==0 and 0 or nil
            else --2*b*t+c=0
                local t = -c/(2*b)
                t1 = v2*t>=0 and t or nil
            end
        else --a*t*t+2*b*t+c=0
            local sqr = b*b-a*c
            if sqr>=0 then
                local nom = sqrt(sqr)
                local t = (-nom-b)/a
                t1 = v2*t>=0 and t or nil
                t = (nom-b)/a
                t2 = v2*t>=0 and t or nil
            end
        end
    end
elseif dist==0 then
    t1 = 0
end

return t1, GetCollisionPoint(t1), t2, GetCollisionPoint(t2), dist
end

--======== Start of the Classes ========--

Vector = class()

    function Vector:__init(a, b, c)
        self.type = "Vector"

        if a == nil then
            self.x, self.y, self.z = 0.0, 0.0, 0.0
        elseif b == nil then
            a = a.position or a
            assert(VectorType(a), "Vector: wrong argument types (expected nil or <Vector> or 2 <number> or 3 <number>)")
            self.x, self.y, self.z = a.x, a.y, a.z
        else
            assert(type(a) == "number" and (type(b) == "number" or type(c) == "number"), "Vector: wrong argument types (<Vector> or 2 <number> or 3 <number>)")
            self.x = a
            if b and type(b) == "number" then self.y = b end
            if c and type(c) == "number" then self.z = c end
        end
    end

    function Vector:__add(v)
        assert(VectorType(v) and VectorType(self), "add: wrong argument types (<Vector> expected)")
        return Vector(self.x + v.x, (v.y and self.y) and self.y + v.y, (v.z and self.z) and self.z + v.z)
    end

    function Vector:__sub(v)
        assert(VectorType(v) and VectorType(self), "Sub: wrong argument types (<Vector> expected)")
        return Vector(self.x - v.x, (v.y and self.y) and self.y - v.y, (v.z and self.z) and self.z - v.z)
    end

    function Vector.__mul(a, b)
        if type(a) == "number" and VectorType(b) then
            return Vector({ x = b.x * a, y = b.y and b.y * a, z = b.z and b.z * a })
        elseif type(b) == "number" and VectorType(a) then
            return Vector({ x = a.x * b, y = a.y and a.y * b, z = a.z and a.z * b })
        else
            assert(VectorType(a) and VectorType(b), "Mul: wrong argument types (<Vector> or <number> expected)")
            return a:dotP(b)
        end
    end

    function Vector.__div(a, b)
        if type(a) == "number" and VectorType(b) then
            return Vector({ x = a / b.x, y = b.y and a / b.y, z = b.z and a / b.z })
        elseif a.type == "Vector" and b.type == "Vector" then
            return Vector(a.x / b.x, a.y / b.y, a.z / b.z)
        else
            assert(VectorType(a) and type(b) == "number", "Div: wrong argument types (<number> expected)")
            return Vector({ x = a.x / b, y = a.y and a.y / b, z = a.z and a.z / b })
        end
    end

    function Vector.__lt(a, b)
        assert(VectorType(a) and VectorType(b), "__lt: wrong argument types (<Vector> expected)")
        return a:len() < b:len()
    end

    function Vector.__le(a, b)
        assert(VectorType(a) and VectorType(b), "__le: wrong argument types (<Vector> expected)")
        return a:len() <= b:len()
    end

    function Vector:__eq(v)
        assert(VectorType(v), "__eq: wrong argument types (<Vector> expected)")
        return self.x == v.x and self.y == v.y and self.z == v.z
    end

    function Vector:__unm()
        return Vector(-self.x, self.y and -self.y, self.z and -self.z)
    end

    function Vector:__vector(v)
        assert(VectorType(v), "__vector: wrong argument types (<Vector> expected)")
        return self:crossP(v)
    end

    function Vector:__tostring()
        if self.z then
            return "(" .. self.x .. "," .. self.y .. "," .. self.z .. ")"
        else
            return "(" .. self.x .. "," .. self.y .. ")"
        end
    end

    function Vector:clone()
        return Vector(self)
    end

    function Vector:unpack()
        return self.x, self.y, self.z
    end

    function Vector:len2(v)
        assert(v == nil or VectorType(v), "dist: wrong argument types (<Vector> expected)")
        local v = v and Vector(v) or self
        return self.x * v.x + (self.y and self.y * v.y or 0) + (self.z and self.z * v.z or 0)
    end

    function Vector:len()
        return sqrt(self:len2())
    end

    function Vector:dist(v)
        assert(VectorType(v), "dist: wrong argument types (<Vector> expected)")
        local a = self - v
        return a:len()
    end

    function Vector:normalize()
        local a = self:len()
        self.x = self.x / a
        if self.y then self.y = self.y / a end
        if self.z then self.z = self.z / a end
    end

    function Vector:normalized()
        local a = self:clone()
        a:normalize()
        return a
    end

    function Vector:center(v)
        assert(VectorType(v), "center: wrong argument types (<Vector> expected)")
        return Vector((self + v) / 2)
    end

    function Vector:crossP(other)
        assert(self.y and self.z and other.y and other.z, "crossP: wrong argument types (3 Dimensional <Vector> expected)")
        return Vector({
            x = other.z * self.y - other.y * self.z,
            y = other.x * self.z - other.z * self.x,
            z = other.y * self.x - other.x * self.y
        })
    end

    function Vector:dotP(other)
        assert(VectorType(other), "dotP: wrong argument types (<Vector> expected)")
        return self.x * other.x + (self.y and (self.y * other.y) or 0) + (self.z and (self.z * other.z) or 0)
    end

    function Vector:projectOn(v)
        assert(VectorType(v), "projectOn: invalid argument: cannot project Vector on " .. type(v))
        if type(v) ~= "Vector" then v = Vector(v) end
        local s = self:len2(v) / v:len2()
        return Vector(v * s)
    end

    function Vector:mirrorOn(v)
        assert(VectorType(v), "mirrorOn: invalid argument: cannot mirror Vector on " .. type(v))
        return self:projectOn(v) * 2
    end

    function Vector:sin(v)
        assert(VectorType(v), "sin: wrong argument types (<Vector> expected)")
        if type(v) ~= "Vector" then v = Vector(v) end
        local a = self:__vector(v)
        return sqrt(a:len2() / (self:len2() * v:len2()))
    end

    function Vector:cos(v)
        assert(VectorType(v), "cos: wrong argument types (<Vector> expected)")
        if type(v) ~= "Vector" then v = Vector(v) end
        return self:len2(v) / sqrt(self:len2() * v:len2())
    end

    function Vector:angle(v)
        assert(VectorType(v), "angle: wrong argument types (<Vector> expected)")
        return acos(self:cos(v))
    end

    function Vector:affineArea(v)
        assert(VectorType(v), "affineArea: wrong argument types (<Vector> expected)")
        if type(v) ~= "Vector" then v = Vector(v) end
        local a = self:__vector(v)
        return sqrt(a:len2())
    end

    function Vector:triangleArea(v)
        assert(VectorType(v), "triangleArea: wrong argument types (<Vector> expected)")
        return self:affineArea(v) / 2
    end

    function Vector:rotateXaxis(phi)
        assert(type(phi) == "number", "Rotate: wrong argument types (expected <number> for phi)")
        local c, s = cos(phi), sin(phi)
        self.y, self.z = self.y * c - self.z * s, self.z * c + self.y * s
    end

    function Vector:rotateYaxis(phi)
        assert(type(phi) == "number", "Rotate: wrong argument types (expected <number> for phi)")
        local c, s = cos(phi), sin(phi)
        self.x, self.z = self.x * c + self.z * s, self.z * c - self.x * s
    end

    function Vector:rotateZaxis(phi)
        assert(type(phi) == "number", "Rotate: wrong argument types (expected <number> for phi)")
        local c, s = cos(phi), sin(phi)
        self.x, self.y = self.x * c - self.z * s, self.y * c + self.x * s
    end

    function Vector:rotate(phiX, phiY, phiZ)
        assert(type(phiX) == "number" and type(phiY) == "number" and type(phiZ) == "number", "Rotate: wrong argument types (expected <number> for phi)")
        if phiX ~= 0 then self:rotateXaxis(phiX) end
        if phiY ~= 0 then self:rotateYaxis(phiY) end
        if phiZ ~= 0 then self:rotateZaxis(phiZ) end
    end

    function Vector:rotated(phiX, phiY, phiZ)
        assert(type(phiX) == "number" and type(phiY) == "number" and type(phiZ) == "number", "Rotated: wrong argument types (expected <number> for phi)")
        local a = self:clone()
        a:rotate(phiX, phiY, phiZ)
        return a
    end

    -- not yet full 3D functions
    function Vector:polar()
        if close(self.x, 0) then
            if (self.z or self.y) > 0 then return 90
            elseif (self.z or self.y) < 0 then return 270
            else return 0
            end
        else
            local theta = deg(atan((self.z or self.y) / self.x))
            if self.x < 0 then theta = theta + 180 end
            if theta < 0 then theta = theta + 360 end
            return theta
        end
    end

    function Vector:angleBetween(v1, v2)
        assert(VectorType(v1) and VectorType(v2), "angleBetween: wrong argument types (2 <Vector> expected)")
        local p1, p2 = (-self + v1), (-self + v2)
        local theta = p1:polar() - p2:polar()
        if theta < 0 then theta = theta + 360 end
        if theta > 180 then theta = 360 - theta end
        return theta
    end

    function Vector:distSqr(pos)
        assert(VectorType(pos), "compare: wrong argument types (<Vector> expected)")
        local p2x, p2y, p2z = pos:unpack()
        local p1x, p1y, p1z = self:unpack()
        local dx = p1x - p2x
        local dz = (p1z or p1y) - (p2z or p2y)
        return dx*dx + dz*dz
    end

    function Vector:compare(v)
        assert(VectorType(v), "compare: wrong argument types (<Vector> expected)")
        local ret = self.x - v.x
        if ret == 0 then ret = self.z - v.z end
        return ret
    end

    function Vector:perpendicular()
        return Vector(-self.z, self.y, self.x)
    end

    function Vector:perpendicular2()
        return Vector(self.z, self.y, -self.x)
    end

    function Vector:abs()
        return Vector(abs(self.x), abs(self.y), abs(self.z))
    end

    function Vector:__distance(Object)
        if Object.type == "Vector" then
            return (self:__sub(Object)):len()
        elseif Object.type == "LineSegment" then
            return Object:__distance(self)
        elseif Object.type == "Circle" then
            --missing
        end
    end

    function Vector:__insideOf(Object)
        return Object:__contains(self)
    end

    function Vector:__getPoints()
        return {self}
    end

    function Vector:__draw(color)
        local C = Circle(self, 5)

        C:__draw(color)
    end

veigar = menu:add_category("Veigar")
veigar_enabled = menu:add_checkbox("Enabled", veigar, 1)
combokey = menu:add_keybinder("Combo Key", veigar, 32)

pred_settings = menu:add_subcategory("Prediction Settings", veigar)
pred_q_hit_chance = menu:add_slider("Q Hit Chance", pred_settings, 1, 100, 50)
pred_w_hit_chance = menu:add_slider("W Hit Chance", pred_settings, 1, 100, 50)
pred_e_hit_chance = menu:add_slider("E Hit Chance", pred_settings, 1, 100, 50)

combo_settings = menu:add_subcategory("Combo Settings", veigar)
combo_q = menu:add_checkbox("Use Q", combo_settings, 1)
combo_q_mana = menu:add_slider("Minimum Mana to Q", combo_settings, 0, 100, 30)
combo_q_range = menu:add_slider("Maximum Q Range", combo_settings, 100, 950, 850)
combo_w = menu:add_checkbox("Use W", combo_settings, 1)
combo_w_mana = menu:add_slider("Minimum Mana to W", combo_settings, 0, 100, 30)
combo_w_stunned = menu:add_checkbox("Only W Stunned / Slowed", combo_settings, 1)
combo_w_anyways = menu:add_checkbox("Use W Always When Target HP Low", combo_settings, 1)
combo_w_anyways_health = menu:add_slider("W Always When Target HP% Below: ", combo_settings, 1, 100, 35)
combo_w_range = menu:add_slider("Maximum W Range", combo_settings, 100, 900, 800)
combo_e = menu:add_checkbox("Use E", combo_settings, 1)
combo_e_mode = menu:add_combobox("E Mode", combo_settings, {"Stun", "Center"}, 0)
--combo_e_stun_dir = menu:add_combobox("E Stun Cage Direction", combo_settings, {"Behind", "In Front"}, 0, "Which direction to shift the cage when trying to stun the target")

harass_settings = menu:add_subcategory("Harass Settings", veigar)
harass_q = menu:add_checkbox("Use Q", harass_settings, 1)
harass_q_mana = menu:add_slider("Minimum Mana to Q", harass_settings, 0, 100, 30)
harass_q_range = menu:add_slider("Maximum Q Range", harass_settings, 100, 950, 850)
harass_w = menu:add_checkbox("Use W", harass_settings, 1)
harass_w_mana = menu:add_slider("Minimum Mana to W", harass_settings, 0, 100, 30)
harass_w_stunned = menu:add_checkbox("Only W Stunned / Slowed", harass_settings, 1)
harass_w_anyways = menu:add_checkbox("Use W Always When Target HP Low", harass_settings, 1)
harass_w_anyways_health = menu:add_slider("W Always When Target HP% Below: ", harass_settings, 1, 100, 35)
harass_w_range = menu:add_slider("Maximum W Range", harass_settings, 100, 900, 800)

clear_settings = menu:add_subcategory("Lane Clear Settings", veigar)
clear_q = menu:add_checkbox("Use Q", clear_settings, 1)
clear_q_mana = menu:add_slider("Minimum Mana to Q", clear_settings, 0, 100, 30)
clear_q_minimum = menu:add_slider("Minimum Minions to Q", clear_settings, 1, 2, 1)
clear_w = menu:add_checkbox("Use W", clear_settings, 1)
clear_w_mana = menu:add_slider("Minimum Mana to W", clear_settings, 0, 100, 30)
clear_w_minimum = menu:add_slider("Minimum Minions to W", clear_settings, 1, 6, 2)

auto_settings = menu:add_subcategory("Auto Settings", veigar)
auto_q_stack = menu:add_checkbox("Auto Q Stack Minions", auto_settings, 1)
auto_q_stack_mana = menu:add_slider("Minimum Mana to Auto Q", auto_settings, 0, 100, 30)
auto_w_stunned = menu:add_checkbox("Auto W Stunned", auto_settings, 1)
auto_e = menu:add_checkbox("Auto E Enemies", auto_settings, 1)
auto_e_number = menu:add_slider("Minimum Champs to Auto E", auto_settings, 1, 5, 3)

killsteal_enabled = menu:add_checkbox("KillSteal", veigar, 1)
killsteal_settings = menu:add_subcategory("KillSteal Settings", veigar)
killsteal_q = menu:add_checkbox("Use Q", killsteal_settings, 1)
killsteal_w = menu:add_checkbox("Use W", killsteal_settings, 1)
killsteal_r = menu:add_checkbox("Use R", killsteal_settings, 1)

drawings_menu = menu:add_subcategory("Drawings", veigar)
drawings_enabled = menu:add_checkbox("Drawings Enabled", drawings_menu, 1)
draw_combo_dmg = menu:add_checkbox("Draw Combo Dmg on Healthbar", drawings_menu, 1)
draw_targets = menu:add_checkbox("Label Targets By Priority", drawings_menu, 1)
draw_q_range = menu:add_checkbox("Draw Q Range", drawings_menu, 1)
draw_w_range = menu:add_checkbox("Draw W Range", drawings_menu, 1)
draw_e_range = menu:add_checkbox("Draw E Range", drawings_menu, 1)
draw_r_range = menu:add_checkbox("Draw R Range", drawings_menu, 1)
draw_q_color = menu:add_subcategory("Draw Q Color", drawings_menu)
draw_q_R = menu:add_slider("Q RGB Red", draw_q_color, 0, 255, 255)
draw_q_G = menu:add_slider("Q RGB Green", draw_q_color, 0, 255, 0)
draw_q_B = menu:add_slider("Q RGB Blue", draw_q_color, 0, 255, 0)
draw_w_color = menu:add_subcategory("Draw W Color", drawings_menu)
draw_w_R = menu:add_slider("W RGB Red", draw_w_color, 0, 255, 0)
draw_w_G = menu:add_slider("W RGB Red", draw_w_color, 0, 255, 255)
draw_w_B = menu:add_slider("W RGB Red", draw_w_color, 0, 255, 0)
draw_e_color = menu:add_subcategory("Draw E Color", drawings_menu)
draw_e_R = menu:add_slider("W RGB Red", draw_e_color, 0, 255, 0)
draw_e_G = menu:add_slider("W RGB Red", draw_e_color, 0, 255, 0)
draw_e_B = menu:add_slider("W RGB Red", draw_e_color, 0, 255, 255)
draw_r_color = menu:add_subcategory("Draw R Color", drawings_menu)
draw_r_R = menu:add_slider("R RGB Red", draw_r_color, 0, 255, 255)
draw_r_G = menu:add_slider("R RGB Red", draw_r_color, 0, 255, 255)
draw_r_B = menu:add_slider("R RGB Red", draw_r_color, 0, 255, 0)

--[[
do
    local function AutoUpdate()
        local Version = 1
        local file_name = "Veigar.lua"
        local url = "https://raw.githubusercontent.com/stoneb2/Bruhwalker/main/Qiayana/Qiyana.lua"
        local web_version = http:get("https://raw.githubusercontent.com/stoneb2/Bruhwalker/main/Qiayana/Qiyana.version.txt")
        console:log("BenQiyana Version: "..Version)
        console:log("BenQiyana Web Version: "..tonumber(web_version))
        if tonumber(web_version) == Version then
            console:log("BenQiyana Library successfully loaded")
        else
            http:download_file(url, file_name)
            console:log("New BenQiyana Update Available")
            console:log("Please Reload with F5")
        end
    end
    AutoUpdate()
end
]]

local spellQ = {
    range = 950,
    width = 140, 
    speed = 2200,
    delay = 0.25
}

local q_input = {
    source = local_player,
    speed = spellQ.speed, range = spellQ.range,
    delay = spellQ.delay, radius = spellQ.width,
    collision = {"wind_wall"},
    type = "linear", hitbox = true
}

local spellW = {
    range = 900, 
    radius = 240,
    delay = 0.25,
    speed = math.huge,
    time = 1.221
}

local w_input = {
    source = local_player,
    speed = spellW.speed, range = spellW.range,
    delay = (spellW.delay + spellW.time), radius = spellW.radius,
    collision = {},
    type = "circular", hitbox = true
}

local spellE = {
    range = 725,
    delay = 0.25,
    time = 0.5,
    speed = math.huge,
    radius = 400
}

local e_input = {
    source = local_player,
    speed = spellE.speed, range = spellE.range,
    delay = (spellE.delay + spellE.time), radius = spellE.radius,
    collision = {},
    type = "circular", hitbox = true
}

local spellR = {
    range = 650,
    delay = 0.25
}

local function IsLaneMinion(unit)
    if string.find(tostring(unit.champ_name), "MinionRanged") or string.find(tostring(unit.champ_name), "MinionMelee") or string.find(tostring(unit.champ_name), "MinionSiege") then
        return true
    end
    return false
end

local function GetLineTargetCount(source, aimPos, delay, speed, width)
    local Count = 0
    players = game.players
    for _, target in ipairs(players) do
        local Range = 1100 * 1100
        if target.object_id ~= 0 and ml.IsValid(target) and target.is_enemy and ml.GetDistanceSqr(local_player, target.origin) < Range then
            local pointSegment, pointLine, isOnSegment = ml.VectorPointProjectionOnLineSegment(source.origin, aimPos, target.origin)
            if pointSegment and isOnSegment and (ml.GetDistanceSqr2(target.origin, pointSegment) <= (target.bounding_radius + width) * (target.bounding_radius + width)) then
                Count = Count + 1
            end
        end
    end
    return Count
end

local function GetLineMinionCount(source, aimPos, delay, speed, width)
    local Count = 0
    players = game.minions
    for _, target in ipairs(players) do
        if IsLaneMinion(target) then
            local Range = 1100 * 1100
            if target.object_id ~= 0 and ml.IsValid(target) and target.is_enemy and ml.GetDistanceSqr(local_player, target.origin) < Range then
                local pointSegment, pointLine, isOnSegment = ml.VectorPointProjectionOnLineSegment(source.origin, aimPos, target.origin)
                if pointSegment and isOnSegment and (ml.GetDistanceSqr2(target.origin, pointSegment) <= (target.bounding_radius + width) * (target.bounding_radius + width)) then
                    Count = Count + 1
                end
            end
        end
    end
    return Count
end

local function GetLineJgMinionCount(source, aimPos, delay, speed, width)
    local Count = 0
    players = game.jungle_minions
    for _, target in ipairs(players) do
        if IsLaneMinion(target) then
            local Range = 1100 * 1100
            if target.object_id ~= 0 and ml.IsValid(target) and ml.GetDistanceSqr(local_player, target.origin) < Range then
                local pointSegment, pointLine, isOnSegment = ml.VectorPointProjectionOnLineSegment(source.origin, aimPos, target.origin)
                if pointSegment and isOnSegment and (ml.GetDistanceSqr2(target.origin, pointSegment) <= (target.bounding_radius + width) * (target.bounding_radius + width)) then
                    Count = Count + 1
                end
            end
        end
    end
    return Count
end

local function CastQ(target)
    if ml.Ready(SLOT_Q) then
        if ml.IsValid(target) and target.is_enemy then
            local output = arkpred:get_prediction(q_input, target)
            local inv = arkpred:get_invisible_duration(target)
            local hit_chance = (tonumber(menu:get_value(pred_q_hit_chance)) / 100)
            if output.hit_chance > hit_chance and inv < (spellQ.delay / 2) then
                local cast_pos = output.cast_pos
                local champ_count = GetLineTargetCount(local_player, cast_pos, spellQ.delay, spellQ.speed, spellQ.width)
                local minion_count = GetLineMinionCount(local_player, cast_pos, spellQ.delay, spellQ.speed, spellQ.width)
                if champ_count <= 1 and minion_count <= 1 then
                    spellbook:cast_spell(SLOT_Q, spellQ.delay, cast_pos.x, cast_pos.y, cast_pos.z)
                end
            end
        end
    end
end

local function CastQMinion(minion)
    if ml.Ready(SLOT_Q) then
        if ml.IsValid(minion) and minion.is_enemy then
            spellbook:cast_spell(SLOT_Q, spellQ.delay, minion.origin.x, minion.origin.y, minion.origin.z)
        end
    end
end

local function CastW(target)
    if ml.Ready(SLOT_W) then
        if ml.IsValid(target) and target.is_enemy then
            local output = arkpred:get_prediction(w_input, target)
            local inv = arkpred:get_invisible_duration(target)
            local hit_chance = (tonumber(menu:get_value(pred_w_hit_chance)) / 100)
            if output.hit_chance > hit_chance and inv < (spellW.delay / 2) then
                local cast_pos = output.cast_pos
                spellbook:cast_spell(SLOT_W, spellW.delay, cast_pos.x, cast_pos.y, cast_pos.z)
            end
        end
    end
end

local function CastE(target)
    if ml.Ready(SLOT_E) then
        if ml.IsValid(target) and target.is_enemy then
            local output = arkpred:get_prediction(e_input, target)
            local inv = arkpred:get_invisible_duration(target)
            local hit_chance = (tonumber(menu:get_value(pred_e_hit_chance)) / 100)
            if output.hit_chance > hit_chance and inv < (spellE.delay / 2) then
                local cast_pos = output.cast_pos
                if menu:get_value(combo_e_mode) == 1 then
                    spellbook:cast_spell(SLOT_E, spellE.delay, cast_pos.x, cast_pos.y, cast_pos.z)
                else
                    local local_player_origin = Vector(local_player.origin.x, local_player.origin.y, local_player.origin.z)
                    local target_pred = arkpred:get_position_after(target, (spellE.delay + spellE.time + game.ping / 2000 + 0.0333), true)
                    local target_origin = Vector(target_pred.x, target_pred.y, target_pred.z)
                    local new_cast_pos = target_origin + (target_origin - local_player_origin):normalized() * spellE.radius
                    if new_cast_pos:dist(local_player_origin) < spellE.range then
                        spellbook:cast_spell(SLOT_E, spellE.delay, new_cast_pos.x, new_cast_pos.y, new_cast_pos.z)
                    else
                        new_cast_pos = target_origin - (target_origin - local_player_origin):normalized() * spellE.radius
                        spellbook:cast_spell(SLOT_E, spellE.delay, new_cast_pos.x, new_cast_pos.y, new_cast_pos.z)
                    end
                    --[[
                    if menu:get_value(combo_e_stun_dir) == 0 then
                        local local_player_origin = vec3.new(local_player.origin.x, local_player.origin.y, local_player.origin.z)
                        local target_origin = vec3.new(target.origin.x, target.origin.y, target.origin.z)
                        local new_cast_pos = ml.Extend(local_player_origin, target_origin, spellE.radius)
                        if target:distance_to(new_cast_pos) < spellE.range then
                            spellbook:cast_spell(SLOT_E, spellE.delay, new_cast_pos.x, new_cast_pos.y, new_cast_pos.z)
                        end
                    elseif menu:get_value(combo_e_stun_dir) == 1 then
                        local local_player_origin = vec3.new(local_player.origin.x, local_player.origin.y, local_player.origin.z)
                        local target_origin = vec3.new(target.origin.x, target.origin.y, target.origin.z)
                        local new_cast_pos = ml.Shorten(local_player_origin, target_origin, spellE.radius)
                        if target:distance_to(new_cast_pos) < spellE.range then
                            spellbook:cast_spell(SLOT_E, spellE.delay, new_cast_pos.x, new_cast_pos.y, new_cast_pos.z)
                        end
                    end
                    ]]
                end
            end
        end
    end
end

local function CastR(target)
    if ml.Ready(SLOT_R) then
        if ml.IsValid(target) and target.is_enemy then
            spellbook:cast_spell(SLOT_R, spellR.delay, target.origin.x, target.origin.y, target.origin.z)
        end
    end
end

local function HasHealingBuff(unit)
    if myHero:distance_to(unit.origin) < 3400 and unit:has_buff("Item2003") or unit:has_buff("ItemCrystalFlask") or unit:has_buff("ItemDarkCrystalFlask") then
        return true
    end
    return false
end

local function QDmg(target)
    local damage = 0
    local level = spellbook:get_spell_slot(SLOT_Q).level
    local q_dmg = ({80, 120, 160, 200, 240})[level] + (0.6 * local_player.ability_power)
    if HasHealingBuff(target) then
        q_dmg = q_dmg - 10
    end
    damage = target:calculate_magic_damage(q_dmg)
    return damage
end

local function WDmg(target)
    local damage = 0
    local level = spellbook:get_spell_slot(SLOT_W).level
    local w_dmg = ({100, 150, 200, 250, 300})[level] + local_player.ability_power
    if HasHealingBuff(target) then
        w_dmg = w_dmg - 10
    end
    damage = target:calculate_magic_damage(w_dmg)
    return damage
end

local function RDmg(target)
    local damage = 0
    local level = spellbook:get_spell_slot(SLOT_R).level
    local r_dmg_min = ({175, 250, 325})[level] + (0.75 + local_player.ability_power)
    local missing_health = ((target.max_health - target.health) / target.max_health)
    local multiplier = 1.5 * 100 * missing_health
    if multiplier > 66.66 then
        multiplier = 66.66
    end
    multiplier = 1 + (multiplier / 100)
    local r_dmg = multiplier * r_dmg_min
    if HasHealingBuff(target) then
        r_dmg = r_dmg - 10
    end
    damage = target:calculate_magic_damage(r_dmg)
    return damage
end

local function GetMana()
    return local_player.mana
end

local function GetManaPercent()
    local mana_percent = (local_player.mana / local_player.max_mana) * 100
    return mana_percent
end

local function QMana()
    local level = spellbook:get_spell_slot(SLOT_Q).level
    local mana = ({30, 35, 40, 45, 50})[level]
    return mana
end

local function WMana()
    local level = spellbook:get_spell_slot(SLOT_W).level
    local mana = ({60, 65, 70, 75, 80})[level]
    return mana
end

local function EMana()
    local level = spellbook:get_spell_slot(SLOT_E).level
    local mana = ({70, 75, 80, 85, 90})[level]
    return mana
end

local function RMana()
    local mana = 100
    return mana
end

local function ComboDmg(target)
    local q_dmg = 0
    local w_dmg = 0
    local r_dmg = 0
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
    if ml.Ready(SLOT_W) then
        w_dmg = WDmg(target)
    end
    if ml.Ready(SLOT_R) then
        r_dmg = RDmg(target)
    end
    damage = q_dmg + w_dmg + r_dmg + elec_damage
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
    local target = SelectTarget(spellQ.range)
    if selector:get_focus_target() and ml.IsValid(selector:get_focus_target()) then
        target = selector:get_focus_target()
    end
    if target and ml.IsValid(target) and not target:has_buff("sionpassivezombie") then
        if menu:get_value(combo_e) == 1 then
            CastE(target)
        end
        if menu:get_value(combo_q) == 1 then
            if (GetManaPercent() >= menu:get_value(combo_q_mana)) and target:distance_to(local_player.origin) < menu:get_value(combo_q_range) then
                CastQ(target)
            end
        end
        if menu:get_value(combo_w) == 1 then
            if (GetManaPercent() >= menu:get_value(combo_w_mana)) and target:distance_to(local_player.origin) < menu:get_value(combo_w_range) then
                if menu:get_value(combo_w_stunned) == 1 then
                    if ml.IsImmobile(target) then
                        CastW(target)
                    else
                        if menu:get_value(combo_w_anyways) == 1 then
                            local hp_perc = (target.health / target.max_health) * 100
                            if hp_perc <= menu:get_value(combo_w_anyways_health) then
                                CastW(target)
                            end
                        end
                    end
                else
                    CastW(target)
                end
            end
        end
    end
end

local function Harass()
    local target = SelectTarget(spellQ.range)
    if selector:get_focus_target() and ml.IsValid(selector:get_focus_target()) then
        target = selector:get_focus_target()
    end
    if target and ml.IsValid(target) and not target:has_buff("sionpassivezombie") then
        if menu:get_value(harass_q) == 1 then
            if (GetManaPercent() >= menu:get_value(harass_q_mana)) and target:distance_to(local_player.origin) < menu:get_value(harass_q_range) then
                CastQ(target)
            end
        end
        if menu:get_value(harass_w) == 1 then
            if (GetManaPercent() >= menu:get_value(harass_w_mana)) and target:distance_to(local_player.origin) < menu:get_value(harass_w_range) then
                if menu:get_value(harass_w_stunned) == 1 then
                    if ml.IsImmobile(target) then
                        CastW(target)
                    else
                        if menu:get_value(harass_w_anyways) == 1 then
                            local hp_perc = (target.health / target.max_health) * 100
                            if hp_perc <= menu:get_value(harass_w_anyways_health) then
                                CastW(target)
                            end
                        end
                    end
                else
                    CastW(target)
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

local function SiegeMinion(unit)
    if string.find(unit.champ_name, "MinionSiege") then
        return true
    end
    return false
end

local function SiegeMinionsAround(pos, range)
    local minion_table = {}
    local count = 0
    minions = game.minions
    for i, m in ipairs(minions) do
        if m.object_id ~= 0 and m.is_enemy and m.is_alive and m:distance_to(pos) < range then
            if string.find(m.champ_name, "MinionSiege") then
                count = count + 1
                table.insert(minion_table, m)
            end
        end
    end
    return minion_table, count
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

local function Clear()
    if menu:get_value(clear_q) == 1 and GetManaPercent() >= menu:get_value(clear_q_mana) then
        if ml.Ready(SLOT_Q) then
            local minions = MinionsAround(local_player.origin, spellQ.range)
            if minions then
                if #minions > 0 then
                    for i, minion in ipairs(minions) do
                        local count = GetLineMinionCount(local_player, minion.origin, spellQ.delay, spellQ.speed, spellQ.width)
                        if count >= menu:get_value(clear_q_minimum) then
                            spellbook:cast_spell(SLOT_Q, spellQ.delay, minion.origin.x, minion.origin.y, minion.origin.z)
                        end
                    end
                end
            end
        end
    end
    if menu:get_value(clear_w) == 1 and GetManaPercent() >= menu:get_value(clear_w_mana) then
        if ml.Ready(SLOT_W) then
            local cast_pos, count = ml.GetBestCircularFarmPos(local_player, spellW.range, spellW.radius)
            if count >= menu:get_value(clear_w_minimum) then
                spellbook:cast_spell(SLOT_W, spellW.delay, cast_pos.x, cast_pos.y, cast_pos.z)
            end
        end
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

local function JgClear()
    if menu:get_value(clear_q) == 1 and GetManaPercent() >= menu:get_value(clear_q_mana) then
        if ml.Ready(SLOT_Q) then
            local epic_monsters, epic_monsters_count = EpicMonstersAround(local_player.origin, spellQ.range)
            local solo_monsters, solo_monsters_count = SoloCampsAround(local_player.origin, spellQ.range)
            local jg_monsters, jg_monsters_count = JungleMonstersAround(local_player.origin, spellQ.range)
            if epic_monsters and epic_monsters_count > 0 then
                for i, minion in ipairs(epic_monsters) do
                    spellbook:cast_spell(SLOT_Q, spellQ.delay, minion.origin.x, minion.origin.y, minion.origin.z)
                end
            end
            if solo_monsters and solo_monsters_count > 0 then
                for i, minion in ipairs(solo_monsters) do
                    spellbook:cast_spell(SLOT_Q, spellQ.delay, minion.origin.x, minion.origin.y, minion.origin.z)
                end
            end
            if jg_monsters and jg_monsters_count > 0 then
                for i, minion in ipairs(jg_monsters) do
                    local count = GetLineJgMinionCount(local_player, minion.origin, spellQ.delay, spellQ.speed, spellQ.width)
                    if count >= menu:get_value(clear_q_minimum) then
                        spellbook:cast_spell(SLOT_Q, spellQ.delay, minion.origin.x, minion.origin.y, minion.origin.z)
                    end
                end
            end
        end
    end
    if menu:get_value(clear_w) == 1 and GetManaPercent() >= menu:get_value(clear_w_mana) then
        if ml.Ready(SLOT_W) then
            local epic_monsters, epic_monsters_count = EpicMonstersAround(local_player.origin, spellQ.range)
            local solo_monsters, solo_monsters_count = SoloCampsAround(local_player.origin, spellQ.range)
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
            local cast_pos, count = ml.GetBestCircularJungPos(local_player, spellW.range, spellW.radius)
            if count >= menu:get_value(clear_w_minimum) then
                spellbook:cast_spell(SLOT_W, spellW.delay, cast_pos.x, cast_pos.y, cast_pos.z)
            end
        end
    end
end

local function KillSteal()
    local enemies, _ = ml.GetEnemyCount(local_player.origin, spellQ.range)
    for i, enemy in pairs(enemies) do
        if ml.Ready(SLOT_Q) then
            if QDmg(enemy) > enemy.health and enemy:distance_to(local_player.origin) < spellQ.range then
                CastQ(enemy)
            end
        end
        if ml.Ready(SLOT_W) then
            if WDmg(enemy) > enemy.health and enemy:distance_to(local_player.origin) < spellW.range then
                CastW(enemy)
            end
        end
        if ml.Ready(SLOT_R) then
            if RDmg(enemy) > enemy.health and enemy:distance_to(local_player.origin) < spellR.range then
                CastR(enemy)
            end
        end
    end
end

local function AutoQStack()
    if ml.Ready(SLOT_Q) then
        local minions = MinionsAround(local_player.origin, spellQ.range)
        local canons, count = SiegeMinionsAround(local_player.origin, spellQ.range)
        local epic_monsters, epic_monsters_count = EpicMonstersAround(local_player.origin, spellQ.range)
        local solo_monsters, solo_monsters_count = SoloCampsAround(local_player.origin, spellQ.range)
        local jg_monsters, jg_monsters_count = JungleMonstersAround(local_player.origin, spellQ.range)
        if epic_monsters and epic_monsters_count > 0 then
            for i, minion in ipairs(epic_monsters) do
                if minion.health < QDmg(minion) then
                    spellbook:cast_spell(SLOT_Q, spellQ.delay, minion.origin.x, minion.origin.y, minion.origin.z)
                end
            end
        end
        if solo_monsters and solo_monsters_count > 0 then
            for i, minion in ipairs(solo_monsters) do
                if minion.health < QDmg(minion) then
                    spellbook:cast_spell(SLOT_Q, spellQ.delay, minion.origin.x, minion.origin.y, minion.origin.z)
                end
            end
        end
        if canons then
            if count > 0 then
                for i, canon in ipairs(canons) do
                    local minions_between = GetLineMinionCount(local_player, canon.origin, spellQ.delay, spellQ.speed, spellQ.width)
                    if canon:distance_to(local_player.origin) < spellQ.range and minions_between <= 1 then
                        if canon.health < QDmg(canon) then
                            CastQMinion(canon)
                        end
                    end
                end
            end
        end
        if jg_monsters and jg_monsters_count > 0 then
            for i, minion in ipairs(jg_monsters) do
                local minions_between = GetLineJgMinionCount(local_player, minion.origin, spellQ.delay, spellQ.speed, spellQ.width)
                if minion:distance_to(local_player.origin) < spellQ.range and minions_between <= 1 then
                    if minion.health < QDmg(minion) then
                        spellbook:cast_spell(SLOT_Q, spellQ.delay, minion.origin.x, minion.origin.y, minion.origin.z)
                    end
                end
            end
        end
        if minions then
            if #minions > 0 then
                for _, minion in ipairs(minions) do
                    if IsLaneMinion(minion) then
                        local minions_between = GetLineMinionCount(local_player, minion.origin, spellQ.delay, spellQ.speed, spellQ.width)
                        if minion:distance_to(local_player.origin) < spellQ.range and minions_between <= 1 then
                            if minion.health < QDmg(minion) then
                                CastQMinion(minion)
                            end
                        end
                    end
                end
            end
        end
    end
end

local function PlayersAround(pos, range)
    local Count = 0
    local minion_table = {}
    minions = game.players
    for i, m in ipairs(minions) do
        if m.object_id ~= 0 and m.is_jungle_minion and m.is_alive and m:distance_to(pos) < range then
            Count = Count + 1
            table.insert(minion_table, m)
        end
    end
    return minion_table, Count
end

local function AutoWStunned()
    if ml.Ready(SLOT_W) then
        local player_table, count = PlayersAround(local_player.origin, spellW.range)
        if player_table then
            if count > 0 then
                for i, enemy in ipairs(player_table) do
                    if ml.IsImmobile(enemy) then
                        CastW(enemy)
                    end
                end
            end
        end
    end
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
	local predicted_main_target = pred:predict(speed ,delay, range, radius, main_target, ColWindwall, ColMinion)
	if predicted_main_target.can_cast then
		local predicted_targets = {main_target}
		local diameter_sqr = 4 * radius * radius
		for i, target in ipairs(ml.GetEnemyHeroes()) do
			if target.object_id ~= 0 and ml.IsValid(target) then
				predicted_target = pred:predict(math.huge, delay, range, radius, target, false, false)
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

local function AutoE()
    if ml.Ready(SLOT_E) then
        local enemy_champs = ml.GetEnemyHeroes()
        for i, enemy in ipairs(enemy_champs) do
            if ml.IsValid(enemy) and enemy:distance_to(local_player.origin) <= spellE.range then
                local cast_pos, targets = GetBestAOEPosition(spellE.speed, spellE.delay, spellE.range, spellE.radius, enemy, false, false)
                if cast_pos then
                    if targets >= menu:get_value(auto_e_number) then
                        spellbook:cast_spell(SLOT_E, spellE.delay, cast_pos.x, cast_pos.y, cast_pos.z)
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
        if menu:get_value(auto_q_stack) == 1 then
            AutoQStack()
        end
        if menu:get_value(auto_w_stunned) == 1 then
            AutoWStunned()
        end
        Clear()
        JgClear()
    elseif Mode == MODE_LASTHIT then
        if menu:get_value(auto_q_stack) == 1 then
            AutoQStack()
        end
        if menu:get_value(auto_w_stunned) == 1 then
            AutoWStunned()
        end
    else
        if menu:get_value(auto_q_stack) == 1 then
            AutoQStack()
        end
        if menu:get_value(auto_w_stunned) == 1 then
            AutoWStunned()
        end
    end
end

local function on_tick()
    if menu:get_value(veigar_enabled) == 1 then
        if menu:get_value(killsteal_enabled) == 1 then
            KillSteal()
        end
        Auto()
        if menu:get_value(auto_e) == 1 then
            AutoE()
        end
    end
end

local function on_possible_interupt(obj, spell_name)

end

local function on_gap_close(obj, data)

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
            if menu:get_value(draw_w_range) == 1 then
                if ml.Ready(SLOT_W) then
                    renderer:draw_circle(local_player.origin.x, local_player.origin.y, local_player.origin.z, spellW.range, tonumber(menu:get_value(draw_w_R)), tonumber(menu:get_value(draw_w_G)), tonumber(menu:get_value(draw_w_B)), 255)
                end
            end
            if menu:get_value(draw_e_range) == 1 then
                if ml.Ready(SLOT_E) then
                    renderer:draw_circle(local_player.origin.x, local_player.origin.y, local_player.origin.z, spellE.range, tonumber(menu:get_value(draw_e_R)), tonumber(menu:get_value(draw_e_G)), tonumber(menu:get_value(draw_e_B)), 255)
                end
            end
            if menu:get_value(draw_r_range) == 1 then
                if ml.Ready(SLOT_R) then
                    renderer:draw_circle(local_player.origin.x, local_player.origin.y, local_player.origin.z, spellR.range, tonumber(menu:get_value(draw_r_R)), tonumber(menu:get_value(draw_r_G)), tonumber(menu:get_value(draw_r_B)), 255)
                end
            end
        end
    end
end

client:set_event_callback("on_tick", on_tick)
client:set_event_callback("on_draw", on_draw)
client:set_event_callback("on_possible_interrupt", on_possible_interrupt)
client:set_event_callback("on_gap_close", on_gap_close)