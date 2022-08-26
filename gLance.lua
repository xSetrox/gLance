require("natives-1627063482") -- da natives
require("lua_imGUI V3")

glance = UI.new()
glance.set_background_colour(0, 0, 0)
glance.set_highlight_colour(1, 1, 1)
local white = {r = 1, g = 1, b = 1, a = 1}
local green = {r = 0, g = 1, b = 0, a = 1}
local red = {r = 1, g = 0, b = 0, a = 1}
local cyan = {r= 0, g = 1, b = 1, a = 1}
local black = {r = 0, g = 0, b = 0, a = 1}
local purple = {r = 0.5, g = 0, b= 0.5, a = 1}
local brighter_purple = {r = 0.7, g = 0, b = 0.7, a = 1}
local darker_red = {r = 0.5, g = 0, b = 0, a  = 1}
-- credits to https://stackoverflow.com/questions/10989788/format-integer-in-lua
function format_int(number)
    local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
    -- reverse the int-string and append a comma to all blocks of 3 digits
    int = int:reverse():gsub("(%d%d%d)", "%1,")
    -- reverse the int-string back remove an optional comma and put the 
    -- optional minus and fractional part back
    return minus .. int:reverse():gsub("^,", "") .. fraction
end

function do_percentage_scale_color(perc)
    local color = {r = 0, g = 1, b = 0, a = 1.0}
    if 0.5 < perc and perc < 1.0 then 
        color.r = 0.747 
        color.g = 0.330
        color.b = 0.000
    elseif perc < 0.5 then 
        color.r = 1.0
        color.g = 0.0
        color.b = 0.0
    end
    return color
end

function conditional_color(bool) 
    if bool then
        return green 
    else
        return red 
    end
end

function none_conditional_color(stringy) 
    if stringy == "None" then 
        return red 
    end
    return green 
end

function bool_to_yes_no(bool)
    if bool then 
        return "Yes"
    else
        return "No"
    end
end

local languages = {
[0] = "English",
[1] = "French",
[2] = "German",
[3] = "Italian",
[4] = "Spanish",
[5] = "Brazilian",
[6] = "Polish",
[7] = "Russian",
[8] = "Korean",
[9] = "Chinese (Traditional)",
[10] = "Japanese",
[11] = "Mexican",
[12] = "Chinese (Simplified)"
}

overlay_x_offset = 0.00
x_offset_slider = menu.slider_float(menu.my_root(), "Overlay X Offset", {"glancexoffset"}, "", -1000, 1000, 0, 1, function(s)
    overlay_x_offset = s * 0.001
    glance = UI.new()
    glance.set_background_colour(0, 0, 0)
    glance.set_highlight_colour(1, 1, 1)
end)

overlay_y_offset = 0.00
y_offset_slider = menu.slider_float(menu.my_root(), "Overlay Y Offset", {"glanceyoffset"}, "", -1000, 1000, 0, 1, function(s)
    overlay_y_offset = s * 0.001
    glance = UI.new()
    glance.set_background_colour(0, 0, 0)
    glance.set_highlight_colour(1, 1, 1)
end)

x_offset_focused = false
menu.on_focus(x_offset_slider, function()
    x_offset_focused = true
    end
)

menu.on_blur(x_offset_slider, function()
    x_offset_focused = false
end)

y_offset_focused = false
menu.on_focus(y_offset_slider, function()
    y_offset_focused = true
end)

menu.on_blur(y_offset_slider, function()
    y_offset_focused = false
end)


