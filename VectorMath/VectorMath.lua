--[[

----- PLACE THIS AT THESE LINES AT THE BEGINNING OF YOUR SCRIPT ------------------------------------

--Ensuring that the library is downloaded:
local file_name = "VectorMath.lua"
if not file_manager:file_exists(file_name) then
   local url = "https://raw.githubusercontent.com/stoneb2/Bruhwalker/main/VectorMath/VectorMath.lua"
   http:download_file(url, file_name)
   console:log("VectorMath Library Downloaded")
   console:log("Please Reload with F5")
end

--Initialization line:
local ml = require "VectorMath"

----- Matrix Functions -----------------------------------------------------------------------------

--Creates a New Matrix
ml.NewMatrix(rows, columns, values)

--Add two matrices
ml.MatrixAdd(m1, m2)

--Subtract two matrices
ml.MatrixSub(m1, m2)

--Multiply two matrices
ml.MatrixMult(m1, m2)

--Matrix Type; Table, Tensor, Number
ml.MatrixType(mtx)

--Copy Matrix
ml.CopyMatrix(m1)

--Concatenate two matrices, horizontal
ml.ConcatH(m1, m2)

--Matrix Gaussian 
ml.DoGauss(mtx)

--Submatrix out of matrix
ml.SubM(m1, i1, j1, i2, j2)

--Get inverted matrix
ml.MatrixInvert(m1)

--Divide two matrices
ml.MatrixDiv(m1, m2)

--Multiply Matrix by Number
ml.MatrixMultNum(m1, num)

--Divide Matrix by Number
ml.MatrixDivNum(m1, num)

--Raise Matrix to a Power
ml.MatrixPower(m1, num)

----- Vector Functions -----------------------------------------------------------------------------

--Converts from Radians to Degrees
ml.R2D(radians)

--Converts from Degrees to Radians
ml.D2R(degrees)

--Add two vectors
ml.Add(vec1, vec2)

--Subtract two vectors
ml.Sub(vec1, vec2)

--Center between two vectors
ml.Center(vec1, vec2)

--Multiplies vector by magnitude
ml.VectorMag(vec, mag)

--Cross product of two vectors
ml.CrossProduct(vec1, vec2)

--Dot product of two vectors
ml.DotProduct(vec1, vec2)

--Vector Magnitude / Length
ml.Magnitude(vec)

--Switches vector origin to local player
ml.local_player_origin(vec)

--Switches vector back to normal league origin
ml.league_origin(vec)

--Projects a vector on a vector
ml.ProjectOn(vec1, vec2)

--Mirrors a vector on a vector
ml.MirrorOn(vec1, vec2)

--Calculates sin of two vectors
ml.Sin(vec1, vec2)

--Calculates cos of two vectors
ml.Cos(vec1, vec2)

--Calculates angle between two vectors
ml.Angle(vec1, vec2)

--Calculates angle between two 3D vectors
ml.Angle3D(vec1, vec2)

--Calculates the area between two vectors
ml.AffineArea(vec1, vec2)

--Calculates triangular area between two vectors
ml.TriangleArea(vec1, vec2)

--Performs a 2D rotation of a vector, positive = ccw and negative = cw
ml.Rotate(vec, phi)

--Rotates 3D vector by phi around x-axis
ml.RotateX3D(vec, phi)

--Rotates 3D vector by phi around y-axis
ml.RotateY3D(vec, phi)

--Rotates 3D vector by phi around z-axis
ml.RotateZ3D(vec, phi)

--Rotates a 3D vector
ml.Rotate3D(PhiX, PhiY, PhiZ)

--Returns polar value
ml.Polar(vec)

--Returns cartesian value from polar
ml.Cartesian(r, theta)

--Returns the angle formed from a vector to both input vectors
ml.AngleBetween(input_vec, vec1, vec2)

--Returns the unit vector / direction of a vector
ml.Direction(vec)

--Compares both vectors, returns difference
ml.Compare(vec1, vec2)

--Creates a new vector that is rotated 90 degrees right
ml.Perpendicular(vec)

--Creates a new vector that is rotated 90 degrees left
ml.Perpendicular2(vec)

--Extends a vector from vec1 behind vec2 by a distance
ml.Extend(vec1, vec2, distance)

--Shortens a vector from vec1 in front vec2 by a distance
ml.Shorten(vec1, vec2, distance)

--Lerps from start to end with percentage length
ml.Lerp(start_vec, end_vec, percentage)

--Normalizes an angle between 0 and 360 degrees
ml.AngleNorm(angle)

--Returns the absolute value of difference between two angles
ml.AngleDelta(angle1, angle2)

----- Game Functions -------------------------------------------------------------------------------

--Checks if a unit is valid
ml.IsValid(unit)

--Returns size of table
ml.size(table)

--Returns mouse position
ml.GetMousePos()

--Returns distance between a unit and a point
ml.GetDistanceSqr(unit, p2)

--Returns distance between two points
ml.GetDistanceSqr2(p1, p2)

--Returns a table of enemy heroes
ml.GetEnemyHeroes()

--Returns a table of ally heroes
ml.GetAllyHeroes()

--Returns shielded health of object
ml.GetShieldedHealth(damageType, target)

--Returns buff count
ml.GotBuff(unit, buffname)

--Checks if unit has a specific buff
ml.HasBuff(unit, buffname)

--Counts enemies within range
ml.GetEnemyCount(pos, range)

--Counts minions within range
ml.GetMinionCount(pos, range)

--Counts jungle monsters within range
ml.GetJungleMinionCount(pos, range)

--Checks if a spell slot is ready to cast
ml.Ready(spell)

--Checks if a unit is under ally tower
ml.is_under_ally_tower(target)

--Checks if a unit is under enemy tower
ml.is_under_enemy_tower(target)

--Returns closest jungle monster
ml.GetClosestJungle(pos, range)

--Returns closest minion
ml.GetClosestMinion(pos, range)

--Returns closest minion to an enemy
ml.GetClosestMinionToEnemy(pos, range)

--Returns closest jungle monster to an enemy
ml.GetClosestJungleEnemy(pos, range)

--Checks if a value is in a table
ml.in_list(tab, val)

--Checks if target is invulnerable
ml.is_invulnerable(target)

--Checks if target is immobile
ml.IsImmobile(target)

--Creates a table of items in inventory
ml.GetItems()

--Converts string to item slot variable
ml.SlotSet(slot_str)

--Calculates On-Hit Damage, 1 for 100% effectiveness (some on-hit abilities do not apply at 100%) 
ml.OnHitDmg(target, effectiveness)

--Calculates the centroid of a set of points
ml.GetCenter(points)

--Checks if a circle contains all given points
ml.ContainsThemAll(circle, points)

--Returns furthest point from given position
ml.FarthestFromPositionIndex(points, position)

--Removes the farthest target from list
ml.RemoveWorst(targets, position)

--Returns targets within given radius of main target
ml.GetInitialTargets(radius, main_target)

--Returns predicted target positions, returns nil if pred position cannot cast
ml.GetPredictedInitialTargets(speed, delay, range, radius, main_target, ColWindwall, ColMinion)

--Returns best AOE cast position for a target
ml.GetBestAOEPosition(speed ,delay, range, radius, main_target, ColWindwall, ColMinion)

--Adding this function to on_draw callback event draws ml.GetBestAOEPosition cast position and target hit count on the map
ml.AOEDraw()

--Returns whether or not a point is on a given line segment
ml.VectorPointProjectionOnLineSegment(v1, v2, v)

--Returns how many targets will be hit by pred / cast position
ml.GetLineTargetCount(source, aimPos, delay, speed, width)

--Returns count of minions within range of a given position
ml.MinionsAround(pos, range)

--Returns count of jungle monsters within range of a given position
ml.JungleMonstersAround(pos, range)

--Returns position to hit most minions with circular AOE spells
ml.GetBestCircularFarmPos(unit, range, radius)

--Returns position to hit most jungle monsters with circular AOE spells
ml.GetBestCircularJungPos(unit, range, radius)

--]]

