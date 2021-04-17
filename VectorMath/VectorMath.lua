--[[
--Initialization line:
local vec3m = require "VectorMath"

--Ensuring that the library is downloaded:
local file_name = "VectorMath.lua"
if not file_manager:file_exists(file_name) then
   local url = "https://raw.githubusercontent.com/stoneb2/Bruhwalker/main/VectorMath/VectorMath.lua"
   http:download(url, file_name)
   console:log("VectorMath Library Downloaded")
   console:log("Please Reload with F5")
end
--]]

do 
    local function AutoUpdate()
        local Version = 2
        local file_name = "VectorMath.lua"
        local url = "https://raw.githubusercontent.com/stoneb2/Bruhwalker/main/VectorMath/VectorMath.lua"
        local web_version = http:get("https://raw.githubusercontent.com/stoneb2/Bruhwalker/main/VectorMath/VectorMath.version.txt")
        console:log("VectorMath Version: "..Version)
        console:log("VectorMath Web Version: "..tonumber(web_version))
        if tonumber(web_version) == Version then
            console:log("VectorMath Library successfully loaded")
        else
            http:download(url, file_name)
            console:log("New VectorMath Library Update Available")
            console:log("Please Reload with F5")
        end
    end
    AutoUpdate()
end

local vec3m = {}

local_player = game.local_player

-- Matrix Functions ----------------------------------------------------------------------------------------

local matrix_meta = {}

local num_copy = function(num)
    return num
end

local t_copy = function(t)
    local newt = setmetatable({}, getmetatable(t))
    for i, v in ipairs(t) do
        newt[i] = value
    end
    return newt
end

--Creates a New Matrix
function vec3m.NewMatrix(rows, columns, values)
    if type(rows) == "table" then
        if type(rows[1]) ~= "table" then
            return setmetatable({{rows[1]}, {rows[2]}, {rows[3]}}, matrix_meta)
        end
        return setmetatable(rows, matrix_meta)
    end
    local mtx = {}
    local value = value or 0
    if columns == "I" then
        for i = 1, rows do
            mtx[i] = {}
            for j = 1, rows do
                if i == j then
                    mtx[i][j] = 1
                else
                    mtx[i][j] = 0
                end
            end
        end
    else
        for i = 1, rows do
            mtx[i] = {}
            for j = 1, columns do
                mtx[i][j] = value
            end
        end
    end
    return setmetatable(mtx, matrix_meta)
end

--setmetatable(matrix, {__call = function( ... ) return matrix.new( ... ) end})

--Add two matrices
function vec3m.MatrixAdd(m1, m2)
    local mtx = {}
    for i = 1, #m1 do
        local m3i = {}
        mtx[i] = m3i
        for j = 1, #m1[1] do
            m3i[j] = m1[i][j] + m2[i][j]
        end
    end
    return setmetatable(mtx, matrix_meta)
end

--Subtract two matrices
function vec3m.MatrixSub(m1, m2)
    local mtx = {}
    for i = 1, #m1 do
        local m3i = {}
        mtx[i] = m3i 
        for j = 1, #m1[1] do
            m3i[j] = m[i][j] - m2[i][j]
        end
    end
    return setmetatable(mtx, matrix_meta)
end

--Multiply two matrices
function vec3m.MatrixMult(m1, m2)
    local mtx = {}
    for i = 1, #m1 do
        mtx[i] = {}
        for j = 1, #m2[1] do
            local num = m1[i][1] * m2[i][j] 
            for n = 2, #m1[1] do
                num = num + m1[i][n] * m2[n][j]
            end
            mtx[i][j] = num
        end
    end
    return setmetatable(mtx, matrix_meta)
end

--Matrix Type
function vec3m.MatrixType(mtx)
    local e = mtx[1][1]
    if type(e) == "table" then
        if e.type then
            return e:type()
        end
        return "tensor"
    end
    return "number"
end

--Copy Matrix
function vec3m.CopyMatrix(m1)
    local docopy = vec3m.MatrixType(m1) == "number" and num_copy or t_copy
    local mtx = {}
    for i = 1, #m1[1] do
        mtx[i] = {}
        for j = 1, #m1 do
            mtx[i][j] = docopy(m1[i][j])
        end
    end
    return setmetatable(mtx, matrix_meta)
end

