---@diagnostic disable: undefined-global, lowercase-global
do
    local function AutoUpdate()
        local Version = 6
        local file_name = "fakecursor.lua"
        local url = "https://raw.githubusercontent.com/stoneb2/Bruhwalker/main/fakecursor/fakecursor.lua"
        local web_version = http:get("https://raw.githubusercontent.com/stoneb2/Bruhwalker/main/fakecursor/fakecursor.version.txt")
        console:log("Fake Cursor Version: " .. Version)
        console:log("Fake Cursor Web Version: " .. tonumber(web_version))
        if tonumber(web_version) == Version then
            console:log("Fake Cursor successfully loaded")
        else
            http:download_file(url, file_name)
            console:log("New Fake Cursor Update Available")
            console:log("Please Reload with F5")
        end
    end
    AutoUpdate()
end

if file_manager:file_exists("CursorNameChange.png") then
	sprite1 = renderer:add_sprite("CursorNameChange.png", 28, 40)
else
	console:log("Cursor Sprite Downloaded")
	console:log("Please Reload with F5")
	local url = "https://raw.githubusercontent.com/stoneb2/Bruhwalker/main/fakecursor/Cursor.png"
	http:download_file(url, "CursorNameChange.png")
end

if file_manager:file_exists("Attack.png") then
	sprite2 = renderer:add_sprite("Attack.png", 26, 44)
else
	console:log("Attack Cursor Sprite Downloaded")
	console:log("Please Reload with F5")
	local url = "https://raw.githubusercontent.com/stoneb2/Bruhwalker/main/fakecursor/Attack.png"
	http:download_file(url, "Attack.png")
end

local ml = require("VectorMath")

fake_cursor_category = menu:add_category("fake clicks")
fake_cursor_enabled = menu:add_checkbox("Draw Fake Cursor", fake_cursor_category, 1)
fake_cursor_speed = menu:add_slider("Cursor Speed Factor", fake_cursor_category, 5, 30, 5)
spawn_fake_clicks = menu:add_checkbox("Spawn Fake Clicks", fake_cursor_category, 1)
spawn_red_clicks = menu:add_checkbox("Spawn Red Clicks", fake_cursor_category, 1)
fake_click_delay = menu:add_slider("Fake Click Delay", fake_cursor_category, 0, 1000, 300)
extend = menu:add_slider("extend", fake_cursor_category, 0, 500, 250)
randomize2 = menu:add_checkbox("randomize extend", fake_cursor_category, 1)
click_near_enemy = menu:add_checkbox("click near enemy", fake_cursor_category, 1)
randomize = menu:add_checkbox("randomize", fake_cursor_category, 0)
combokey = menu:add_keybinder("Combo Key", fake_cursor_category, 32)
clearkey = menu:add_keybinder("Clear Key", fake_cursor_category, string.byte("V"))
lasthitkey = menu:add_keybinder("Last Hit Key", fake_cursor_category, string.byte("X"))
harasskey = menu:add_keybinder("Harass Key", fake_cursor_category, string.byte("C"))
fleekey = menu:add_keybinder("Flee Key", fake_cursor_category, string.byte("Z"))

local function on_new_path(obj, path)
    if obj.object_id == game.local_player.object_id then
		if game:is_key_down(menu:get_value(combokey)) or game:is_key_down(menu:get_value(clearkey)) or game:is_key_down(menu:get_value(lasthitkey)) or game:is_key_down(menu:get_value(harasskey)) or game:is_key_down(menu:get_value(fleekey)) then
			game:spawn_fake_click(menu:get_value(fake_click_delay), 0)
		end
    end
end

last_order_type = nil
red_click_target = nil
local function on_issue_order(vec, order)
	if order == 2 then
		game:spawn_fake_click_pos(vec, menu:get_value(fake_click_delay), 0)
	end

	if order == 3 then
		if last_order_type == 3 then
			game:spawn_fake_click_pos(ml.GetMousePos(), 0, 0)
		end

		local name = string.lower(red_click_target.champ_name)
		if red_click_target and name == "sru_crab" 
			and not red_click_target.is_inhib 
			and not red_click_target.is_nexus 
			and name == "sru_razorbeakmini" then
			return
		end

		local multiplier = 3
		if red_target and (red_click_target.is_minion or red_click_target.is_jungle_minion) then
			multiplier = 2
		end
		local max = red_click_target and multiplier * red_click_target.bounding_radius or 3 * 65
		local basePos = red_click_target.origin
		local deltaX = math.random(0, max)
		local deltaY = math.random(0, max)
		local clickPos = vec3.new(basePos.x + deltaX, basePos.y, basePos.z + deltaY)
		game:spawn_fake_click_pos(clickPos, 0, 1)
	end

	last_order_type = order
end

