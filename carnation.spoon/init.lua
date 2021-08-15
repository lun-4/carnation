local obj = {}

obj.name = "carnation"
obj.version = "0.1"
obj.author = "Luna <luna@l4.pm>"
obj.license = "Unlicense"

obj.config_url = nil
obj.screen_dimensions = nil

top = 0
-- TODO: make those values work for my mbpro
bottom = 1079
right = 1919
left = 0

local function calcAngles(pos)
    local origin_x = (obj.screen_dimensions[1] / 2)
    local x_offset = pos.x - origin_x

    -- TODO understand the maths here and fix it
    local left_range = origin_x - left
    local right_range = right - origin_x

    local angle_x = nil

    if x_offset > 0 then
        angle_x = 30 * x_offset / right_range
    else
        angle_x = 30 * x_offset / left_range
    end

    local origin_y = (obj.screen_dimensions[2] / 2)
    local top_range = origin_y - top
    local bottom_range = bottom - origin_x
    local y_offset = pos.y - origin_y

    local angle_y = nil

    if y_offset > 0 then
        angle_y = -30 * y_offset / bottom_range
    else
        angle_y = -30 * y_offset / top_range
    end

    return {x=angle_x, y=angle_y}
end

function obj:start()
    hs.alert.show('hello')

    if not obj.config_url then
        hs.alert.show('fucked up: no url')
        return
    end

    if not obj.screen_dimensions then
        hs.alert.show('fucked up: no screen')
        return
    end

    -- keep watcher as global to prevent it from being gc'd away
    obj.__watcher = hs.eventtap.new({hs.eventtap.event.types.mouseMoved}, function (event)
        local pos = hs.mouse.absolutePosition()
        local angle = calcAngles(pos)
        local string = "!angles "..angle.x.." "..angle.y
        client = hs.socket.udp.new():send(string, obj.config_url, 6699)
    end):start()
end

return obj