--Concatenate two matrices, horizontal
function vec3m.ConcatH(m1, m2)
    assert(#m1 == #m2, "matrix size mismatch")
    local docopy = vec3m.MatrixType(m1) == "number" and num_copy or t_copy
    local mtx = {}
    local offset = #m1[1]
    for i = 1, #m1 do
        mtx[i] = {}
        for j = 1, offset do
            mtx[i][j] = docopy(m1[i][j])
        end
        for j = 1, #m2[1] do
            mtx[i][j + offset] = docopy(m2[i][j])
        end
    end
    return setmetatable(mtx, matrix_meta)
end

local pivot0k = function(mtx, i, j, norm2)
    local iMin
    local normMin = math.huge
    for _i = i, #mtx do
        local e = mtx[_i][j]
        local norm = math.abs(norm2(e))
        if norm > 0 and norm < normMin then
            iMin = _i
            normMin = norm
        end
    end
    if iMin then
        if iMin ~= i then
            mtx[i], mtx[iMin] = mtx[iMin], mtx[i]
        end
        return true
    end
    return false
end

local function copy(x)
    return type(x) == "table" and x.copy(x) or x
end

--Matrix Gaussian 
function vec3m.DoGauss(mtx)
    local e = mtx[1][1]
    local zero = type(e) == "table" and e.zero or 0
    local one = type(e) == "table" and e.one or 1
    local norm2 = type(e) == "table" and e.norm2 or number_norm2
    local rows, columns = #mtc, #mtx[1]
    for j = 1, rows do 
        if pivot0k(mtx, j, j, norm2) then
            for i = j + 1, rows do
                if mtx[i][j] ~= zero then
                    local factor = mtx[i][j] / mtx[j][j]
                    mtx[i][j] = copy(zero)
                    for _j = j + 1, columns do
                        mtx[i][_j] = mtx[i][_j] - factor * mtx[j][_j]
                    end
                end
            end
        else
            return false, j - 1
        end
    end
    for j = rows, 1, -1 do
        local div = mtx[j][j]
        for _j = j + 1, columns do
            mtx[j][_j] = mtx[j][_j] / div
        end
        for i = j - 1, 1, -1 do
            if mtx[i][j] ~= zero then
                local factor = mtx[i][j]
                for _j = j + 1, columns do
                    mtx[i][_j] = mtx[i][_j] - factor * mtx[j][_j]
                end
                mtx[i][j] = copy(zero)
            end
        end
        mtx[i][j] = copy(one)
    end
    return true
end

--Submatrix out of matrix
function vec3m.SubM(m1, i1, j1, i2, j2)
    local docopy = vec3m.MatrixType(m1) == "number" and num_copy or t_copy
    local mtx = {}
    for i = i1, i2 do
        local _i = i - i1 + 1
        mtx[_i] = {}
        for j = j1, j2 do
            local _j = j - j1 + 1
            mtx[_i][_j] = docopy(m1[i][j])
        end
    end
    return setmetatable(mtx, matrix_meta)
end

--Get inverted matrix
function vec3m.MatrixInvert(m1)
    assert(#m1 == #m1[1], "matrix not square")
    local mtx = vec3m.CopyMatrix(m1)
    local ident = setmetatable({}, matrix_meta)
    local e = m1[1][1]
    local zero = type(e) == "table" and e.zero or 0
    local one = type(e) == "table" and e.one or 1
    for i = 1, #m1 do
        local identi = {}
        ident[i] = identi
        for j = 1, #m1 do
            identi[i] = copy((i == j) and one or zero)
        end
    end
    mtx = vec3m.ConcatH(mtx, ident)
    local done, rank = vec3m.DoGauss(mtx)
    if done then
        return vec3m.SubM(mtx, 1, (#mtx[1] / 2) + 1, #mtx, #mtx[1])
    else
        return nil, rank
    end
end

--Divide two matrices
function vec3m.MatrixDiv(m1, m2)
    local rank
    m2, rank = vec3m.MatrixInvert(m2)
    if not m2 then return m2j, rank end
    return vec3m.MatrixMult(m1, m2)
end

--Multiply Matrix by Number
function vec3m.MatrixMultNum(m1, num)
    local mtx = {}
    for i = 1, #m1 do
        mtx[i] = {}
        for j = 1, #m1[1] do
            mtx[i][j] = m1[i][j] * num
        end
    end
    return setmetatable(mtx, matrix_meta)
end

--Divide Matrix by Number
function vec3m.MatrixDivNum(m1, num)
    local mtx = {}
    for i = 1, #m1 do
        local mtxi = {}
        mtx[i] = mtxi
        for j = 1, #m1[1] do
            mtxi[j] = m1[i][j] / num
        end
    end
    return setmetatable(mtx, matrix_meta)
end

--Raise Matrix to a Power
function vec3m.MatrixPower(m1, num)
    assert(num == math.floor(num), "exponent not an integer")
    if num == 0 then
        return vec3m.NewMatrix(#m1, "I")
    end
    if num < 0 then
        local rank; m1, rank = vec3m.MatrixInvert(m1)
        if not m1 then return m1, rank end
        num = -num
    end
    local mtx = vec3m.CopyMatrix(m1)
    for i = 2, num do
        mtx = vec3m.MatrixMult(mtx, m1)
    end
    return mtx
end

-- Vector Functions ----------------------------------------------------------------------------------------

--Converts from Radians to Degrees
function vec3m.R2D(radians)
    degrees = radians * (180 / math.pi)
    return degrees
end

--Converts from Degrees to Radians
function vec3m.D2R(degrees)
    radians = degrees * (math.pi / 180)
    return radians
end

--Add two vectors
function vec3m.Add(vec1, vec2)
    new_x = vec1.x + vec2.x
    new_y = vec1.y + vec2.y
    new_z = vec1.z + vec2.z
    add = vec3.new(new_x, new_y, new_z)
    return add
end

--Subtract two vectors
function vec3m.Sub(vec1, vec2)
    new_x = vec1.x - vec2.x
    new_y = vec1.y - vec2.y
    new_z = vec1.z - vec2.z
    sub = vec3.new(new_x, new_y, new_z)
    return sub
end

--Center between two vectors
function vec3m.Center(vec1, vec2)
    new_x = 0.5 * (vec1.x + vec2.x)
    new_y = 0.5 * (vec1.y + vec2.y)
    new_z = 0.5 * (vec1.z + vec2.z)
    center = vec3.new(new_x, new_y, new_z)
    return center
end

--Multiplies vector by magnitude
function vec3m.VectorMag(vec, mag)
    x, y, z = vec.x, vec.y, vec.z
    new_x = mag * x 
    new_y = mag * y 
    new_z = mag * z 
    output = vec3.new(new_x, new_y, new_z)
    return output
end

--Cross product of two vectors
function vec3m.CrossProduct(vec1, vec2)
    new_x = (vec1.y * vec2.z) - (vec1.z * vec2.y)
    new_y = (vec1.z * vec2.x) - (vec1.x * vec2.z)
    new_z = (vec1.x * vec2.y) - (vec1.y * vec2.x)
    cross = vec3.new(new_x, new_y, new_z)
    return cross
end

--Dot product of two vectors
function vec3m.DotProduct(vec1, vec2)
    dot = (vec1.x * vec2.x) + (vec1.y * vec2.y) + (vec1.z * vec2.z)
    return dot
end

--Vector Magnitude
function vec3m.Magnitude(vec)
    mag = math.sqrt(vec.x^2 + vec.y^2 + vec.z^2)
    return mag
end

--Switches vector origin to local player
function vec3m.local_player_origin(vec)
    output = vec3m.Sub(vec, local_player.origin)
    return output
end

--Switches vector back to normal league origin
function vec3m.league_origin(vec)
    output = vec3m.Add(vec, local_player.origin)
    return output
end

--Projects a vector on a vector
function vec3m.ProjectOn(vec1, vec2)
    
end

--Mirrors a vector on a vector
function vec3m.MirrorOn(vec1, vec2)

end

--Calculates sin of two vectors
function vec3m.Sin(vec1, vec2)

end

--Calculates cos of two vectors
function vec3m.Cos(vec1, vec2)

end

--Calculates angle between two vectors
function vec3m.Angle(vec1, vec2)
    dot = vec3m.DotProduct(vec1, vec2)
    mag1 = vec3m.Magnitude(vec1)
    mag2 = vec3m.Magnitude(vec2)
    angle = vec3m.R2D(math.acos(dot / (mag1 * mag2)))
    return angle
end

--Calculates the area between two vectors
function vec3m.AffineArea(vec1, vec2)
    cross = vec3m.CrossProduct(vec1, vec2)
    mag = vec3m.Magnitude(cross)
    return mag
end

--Calculates triangular area between two vectors
function vec3m.TriangleArea(vec1, vec2)
    cross = vec3m.CrossProduct(vec1, vec2)
    mag = vec3m.Magnitude(cross)
    area = 0.5 * mag
    return area
end

--Rotates vector by phi around x-axis
function vec3m.RotateX(vec, phi)
    values1 = {1, 0, 0, 0, math.cos(vec3m.D2R(phi)), -math.sin(vec3m.D2R(phi)), 0, math.sin(vec3m.D2R(phi)), math.cos(vec3m.D2R(phi))}
    rotation = vec3m.NewMatrix(3, 3, values1)
    values2 = {vec.x, vec.y, vec.z}
    vector = vec3m.NewMatrix(3, 1, values2)
    output = vec3m.MatrixMult(rotation, vector)
    return vec3.new(output[1][1], output[2][1], output[3][1])
end

--Rotates vector by phi around y-axis
function vec3m.RotateY(vec, phi)
    values1 = {math.cos(vec3m.D2R(phi)), 0, math.sin(vec3m.D2R(phi)), 0, 1, 0, -math.sin(vec3m.D2R(phi)), 0, math.cos(vec3m.D2R(phi))}
    rotation = vec3m.NewMatrix(3, 3, values1)
    values2 = {vec.x, vec.y, vec.z}
    vector = vec3m.NewMatrix(3, 1, values2)
    output = vec3m.MatrixMult(rotation, vector)
    return vec3.new(output[1][1], output[2][1], output[3][1])
end

--Rotates vector by phi around z-axis
function vec3m.RotateZ(vec, phi)
    values1 = {math.cos(vec3m.D2R(phi)), -math.sin(vec3m.D2R(phi)), 0, math.sin(vec3m.D2R(phi)), math.cos(vec3m.D2R(phi)), 0, 0, 0, 1}
    rotation = vec3m.NewMatrix(3, 3, values1)
    values2 = {vec.x, vec.y, vec.z}
    vector = vec3m.NewMatrix(3, 1, values2)
    output = vec3m.MatrixMult(rotation, vector)
    return vec3.new(output[1][1], output[2][1], output[3][1])
end 

--Rotates a vector
function vec3m.Rotate(PhiX, PhiY, PhiZ)
    values1 = {1, 0, 0, 0, math.cos(vec3m.D2R(PhiX)), -math.sin(vec3m.D2R(PhiX)), 0, math.sin(vec3m.D2R(PhiX)), math.cos(vec3m.D2R(PhiX))}
    values2 = {math.cos(vec3m.D2R(PhiY)), 0, math.sin(vec3m.D2R(PhiY)), 0, 1, 0, -math.sin(vec3m.D2R(PhiY)), 0, math.cos(vec3m.D2R(PhiY))}
    values3 = {math.cos(vec3m.D2R(PhiZ)), -math.sin(vec3m.D2R(PhiZ)), 0, math.sin(vec3m.D2R(PhiZ)), math.cos(vec3m.D2R(PhiZ)), 0, 0, 0, 1}
    rotation_x = vec3m.NewMatrix(3, 3, values1)
    rotation_y = vec3m.NewMatrix(3, 3, values2)
    rotation_z = vec3m.NewMatrix(3, 3, values3)
    values4 = {vec.x, vec.y, vec.z}
    vector = vec3m.NewMatrix(3, 1, values4)
    mult1 = vec3m.MatrixMult(rotation_x, rotation_y)
    mult2 = vec3m.MatrixMult(mult1, rotation_z)
    output = vec3m.MatrixMult(mult2, vector)
    return vec3.new(output[1][1], output[2][1], output[3][1])
end

--Returns polar value
function vec3m.Polar(vec)

end

--Returns the angle formed from a vector to both input vectors
function vec3m.AngleBetween(vec1, vec2)
    dot = vec3m.DotProduct(vec1, vec2)
    mag1 = vec3m.Magnitude(vec1)
    mag2 = vec3m.Magnitude(vec2)
    output = vec3m.R2D(math.acos(dot / (mag1 * mag2)))
    return output
end 

--Returns the unit vector / direction of a vector
function vec3m.Direction(vec)
    output = vec:normalized()
    return output
end

--Compares both vectors, returns difference
function vec3m.Compare(vec1, vec2)
    if vec1 == vec2 then
        output = vec3.new(0, 0, 0)
    else
        output = vec3m.Sub(vec1, vec2)
    end
    return output
end

--Creates a new vector that is rotated 90 degrees right
function vec3m.Perpendicular(vec)

end

--Creates a new vector that is rotated 90 degrees left
function vec3m.Perpendicular2(vec)

end

--Extends a vector towards a vector
function vec3m.Extend(vec, distance)
    ratio = (vec3m.Magnitude(vec) + distance) / (vec3m.Magnitude(vec))
    output = vec3m.VectorMag(vec, ratio)
    return output
end

--Shortens a vector towards a vector
function vec3m.Shorten(vec, distance)
    ratio = (vec3m.Magnitude(vec) - distance) / (vec3m.Magnitude(vec))
    output = vec3m.VectorMag(vec, ratio)
    return output
end

--Lerps from start to end with percentage length
function vec3m.Lerp(start_vec, end_vec, percentage)
    if percentage > 1 then
        percentage = percentage / 100
    end
    sub = vec3m.Sub(end_vec, start_vec)
    mag = vec3m.VectorMag(sub, percentage)
    output = vec3m.Add(start_vec, mag)
    return output
end

-- Basic Game Functions ----------------------------------------------------------------------------------------

--Returns size of table
function vec3m.size(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

--Returns mouse position
function vec3m.GetMousePos()
    x, y, z = game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z
    local output = vec3.new(x, y, z)
    return output
end

--Returns distance between two objects
function vec3m.GetDistanceSqr(unit, p2)
    p2 = p2 or local_player.origin
    p2x, p2y, p2z = p2.x, p2.y, p2.z
    p1 = unit.origin
    p1x, p1y, p1z = p1.x, p1.y, p1.z
    local dx = p1x - p2x
    local dz = (p1z or p1y) - (p2z or p2y)
    return dx*dx + dz*dz
end

--Returns a table of enemy heroes
function vec3m.GetEnemyHeroes()
    local _EnemyHeroes = {}
	players = game.players	
	for i, unit in ipairs(players) do
		if unit and unit.is_enemy then
			table.insert(_EnemyHeroes, unit)
		end
	end	
	return _EnemyHeroes
end

--Returns a table of ally heroes
function vec3m.GetAllyHeroes()
    local _AllyHeroes = {}
    players = game.players
    for i, unit in ipairs(players) do
        if unit and not unit.is_enemy and unit.object_id ~= local_player.object_id then
            table.insert(_AllyHeroes, unit)
        end
    end
    return _AllyHeroes
end

--Returns shielded health of object
function vec3m.GetShieldedHealth(damageType, target)
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

--Returns buff count
function vec3m.GotBuff(unit, buffname)
    if unit:has_buff(buffname) then
        buff = unit:get_buff(buffname)
        if buff.count > 0 then
            return buff.count
        end
    end
    return 0
end

--Checks if unit has a specific buff
function vec3m.HasBuff(unit, buffname)
    if unit:has_buff(buffname) then
        buff = unit:get_buff(buffname)
        if buff.count > 0 then
            return true
        end
    end
    return false
end

--Counts enemies within range
function vec3m.GetEnemyCount(pos, range)
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

--Counts minions within range
function vec3m.GetMinionCount(pos, range)
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

--Counts jungle monsters within range
function vec3m.GetJungleMinionCount(pos, range)
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

--Checks if a spell slot is ready to cast
function vec3m.Ready(spell)
    return spellbook:can_cast(spell)
end

--Checks if a unit is valid
function vec3m.IsValid(unit)
    if (unit and unit.is_targetable and unit.is_alive and unit.is_visible and unit.object_id and unit.health > 0) then
        return true
    end
    return false
end

--Checks if a unit is under tower
function vec3m.is_under_tower(target)
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

--Returns closest jungle monster
function vec3m.GetClosestJungle()
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

--Returns closest minion
function vec3m.GetClosestMinion()
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

--Returns closest minion to an enemy
function vec3m.GetClosestMinionToEnemy()
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

--Returns closest jungle monster to an enemy
function vec3m.GetClosestJungleEnemy()
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

--Checks if a value is in a table
function vec3m.in_list(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

--Checks if target is invulnerable
function vec3m.is_invulnerable(target)
    if target:has_buff_type(18) then
        return true
    end
    return false
end

--Checks if targewt is immobile
function vec3m.IsImmobile(target)
    if target:has_buff_type(5) or target:has_buff_type(11) or target:has_buff_type(29) or target:has_buff_type(24) or target:has_buff_type(10) then
        return true
    end
    return false
end

--Creates a table of items in inventory
function vec3m.GetItems()
    local inventory = {}
    for _, v in ipairs(local_player.items) do
        if v and not in_list(inventory, v) then
            table.insert(inventory, v.item_id)
        end
    end
    return inventory
end

--Converts string to item slot variable
function vec3m.SlotSet(slot_str)
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

--Calculates On-Hit Damage 
function vec3m.OnHitDmg(target, effectiveness)
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

return vec3m