local function on_pre_attack(target)
	if menu:get_value(spawn_fake_clicks) == 1 and target.is_valid and not target.is_inhib and not target.is_nexus then
		red_click_target = target
        if target.champ_name ~= "SRU_Crab" then
            origin = target.origin
            
            origin = target.origin
            my_origin = game.local_player.origin
            x, y, z = origin.x, origin.y, origin.z
            x1, y1, z1 = my_origin.x, my_origin.y, my_origin.z

            extend_val = menu:get_value(extend)

            if menu:get_value(randomize2) == 1 then
                extend_val = math.random(extend_val - 80, extend_val + 80)
            end

            calc = vector_math:add_to_direction(x, y, z, x1, y, z1, -extend_val)

            origin = calc

            if menu:get_value(click_near_enemy) == 1 then
                if menu:get_value(randomize) == 1 then
                    click_pos = vec3.new(origin.x + math.random(150,190), origin.y, origin.z + math.random(150,190))
                else
                    click_pos = vec3.new(origin.x, origin.y, origin.z)
                end
            end
        end
	end

    cast = true
	cast_pos = vec3.new(game.local_player.origin.x + math.random(-15, 20), game.local_player.origin.y + math.random(-15, 20), 0)
	if not moving then
		moving = true
		moving2 = true
		draw_pos_last = game.mouse_2d
		draw_pos_x = draw_pos_last.x
		draw_pos_y = draw_pos_last.y
	end
	last_cast_time = game.game_time
	cast = false
end

local function is_inregion(m1, m2, x, y)
	x = x - 10
	x2 = x + 20
	
	y = y - 10
	y2 = y + 20

	if m1 > x and m2 > y and m1 < x2 and m2 < y2 then
		return true
	else
		return false
	end
end

local function is_inregion2(m1, m2, x, y)
	x = x - 80
	x2 = x + 160
	
	y = y - 80
	y2 = y + 160

	if m1 > x and m2 > y and m1 < x2 and m2 < y2 then
		return true
	else
		return false
	end
end

moving = false
moving2 = false
cast = false

draw_pos_test = nil

local function on_draw()
	if draw_vec then
		renderer:draw_circle(draw_vec.x, draw_vec.y, draw_vec.z, local_player.bounding_radius, 0, 0, 255)
	end

    if draw_pos_test then
        renderer:draw_circle(draw_pos_test.x, draw_pos_test.y, draw_pos_test.z, 50, 255, 0, 0, 255)
    end

    if menu:get_value(fake_cursor_enabled) == 1 then
		speed = menu:get_value(fake_cursor_speed)
		draw_attack_icon = false

		under_mouse_object = game.under_mouse_object

		if under_mouse_object.is_enemy then
			draw_attack_icon = true
		end

		if moving2 then
			if moving then
				tx = cast_pos.x
				ty = cast_pos.y
				sx = draw_pos_x 
				sy = draw_pos_y 
		
				deltaX = tx - sx;
				deltaY = ty - sy;
				angle = math.atan(deltaY, deltaX)
				
				distance = cast_pos:dist_to(draw_pos_x, draw_pos_y, 0)
				speed_move = distance / speed
		
				draw_pos_x = draw_pos_x + speed_move * math.cos(angle);
				draw_pos_y = draw_pos_y + speed_move * math.sin(angle);
				
				if is_inregion(draw_pos_x, draw_pos_y, tx, ty) then
					moving = false
				end

				if is_inregion2(draw_pos_x, draw_pos_y, tx, ty) then
					draw_attack_icon = true
				end
			elseif moving2 then
				draw_pos = game.mouse_2d
				tx = draw_pos.x
				ty = draw_pos.y
				sx = draw_pos_x 
				sy = draw_pos_y 

				deltaX = tx - sx;
				deltaY = ty - sy;
				angle = math.atan(deltaY, deltaX)

				distance = draw_pos:dist_to(draw_pos_x, draw_pos_y, 0)
				speed_move = distance / speed
		
				draw_pos_x = draw_pos_x + speed_move * math.cos(angle);
				draw_pos_y = draw_pos_y + speed_move * math.sin(angle);

				if is_inregion(draw_pos_x, draw_pos_y, tx, ty) then
					moving2 = false
				end

				if is_inregion2(draw_pos_x, draw_pos_y, cast_pos.x, cast_pos.y) then
					draw_attack_icon = true
				end
			end

			if draw_attack_icon then
				sprite2:draw(draw_pos_x, draw_pos_y)
			else
				sprite1:draw(draw_pos_x, draw_pos_y)
			end
		else
			draw_pos = game.mouse_2d
			
			if draw_attack_icon then
				sprite2:draw(draw_pos.x, draw_pos.y)
			else
				sprite1:draw(draw_pos.x, draw_pos.y)
			end
		end
	end
end

local function on_cast_skill(pos)
    draw_pos_test = pos
	cast = true
	cast_pos = vec3.new(pos.x + math.random(-15, 20), pos.y + math.random(-15, 20), 0)
	if not moving then
		moving = true
		moving2 = true
		draw_pos_last = game.mouse_2d
		draw_pos_x = draw_pos_last.x
		draw_pos_y = draw_pos_last.y
	end
	last_cast_time = game.game_time
	cast = false
end

client:set_event_callback("on_new_path", on_new_path)
client:set_event_callback("on_pre_attack", on_pre_attack)
client:set_event_callback("on_draw_always", on_draw)
client:set_event_callback("on_cast_skill", on_cast_skill)
client:set_event_callback("on_issue_order", on_issue_order)