do
    local function AutoUpdate()
        local Version = 9
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

local ml = {}

local_player = game.local_player
myHero = game.local_player

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
function ml.NewMatrix(rows, columns, values)
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
function ml.MatrixAdd(m1, m2)
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
function ml.MatrixSub(m1, m2)
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
function ml.MatrixMult(m1, m2)
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
function ml.MatrixType(mtx)
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
function ml.CopyMatrix(m1)
    local docopy = ml.MatrixType(m1) == "number" and num_copy or t_copy
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
function ml.ConcatH(m1, m2)
    assert(#m1 == #m2, "matrix size mismatch")
    local docopy = ml.MatrixType(m1) == "number" and num_copy or t_copy
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
function ml.DoGauss(mtx)
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
function ml.SubM(m1, i1, j1, i2, j2)
    local docopy = ml.MatrixType(m1) == "number" and num_copy or t_copy
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
function ml.MatrixInvert(m1)
    assert(#m1 == #m1[1], "matrix not square")
    local mtx = ml.CopyMatrix(m1)
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
    mtx = ml.ConcatH(mtx, ident)
    local done, rank = ml.DoGauss(mtx)
    if done then
        return ml.SubM(mtx, 1, (#mtx[1] / 2) + 1, #mtx, #mtx[1])
    else
        return nil, rank
    end
end

--Divide two matrices
function ml.MatrixDiv(m1, m2)
    local rank
    m2, rank = ml.MatrixInvert(m2)
    if not m2 then return m2j, rank end
    return ml.MatrixMult(m1, m2)
end

--Multiply Matrix by Number
function ml.MatrixMultNum(m1, num)
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
function ml.MatrixDivNum(m1, num)
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
function ml.MatrixPower(m1, num)
    assert(num == math.floor(num), "exponent not an integer")
    if num == 0 then
        return ml.NewMatrix(#m1, "I")
    end
    if num < 0 then
        local rank; m1, rank = ml.MatrixInvert(m1)
        if not m1 then return m1, rank end
        num = -num
    end
    local mtx = ml.CopyMatrix(m1)
    for i = 2, num do
        mtx = ml.MatrixMult(mtx, m1)
    end
    return mtx
end

-- Vector Functions ----------------------------------------------------------------------------------------

--Converts from Radians to Degrees
function ml.R2D(radians)
    local degrees = radians * (180 / math.pi)
    return degrees
end

--Converts from Degrees to Radians
function ml.D2R(degrees)
    radians = degrees * (math.pi / 180)
    return radians
end

--Add two vectors
function ml.Add(vec1, vec2)
    local new_x = vec1.x + vec2.x
    local new_y = vec1.y + vec2.y
    local new_z = vec1.z + vec2.z
    local add = vec3.new(new_x, new_y, new_z)
    return add
end

--Subtract two vectors
function ml.Sub(vec1, vec2)
    local new_x = vec1.x - vec2.x
    local new_y = vec1.y - vec2.y
    local new_z = vec1.z - vec2.z
    local sub = vec3.new(new_x, new_y, new_z)
    return sub
end

--Center between two vectors
function ml.Center(vec1, vec2)
    local new_x = 0.5 * (vec1.x + vec2.x)
    local new_y = 0.5 * (vec1.y + vec2.y)
    local new_z = 0.5 * (vec1.z + vec2.z)
    local center = vec3.new(new_x, new_y, new_z)
    return center
end

--Multiplies vector by magnitude
function ml.VectorMag(vec, mag)
    local x, y, z = vec.x, vec.y, vec.z
    local new_x = mag * x 
    local new_y = mag * y 
    local new_z = mag * z 
    local output = vec3.new(new_x, new_y, new_z)
    return output
end

--Cross product of two vectors
function ml.CrossProduct(vec1, vec2)
    local new_x = (vec1.y * vec2.z) - (vec1.z * vec2.y)
    local new_y = (vec1.z * vec2.x) - (vec1.x * vec2.z)
    local new_z = (vec1.x * vec2.y) - (vec1.y * vec2.x)
    local cross = vec3.new(new_x, new_y, new_z)
    return cross
end

--Dot product of two vectors
function ml.DotProduct(vec1, vec2)
    local dot = (vec1.x * vec2.x) + (vec1.y * vec2.y) + (vec1.z * vec2.z)
    return dot
end

--Vector Magnitude
function ml.Magnitude(vec)
    local mag = math.sqrt(vec.x^2 + vec.y^2 + vec.z^2)
    return mag
end

--Switches vector origin to local player
function ml.local_player_origin(vec)
    local output = ml.Sub(vec, local_player.origin)
    return output
end

--Switches vector back to normal league origin
function ml.league_origin(vec)
    local output = ml.Add(vec, local_player.origin)
    return output
end

--Projects a vector on a vector
function ml.ProjectOn(vec1, vec2)
    
end

--Mirrors a vector on a vector
function ml.MirrorOn(vec1, vec2)

end

--Calculates sin of two vectors
function ml.Sin(vec1, vec2)

end

--Calculates cos of two vectors
function ml.Cos(vec1, vec2)

end

--Calculates the angle between two vectors
function ml.Angle(vec1, vec2)
    local delta_x = vec1.x - vec2.x
    local delta_z = vec1.z - vec2.z
    local angle = ml.R2D(math.atan2(delta_z, delta_x)) + 180
    return angle
end

--Calculates angle between two 3D vectors
function ml.Angle3D(vec1, vec2)
    local dot = ml.DotProduct(vec1, vec2)
    local mag1 = ml.Magnitude(vec1)
    local mag2 = ml.Magnitude(vec2)
    local output = ml.R2D(math.acos(dot / (mag1 * mag2)))
    return output
end

--Calculates the area between two vectors
function ml.AffineArea(vec1, vec2)
    local cross = ml.CrossProduct(vec1, vec2)
    local mag = ml.Magnitude(cross)
    return mag
end

--Calculates triangular area between two vectors
function ml.TriangleArea(vec1, vec2)
    local cross = ml.CrossProduct(vec1, vec2)
    local mag = ml.Magnitude(cross)
    local area = 0.5 * mag
    return area
end

--Performs a 2D rotation of a vector, positive = ccw and negative = cw
function ml.Rotate(vec, phi)
    local x, z = vec.x, vec.z
    local x2 = (x * math.cos(ml.D2R(phi))) - (y * math.sin(ml.D2R(phi)))
    local z2 = (x * math.sin(ml.D2R(phi))) + (y * math.cos(ml.D2R(phi)))
    return x2, 0, z2
end

--Rotates 3D vector by phi around x-axis
function ml.RotateX3D(vec, phi)
    local values1 = {1, 0, 0, 0, math.cos(ml.D2R(phi)), -math.sin(ml.D2R(phi)), 0, math.sin(ml.D2R(phi)), math.cos(ml.D2R(phi))}
    local rotation = ml.NewMatrix(3, 3, values1)
    local values2 = {vec.x, vec.y, vec.z}
    local vector = ml.NewMatrix(3, 1, values2)
    local output = ml.MatrixMult(rotation, vector)
    return vec3.new(output[1][1], output[2][1], output[3][1])
end

--Rotates 3D vector by phi around y-axis
function ml.RotateY3D(vec, phi)
    local values1 = {math.cos(ml.D2R(phi)), 0, math.sin(ml.D2R(phi)), 0, 1, 0, -math.sin(ml.D2R(phi)), 0, math.cos(ml.D2R(phi))}
    local rotation = ml.NewMatrix(3, 3, values1)
    local values2 = {vec.x, vec.y, vec.z}
    local vector = ml.NewMatrix(3, 1, values2)
    local output = ml.MatrixMult(rotation, vector)
    return vec3.new(output[1][1], output[2][1], output[3][1])
end

--Rotates 3D vector by phi around z-axis
function ml.RotateZ3D(vec, phi)
    values1 = {math.cos(ml.D2R(phi)), -math.sin(ml.D2R(phi)), 0, math.sin(ml.D2R(phi)), math.cos(ml.D2R(phi)), 0, 0, 0, 1}
    rotation = ml.NewMatrix(3, 3, values1)
    values2 = {vec.x, vec.y, vec.z}
    vector = ml.NewMatrix(3, 1, values2)
    output = ml.MatrixMult(rotation, vector)
    return vec3.new(output[1][1], output[2][1], output[3][1])
end 

--Rotates a 3D vector
function ml.Rotate3D(PhiX, PhiY, PhiZ)
    local values1 = {1, 0, 0, 0, math.cos(ml.D2R(PhiX)), -math.sin(ml.D2R(PhiX)), 0, math.sin(ml.D2R(PhiX)), math.cos(ml.D2R(PhiX))}
    local values2 = {math.cos(ml.D2R(PhiY)), 0, math.sin(ml.D2R(PhiY)), 0, 1, 0, -math.sin(ml.D2R(PhiY)), 0, math.cos(ml.D2R(PhiY))}
    local values3 = {math.cos(ml.D2R(PhiZ)), -math.sin(ml.D2R(PhiZ)), 0, math.sin(ml.D2R(PhiZ)), math.cos(ml.D2R(PhiZ)), 0, 0, 0, 1}
    local rotation_x = ml.NewMatrix(3, 3, values1)
    local rotation_y = ml.NewMatrix(3, 3, values2)
    local rotation_z = ml.NewMatrix(3, 3, values3)
    local values4 = {vec.x, vec.y, vec.z}
    local vector = ml.NewMatrix(3, 1, values4)
    local mult1 = ml.MatrixMult(rotation_x, rotation_y)
    local mult2 = ml.MatrixMult(mult1, rotation_z)
    local output = ml.MatrixMult(mult2, vector)
    return vec3.new(output[1][1], output[2][1], output[3][1])
end

--Returns polar value
function ml.Polar(vec)
    local x, y, z = vec.x, vec.y, vec.z
    local r = math.sqrt((x * x) + (z * z))
    local theta = ml.R2D(math.atan2(z, x))
    return r, theta
end

--Returns cartesian value from polar
function ml.Cartesian(r, theta)
    local x = r * math.cos(ml.D2R(theta))
    local z = r * math.sin(ml.D2R(theta))
    return x, 0, z
end

--Returns the angle formed from a vector to both input vectors
function ml.AngleBetween(input_vec, vec1, vec2)
    local angle1 = ml.Angle(input_vec, vec1)
    local angle2 = ml.Angle(input_vec, vec2)
    return angle1, angle2
end

--Returns the unit vector / direction of a vector
function ml.Direction(vec)
    local output = vec:normalized()
    return output
end

--Compares both vectors, returns difference
function ml.Compare(vec1, vec2)
    local output = vec3.new(0, 0, 0)
    if vec1 == vec2 then
        local output = vec3.new(0, 0, 0)
    else
        local output = ml.Sub(vec1, vec2)
    end
    return output
end

--Creates a new vector that is rotated 90 degrees right
function ml.Perpendicular(vec)

end

--Creates a new vector that is rotated 90 degrees left
function ml.Perpendicular2(vec)

end

--Extends a vector from vec1 behind vec2 by a distance
function ml.Extend(vec1, vec2, distance)
    local direction = ml.Sub(vec2, vec1):normalized()
    local delta = ml.VectorMag(direction, distance)
    local position = ml.Add(vec2, delta)
    return position
end

--Shortens a vector from vec1 in front vec2 by a distance
function ml.Shorten(vec1, vec2, distance)
    local direction = ml.Sub(vec1, vec2, distance)
    local delta = ml.VectorMag(direction, distance)
    local position = ml.Add(direction, delta)
    return position
end

--Lerps from start to end with percentage length
function ml.Lerp(start_vec, end_vec, percentage)
    if percentage > 1 then
        percentage = percentage / 100
    end
    local sub = ml.Sub(end_vec, start_vec)
    local mag = ml.VectorMag(sub, percentage)
    local output = ml.Add(start_vec, mag)
    return output
end

--Normalizes an angle between 0 and 360 degrees
function ml.AngleNorm(angle)
    if angle < 0 then
        angle = angle + 360
    elseif angle > 360 then
        angle = angle - 360
    end
    return angle
end

--Returns the absolute value of difference between two angles
function ml.AngleDelta(angle1, angle2)
    local phi = math.fmod(math.abs(angle1 - angle2), 360)
    local delta = 0
    if phi > 180 then
        delta = 360 - phi
    else
        delta = phi
    end
    return delta
end

-- Basic Game Functions ----------------------------------------------------------------------------------------

--Checks if a unit is valid
function ml.IsValid(unit)
    if (unit and unit.is_targetable and unit.is_alive and unit.is_visible and unit.object_id and unit.health > 0) then
        return true
    end
    return false
end

--Returns size of table
function ml.size(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

--Returns mouse position
function ml.GetMousePos()
    local x, y, z = game.mouse_pos.x, game.mouse_pos.y, game.mouse_pos.z
    local output = vec3.new(x, y, z)
    return output
end

--Returns distance between a unit and a point
function ml.GetDistanceSqr(unit, p2)
    p2 = p2 or local_player.origin
    p2x, p2y, p2z = p2.x, p2.y, p2.z
    p1 = unit.origin
    p1x, p1y, p1z = p1.x, p1.y, p1.z
    local dx = p1x - p2x
    local dz = (p1z or p1y) - (p2z or p2y)
    return dx*dx + dz*dz
end

--Returns distance between two points
function ml.GetDistanceSqr2(p1, p2)
    p2x, p2y, p2z = p2.x, p2.y, p2.z
    p1x, p1y, p1z = p1.x, p1.y, p1.z
    local dx = p1x - p2x
    local dz = (p1z or p1y) - (p2z or p2y)
    return dx*dx + dz*dz
end

--Returns distance between two objects also
function ml.GetDistanceSqr2(p1, p2)
    p2x, p2y, p2z = p2.x, p2.y, p2.z
    p1x, p1y, p1z = p1.x, p1.y, p1.z
    local dx = p1x - p2x
    local dz = (p1z or p1y) - (p2z or p2y)
    return dx*dx + dz*dz
end

--Returns a table of enemy heroes
function ml.GetEnemyHeroes()
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
function ml.GetAllyHeroes()
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
function ml.GetShieldedHealth(damageType, target)
    local shield = 0
    if damageType == "AD" then
        shield = target.shield
    elseif damageType == "AP" then
        shield = target.magic_shield
    elseif damageType == "ALL" then
        shield = target.shield + target.magic_shield
    end
    return target.health + shield
end

--Returns buff count
function ml.GotBuff(unit, buffname)
    if unit:has_buff(buffname) then
        buff = unit:get_buff(buffname)
        if buff.count > 0 then
            return buff.count
        end
    end
    return 0
end

--Checks if unit has a specific buff
function ml.HasBuff(unit, buffname)
    if unit:has_buff(buffname) then
        buff = unit:get_buff(buffname)
        if buff.count > 0 then
            return true
        end
    end
    return false
end

--Counts enemies within range
function ml.GetEnemyCount(pos, range)
    local count = 0
    local enemies_in_range = {}
	for i, hero in ipairs(ml.GetEnemyHeroes()) do
	    Range = range * range
		if ml.GetDistanceSqr(hero, pos) < Range and ml.IsValid(hero) then
            table.insert(enemies_in_range, hero)
            count = count + 1
		end
	end
	return enemies_in_range, count
end

--Counts minions within range
function ml.GetMinionCount(pos, range)
	count = 0
    local enemies_in_range = {}
	minions = game.minions
	for i, minion in ipairs(minions) do
	Range = range * range
		if minion.is_enemy and ml.IsValid(minion) and ml.GetDistanceSqr(minion, pos) < Range then
            table.insert(enemies_in_range, minion)
			count = count + 1
		end
	end
	return enemies_in_range, count
end

--Counts jungle monsters within range
function ml.GetJungleMinionCount(pos, range)
    count = 0
    local enemies_in_range = {}
	minions = game.jungle_minions
	for i, minion in ipairs(minions) do
	Range = range * range
		if minion.is_jungle_minion and ml.IsValid(minion) and ml.GetDistanceSqr(minion, pos) < Range then
            table.insert(enemies_in_range, minion)
			count = count + 1
		end
	end
	return enemies_in_range, count
end

--Checks if a spell slot is ready to cast
function ml.Ready(spell)
    return spellbook:can_cast(spell)
end

--Checks if a unit is under ally tower
function ml.is_under_ally_tower(target)
    local turrets = game.turrets
    local turret_range = 800
    for i, unit in ipairs(turrets) do
        if unit and unit.is_turret and unit.is_alive and unit.team == local_player.team then
            if unit:distance_to(target.origin) <= turret_range then
                return true
            end
        end
    end
    return false
end

--Checks if a unit is under enemy tower
function ml.is_under_enemy_tower(target)
    local turrets = game.turrets
    local turret_range = 800
    for i, unit in ipairs(turrets) do
        if unit and unit.is_turret and unit.is_alive and unit.is_enemy then
            if unit:distance_to(target.origin) <= turret_range then
                return true
            end
        end
    end
    return false
end

--Returns closest jungle monster
function ml.GetClosestJungle(pos, range)
    local enemyMinions, _ = ml.GetJungleMinionCount(pos, range)
    local closestMinion = nil
    local closestMinionDistance = 9999 
    for i, minion in pairs(enemyMinions) do
        if minion then
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
function ml.GetClosestMinion(pos, range)
    local enemyMinions, _ = ml.GetMinionCount(pos, range)
    local closestMinion = nil
    local closestMinionDistance = 9999 
    for i, minion in pairs(enemyMinions) do
        if minion then
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
function ml.GetClosestMinionToEnemy(pos, range)
    local enemyMinions, _ = ml.GetMinionCount(pos, range)
    local closestMinion = nil
    local closestMinionDistance = 9999
    local enemy = ml.GetEnemyHeroes()
    for i, enemies in ipairs(enemy) do
        if enemies and ml.IsValid(enemies) then
            local hp = ml.GetShieldedHealth("AP", enemies)
            for i, minion in pairs(enemyMinions) do
                if minion then
                    if minion:distance_to(enemies.origin) < range then
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
function ml.GetClosestJungleEnemy(pos, range)
    local enemyMinions, _ = ml.GetJungleMinionCount(pos, range)
    local closestMinion = nil
    local closestMinionDistance = 9999
    local enemy = ml.GetEnemyHeroes()
    for i, enemies in ipairs(enemy) do
        if enemies and ml.IsValid(enemies) then
            local hp = ml.GetShieldedHealth("AP", enemies)
            for i, minion in pairs(enemyMinions) do
                if minion then
                    if minion:distance_to(enemies.origin) < range then
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
function ml.in_list(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true, index
        end
    end
    return false, index
end

--Checks if target is invulnerable
function ml.is_invulnerable(target)
    if target:has_buff_type(invulnerability) then
        return true
    end
    return false
end

--Checks if target is immobile
function ml.IsImmobile(target)
    if target:has_buff_type(stun) or target:has_buff_type(snare) or target:has_buff_type(knockup) or target:has_buff_type(suppression) or target:has_buff_type(slow) then
        return true
    end
    return false
end

--Creates a table of items in inventory
function ml.GetItems()
    local inventory = {}
    for _, v in ipairs(local_player.items) do
        if v and not ml.in_list(inventory, v) then
            table.insert(inventory, v.item_id)
        end
    end
    return inventory
end

--Converts string to item slot variable
function ml.SlotSet(slot_str)
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
function ml.OnHitDmg(target, effectiveness)
    local OH_AP = 0
    local OH_AD = 0
    local OH_TD = 0
    local damage = 0
    local inventory = ml.GetItems()
    for _, v in ipairs(inventory) do
        --BORK
        if tonumber(v) == 3153 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = ml.SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    OH_AD = OH_AD + 0.1*target.health
                end
            end
        --Dead Man's Plate
        elseif tonumber(v) == 3742 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = ml.SlotSet("SLOT_ITEM"..tostring(item.slot))
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
                local slot = ml.SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    OH_AD = OH_AD + 65 + (0.25 * local_player.bonus_attack_damage)
                end
            end
        --Eclipse
        elseif tonumber(v) == 6692 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = ml.SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    OH_AD = OH_AD + (0.06 * target.max_health)
                end
            end
        --Guinsoo's
        elseif tonumber(v) == 3124 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = ml.SlotSet("SLOT_ITEM"..tostring(item.slot))
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
                local slot = ml.SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    OH_AP = OH_AP + 80
                end
            end
        --Nashor's
        elseif tonumber(v) == 3115 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = ml.SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    OH_AP = OH_AP + 15 + (0.2 * local_player.ability_power)
                end
            end
        --Noonquiver
        elseif tonumber(v) == 6670 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = ml.SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    OH_AD = OH_AD + 20
                end
            end
        --Rageknife
        elseif tonumber(v) == 6677 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = ml.SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    --Confirm if this is decimal or percent
                    OH_AD = OH_AD + (1.75 * 100 * local_player.crit_chance)
                end
            end
        --RFC
        elseif tonumber(v) == 3094 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = ml.SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    OH_AP = OH_AP + 120
                end
            end
        --Recurve Bow
        elseif tonumber(v) == 1043 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = ml.SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    OH_AD = OH_AD + 15
                end
            end
        --Stormrazor
        elseif tonumber(v) == 3095 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = ml.SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    OH_AP = OH_AP + 120
                end
            end
        --Tiamat
        elseif tonumber(v) == 3077 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = ml.SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    OH_AD = OH_AD + (0.6 * local_player.total_attack_damage)
                end
            end
        --Titanic Hydra
        elseif tonumber(v) == 3748 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = ml.SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    OH_AD = OH_AD + 5 + (0.015 * local_player.max_health)
                end
            end
        --Trinity Force
        elseif tonumber(v) == 3078 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = ml.SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    OH_AD = OH_AD + (2 * local_player.base_attack_damage)
                end 
            end
        --Wit's End
        elseif tonumber(v) == 3091 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = ml.SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    local level = local_player.level
                    OH_AP = OH_AP + ({15, 18.82, 22.65, 26.47, 30.29, 34.12, 37.94, 41.76, 45.59, 49.41, 53.24, 57.06, 60.88, 64.71, 68.53, 72.35, 76.18, 80})[level]
                end 
            end
        --Divine Sunderer
        elseif tonumber(v) == 6632 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = ml.SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    OH_AD = OH_AD + math.max((1.5 * local_player.base_attack_damage), (0.1 * target.max_health))
                end
            end
        --Essence Reaver
        elseif tonumber(v) == 3508 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = ml.SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    OH_AD = OH_AD + (local_player.base_attack_damage) + (0.4 * local_player.bonus_attack_damage)
                end
            end
        --Lich Bane
        elseif tonumber(v) == 3100 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = ml.SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    OH_AP = OH_AP + (1.5 * local_player.base_attack_damage) + (0.4 * local_player.ability_power)
                end
            end
        --Sheen
        elseif tonumber(v) == 3057 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = ml.SlotSet("SLOT_ITEM"..tostring(item.slot))
                if spellbook:can_cast(slot) then
                    OH_AD = OH_AD + (local_player.base_attack_damage)
                end
            end
        --Kraken Slayer
        elseif tonumber(v) == 6672 then
            local item = local_player:get_item((tonumber(v)))
            if item ~= 0 then
                local slot = ml.SlotSet("SLOT_ITEM"..tostring(item.slot))
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

--Calculates the centroid of a set of points
function ml.GetCenter(points)
    local sum_x = 0
	local sum_z = 0
	for i = 1, #points do
		sum_x = sum_x + points[i].origin.x
		sum_z = sum_z + points[i].origin.z
	end
	local center = {x = sum_x / #points, y = 0, z = sum_z / #points}
	return center
end

--Checks if a circle contains all given points
function ml.ContainsThemAll(circle, points)
    local radius_sqr = circle.radi*circle.radi
	local contains_them_all = true
	local i = 1
	while contains_them_all and i <= #points do
		contains_them_all = ml.GetDistanceSqr2(points[i].origin, circle.center) <= radius_sqr
		i = i + 1
	end
	return contains_them_all
end

--Returns furthest point from given position
function ml.FarthestFromPositionIndex(points, position)
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

--Removes the farthest target from list
function ml.RemoveWorst(targets, position)
    local worst_target = ml.FarthestFromPositionIndex(targets, position)
	table.remove(targets, worst_target)
	return targets
end

--Returns targets within given radius of main target
function ml.GetInitialTargets(radius, main_target)
    local targets = {main_target}
	local diameter_sqr = 4 * radius * radius
	for i, target in ipairs(ml.GetEnemyHeroes()) do
		if target.object_id ~= 0 and target.object_id ~= main_target.object_id and ml.IsValid(target) and ml.GetDistanceSqr(main_target, target) < diameter_sqr then
			table.insert(targets, target)
		end
	end
	return targets
end

--Returns predicted target positions, returns nil if pred position cannot cast
function ml.GetPredictedInitialTargets(speed, delay, range, radius, main_target, ColWindwall, ColMinion)
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

--Returns best AOE cast position for a target
function ml.GetBestAOEPosition(speed, delay, range, radius, main_target, ColWindwall, ColMinion)
    local targets = ml.GetPredictedInitialTargets(speed ,delay, range, radius, main_target, ColWindwall, ColMinion) or GetInitialTargets(radius, main_target)
	local position = ml.GetCenter(targets)
	local best_pos_found = true
	local circle = {pos = position, radi = radius}
	circle.center = position
	if #targets >= 2 then best_pos_found = ml.ContainsThemAll(circle, targets) end
	while not best_pos_found do
		targets = ml.RemoveWorst(targets, position)
		position = ml.GetCenter(targets)
		circle.center = position
		best_pos_found = ml.ContainsThemAll(circle, targets)
	end
	return vec3.new(position.x, position.y, position.z), #targets
end

--Adding this function to on_draw callback event draws ml.GetBestAOEPosition cast position and target hit count on the map
function ml.AOEDraw(speed, delay, range, radius, main_target, ColWindwall, ColMinion)
    for i, unit in ipairs(ml.GetEnemyHeroes()) do
		local Dist = myHero:distance_to(unit.origin)
		if unit.object_id ~= 0 and ml.IsValid(unit) and Dist < 1500 then
			local CastPos, targets = ml.GetBestAoEPosition(speed, delay, range, radius, main_target, ColWindwall, ColMinion)
			if CastPos then
				renderer:draw_circle(CastPos.x, CastPos.y, CastPos.z, 50, 0, 137, 255, 255)
				screen_pos = game:world_to_screen(CastPos.x, CastPos.y, CastPos.z)
				x, y = screen_pos.x, screen_pos.y
				renderer:draw_text_big(x, y, "Count = "..tostring(targets), 220, 20, 60, 255)
			end
		end
	end
end

--Returns whether or not a point is on a given line segment
function ml.VectorPointProjectionOnLineSegment(v1, v2, v)
    local cx, cy, ax, ay, bx, by = v.x, (v.z or v.y), v1.x, (v1.z or v1.y), v2.x, (v2.z or v2.y)
    local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / ((bx - ax) * (bx - ax) + (by - ay) * (by - ay))
    local pointLine = { x = ax + rL * (bx - ax), y = ay + rL * (by - ay) }
    local rS = rL < 0 and 0 or (rL > 1 and 1 or rL)
    local isOnSegment = rS == rL
    local pointSegment = isOnSegment and pointLine or { x = ax + rS * (bx - ax), y = ay + rS * (by - ay) }
    return pointSegment, pointLine, isOnSegment
end

--Returns how many targets will be hit by pred / cast position
function ml.GetLineTargetCount(source, aimPos, delay, speed, width)
    local Count = 0
    players = game.players
    for _, target in ipairs(players) do
        local Range = 1100 * 1100
        if target.object_id ~= 0 and ml.IsValid(target) and target.is_enemy and ml.GetDistanceSqr(myHero, target) < Range then
            local pointSegment, pointLine, isOnSegment = ml.VectorPointProjectionOnLineSegment(source.origin, aimPos, target.origin)
            if pointSegment and isOnSegment and (ml.GetDistanceSqr2(target.origin, pointSegment) <= (target.bounding_radius + width) * (target.bounding_radius + width)) then
                Count = Count + 1
            end
        end
    end
    return Count
end

--Returns count of minions within range of a given position
function ml.MinionsAround(pos, range)
    local Count = 0
    minions = game.minions
    for i, m in ipairs(minions) do
        if m.object_id ~= 0 and m.is_enemy and m.is_alive and m:distance_to(pos) < range then
            Count = Count + 1
        end
    end
    return Count
end

--Returns count of jungle monsters within range of a given position
function ml.JungleMonstersAround(pos, range)
    local Count = 0
    minions = game.jungle_minions
    for i, m in ipairs(minions) do
        if m.object_id ~= 0 and m.is_enemy and m.is_alive and m:distance_to(pos) < range then
            Count = Count + 1
        end
    end
    return Count
end

--Returns position to hit most minions with circular AOE spells
function ml.GetBestCircularFarmPos(unit, range, radius)
    local BestPos = nil
    local MostHit = 0
    minions = game.minions
    for i, m in ipairs(minions) do
        if m.object_id ~= 0 and m.is_enemy and m.is_alive and unit:distance_to(m.origin) < range then
            local Count = ml.MinionsAround(m.origin, radius)
            if Count > MostHit then
                MostHit = Count
                BestPos = m.origin
            end
        end
    end
    return BestPos, MostHit
end

--Returns position to hit most jungle monsters with circular AOE spells
function ml.GetBestCircularJungPos(unit, range, radius)
    local BestPos = nil
    local MostHit = 0
    minions = game.jungle_minions
    for i, m in ipairs(minions) do
        if m.object_id ~= 0 and m.is_enemy and m.is_alive and unit:distance_to(m.origin) < range then
            local Count = ml.JungleMonstersAround(m.origin, radius)
            if Count > MostHit then
                MostHit = Count
                BestPos = m.origin
            end
        end
    end
    return BestPos, MostHit
end

--Returns true if a unit is killable (is not immune, and is not sion zombie)
function ml.IsKillable(unit)
    if unit:has_buff_type(spellimmunity) or unit:has_buff_type(physicalimmunity) or unit:has_buff_type(invulnerability) or unit:has_buff(sionpassivezombie) then
        return true
    end
    return false
end

return ml