all_weapons = {}
temp_weapons = util.get_weapons()
-- create a table with just weapon hashes, labels
for a,b in pairs(temp_weapons) do
    all_weapons[#all_weapons + 1] = {hash = b['hash'], label_key = b['label_key']}
end
function get_weapon_name_from_hash(hash) 
    for k,v in pairs(all_weapons) do 
        if v.hash == hash then 
            return util.get_label_text(v.label_key)
        end
    end
    return 'None'
end

-- credit to nowiry
local function get_offset_from_camera(distance)
    local cam_rot = CAM.GET_GAMEPLAY_CAM_ROT(0)
    local cam_pos = CAM.GET_GAMEPLAY_CAM_COORD()
    cam_pos.z = cam_pos.z + 1.7
    local direction = v3.toDir(cam_rot)
    local destination = 
    { 
        x = cam_pos.x + direction.x * distance, 
        y = cam_pos.y + direction.y * distance, 
        z = cam_pos.z + direction.z * distance 
    }
    return destination
end

function request_model_load(hash)
    request_time = os.time()
    if not STREAMING.IS_MODEL_VALID(hash) then
        return
    end
    STREAMING.REQUEST_MODEL(hash)
    while not STREAMING.HAS_MODEL_LOADED(hash) do
        if os.time() - request_time >= 10 then
            break
        end
        util.yield()
    end
end

--util.create_thread(function()
--    local ped_preview_ang = 0 
--    local last_focused = nil
--    local last_focused_preview_ped = 0
--    while true do 
--        local focused_tbl = players.get_focused()
--        if focused_tbl[1] ~= nil and menu.is_open() or (y_offset_focused or x_offset_focused) then
--            if (y_offset_focused or x_offset_focused) then 
--                focused = players.user()
--            else
--                focused = focused_tbl[1]
--            end
--            if last_focused ~= focused then 
--                entities.delete(last_focused_preview_ped)
--                last_focused = focused
--                local c = get_offset_from_camera(10)
--                local hash = ENTITY.GET_ENTITY_MODEL(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(focused))
--                request_model_load(hash)
--                last_focused_preview_ped = entities.create_ped(28, hash, c, ped_preview_ang)
--                PED.CLONE_PED_TO_TARGET(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(focused), last_focused_preview_ped)
--                ENTITY.SET_ENTITY_COORDS(last_focused_preview_ped, c.x, c.y, c.z, false, false, false, false)
--                ENTITY.SET_ENTITY_ALPHA(last_focused_preview_ped, 100, false)
--                ENTITY.SET_ENTITY_INVINCIBLE(last_focused_preview_ped, true)
--            else
--                local c = get_offset_from_camera(10)
--                ENTITY.SET_ENTITY_COORDS(last_focused_preview_ped, c.x, c.y, c.z, false, false, false, false)
--                if ped_preview_ang >= 360 then 
--                    ped_preview_ang = 0 
--                end
--                ENTITY.SET_ENTITY_ROTATION(last_focused_preview_ped, 0.0, 0.0, ped_preview_ang, 0, true)
--                ped_preview_ang += 1
--            end
--        else
--            entities.delete(last_focused_preview_ped)
--            last_focused = nil
--        end
--        util.yield()
--    end
--end)

-- shamelessly stolen from keks
function dec_to_ipv4(ip)
	return string.format(
		"%i.%i.%i.%i", 
		ip >> 24 & 0xFF, 
		ip >> 16 & 0xFF, 
		ip >> 8  & 0xFF, 
		ip 		 & 0xFF
	)
end

while true do
    if not util.is_session_transition_active() and NETWORK.NETWORK_IS_SESSION_STARTED() then
        local focused_tbl = players.get_focused()
        if focused_tbl[1] ~= nil and menu.is_open() or (y_offset_focused or x_offset_focused) then 
            if PAD.IS_CONTROL_JUST_PRESSED(2, 29) then
                glance.toggle_cursor_mode()
            end
            if (y_offset_focused or x_offset_focused) then 
                focused = players.user()
            else
                focused = focused_tbl[1]
            end
            local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(focused)
            local playerpos = players.get_position(focused)
            local playername = players.get_name(focused)
            local m_x, m_y = menu.get_position()
            glance.begin(playername, m_x - 0.3 + overlay_x_offset, m_y + overlay_y_offset)
            glance.subhead("Player")
            glance.start_horizontal()
            local script_host = players.get_script_host()
            local host = players.get_host()
        
            glance.label("Host: ", bool_to_yes_no(focused == host), white, conditional_color(focused == host))
            glance.divider()
            glance.label("Script host: ", bool_to_yes_no(focused == script_host), white, conditional_color(focused == script_host))
            glance.divider()
            glance.label("Modder: ", bool_to_yes_no(players.is_marked_as_modder(focused)), white, conditional_color(players.is_marked_as_modder(focused)))
            glance.divider()
            glance.label("Atk\'d you: ", bool_to_yes_no(players.is_marked_as_attacker(focused)), white, conditional_color(players.is_marked_as_attacker(focused)))
            glance.end_horizontal()
            glance.start_horizontal()
            glance.label("Wallet: ", '$' .. format_int(players.get_wallet(focused)), white, green)
            glance.divider()
            glance.label("Bank: ", '$' .. format_int(players.get_bank(focused)), white, green)
            glance.divider()
            glance.label("Total: ", '$' .. format_int(players.get_money(focused)), white, green)
            glance.end_horizontal()
            local tags = players.get_tags_string(focused)
            if tags == "" then 
                tags = "None"
            end
            glance.start_horizontal()
            glance.label('Tags: ', tags, white, cyan)
            glance.end_horizontal()
            local rid = players.get_rockstar_id(focused)
            local rid2 = players.get_rockstar_id_2(focused)
            glance.start_horizontal()
            glance.label("RID: ", if rid == rid2 then rid else rid .. '/' .. rid2, white, cyan)
            glance.end_horizontal()
            glance.start_horizontal()
            glance.label("IP: ", dec_to_ipv4(players.get_connect_ip(focused)), white, cyan)
            glance.end_horizontal()
            glance.start_horizontal()
            glance.label("Rank: ", players.get_rank(focused), white, cyan)
            glance.end_horizontal()
            local kd = tonumber(string.format("%.2f", players.get_kd(focused)))
            glance.start_horizontal()
            glance.label("K/D: ", kd, white, cyan)
            glance.end_horizontal()
            glance.start_horizontal()
            glance.label("Wanted level: ", PLAYER.GET_PLAYER_WANTED_LEVEL(focused), white, cyan)
            glance.end_horizontal()
            glance.start_horizontal()
            glance.label("Language: ", languages[players.get_language(focused)], white, cyan)
            glance.end_horizontal()
            if focused == players.user() then
                glance.start_horizontal()
                glance.label("Is femboy: ", "Yes", white, green)
                glance.end_horizontal()
            end
            glance.text(" ")
            if ENTITY.DOES_ENTITY_EXIST(ped) then 
                glance.subhead("Character")
                glance.start_horizontal()
                glance.label("X: ", math.floor(playerpos.x), white, cyan)
                glance.divider()
                glance.label("Y: ", math.floor(playerpos.y), white, cyan)
                glance.divider()
                glance.label("Z: ", math.floor(playerpos.z), white, cyan)
                glance.end_horizontal()
                glance.start_horizontal()
                local c1 = players.get_position(players.user())
                local c2 = players.get_position(focused)
                glance.label("Distance to you: ", math.ceil(MISC.GET_DISTANCE_BETWEEN_COORDS(c1.x, c1.y, c1.z, c2.x, c2.y, c2.z)), white, cyan)
                glance.end_horizontal()
                glance.start_horizontal()
                local health_perc = ENTITY.GET_ENTITY_HEALTH(ped) / ENTITY.GET_ENTITY_MAX_HEALTH(ped)
                local hp_color = do_percentage_scale_color(health_perc)
                glance.label("Health: ", tostring(ENTITY.GET_ENTITY_HEALTH(ped)) .. '/' .. tostring(ENTITY.GET_ENTITY_MAX_HEALTH(ped)), white, hp_color)
                glance.divider()
                local armor_perc = PED.GET_PED_ARMOUR(ped)/PLAYER.GET_PLAYER_MAX_ARMOUR(pid)
                local armor_color = do_percentage_scale_color(armor_perc)
                glance.label("Armor: ", tostring(PED.GET_PED_ARMOUR(ped)) .. '/' .. tostring(PLAYER.GET_PLAYER_MAX_ARMOUR(pid)), white, armor_color)
                glance.divider()
                glance.label("Godmode: ", bool_to_yes_no(players.is_godmode(focused)), white, conditional_color(players.is_godmode(focused)))
                glance.end_horizontal()
                glance.start_horizontal()
                glance.label("In interior: ", bool_to_yes_no(players.is_in_interior(focused)), white, conditional_color(players.is_in_interior(focused)))
                glance.end_horizontal()
                glance.start_horizontal()
                glance.label("Off the radar: ", bool_to_yes_no(players.is_otr(focused)), white, conditional_color(players.is_otr(focused)))
                glance.end_horizontal()
                local vehicle = players.get_vehicle_model(focused)
                if vehicle == 0 then 
                    disp_vehicle = "None"
                else
                    disp_vehicle = util.get_label_text(VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(vehicle))
                end
                glance.start_horizontal()

                glance.label("Vehicle: ", disp_vehicle, white, none_conditional_color(disp_vehicle)) 
                glance.end_horizontal()
                glance.text(" ")
                glance.subhead("Weapon")
                local wep_hash = WEAPON.GET_SELECTED_PED_WEAPON(ped)
                glance.start_horizontal()
                local wep_name =  get_weapon_name_from_hash(wep_hash)
                glance.label("Weapon: ", wep_name, white, none_conditional_color(wep_name))
                glance.end_horizontal()
                glance.start_horizontal()
                local ammo_in_clip_alloc = memory.alloc_int()
                WEAPON.GET_AMMO_IN_CLIP(ped, wep_hash, ammo_in_clip_alloc)
                glance.label("Clip: ", memory.read_int(ammo_in_clip_alloc) .. '/' .. WEAPON.GET_MAX_AMMO_IN_CLIP(ped, wep_hash, true), white, cyan)
                glance.end_horizontal()
            end
            glance.text(" ")
            glance.start_horizontal()
            if glance.button("Teleport to", purple, brighter_purple) then
                local c = players.get_position(focused)
                PED.SET_PED_COORDS_KEEP_VEHICLE(players.user_ped(), c.x, c.y, c.z)
            end
            if glance.button("Kick", red, darker_red) then
                menu.trigger_commands("kick " .. players.get_name(focused))
            end
            if glance.button("Kill", red, darker_red) then
                menu.trigger_commands("kill " .. players.get_name(focused))
            end
            glance.end_horizontal()
            glance.finish()
        end
    end
    util.yield() -- keeps the script running at all times.
end
