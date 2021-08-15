local obj = {}

obj.name = "carnation"
obj.version = "0.1"
obj.author = "Luna <luna@l4.pm>"
obj.license = "Unlicense"

obj.config_url = nil
obj.screen_dimensions = nil

local function calcAngles(pos)
  local screenWidth = obj.screen_dimensions[1]
  local screenHeight = obj.screen_dimensions[2]

  local inX = pos.x / screenWidth
  local inY = pos.y / screenHeight

  local absX = inX
  local absY = 1.0 - inY

  local mX = absX * 60.0
  local mY = absY * 60.0

  local resX = mX - 30.0
  local resY = mY - 30.0

  return {x=resX, y=resY}
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
