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

function obj:_send_msg(msg)
    hs.socket.udp.new():send(msg, obj.config_url, 6699)
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
        obj:_send_msg(string)
    end):start()

    -- animation example, do cmd+ctrl+z to do ParamAngleZ animation

    obj.__funny_state = {toggle = false, num = 0, op = 'plus'}
    obj.__funny_timer = hs.timer.doEvery(0.006, function()
        if not obj.__funny_state.toggle then
            return
        end

        -- to animate angleZ, we have both the number we're currenly on
        -- and the operation we're supossed to do on each tick

        -- the animation also happens beyond the bounds of angleZ, so there's a little
        -- bit of a holding time between each angleZ edge (-30 and 30), that makes
        -- the animation feel more fluid and not mechanical

        -- values beyond 30 here determine the holding bounds of each edge
        if obj.__funny_state.num >= 40 and obj.__funny_state.op == 'plus' then
            obj.__funny_state.op = 'minus'
        elseif obj.__funny_state.num <= -40 and obj.__funny_state.op == 'minus' then
            obj.__funny_state.op = 'plus'
        end

        -- '1' here is the amount angleZ will change per tick
        if obj.__funny_state.op == 'plus' then
            obj.__funny_state.num = obj.__funny_state.num + 1
        else
            obj.__funny_state.num = obj.__funny_state.num - 1
        end

        if obj.__funny_state.num >= -30 and obj.__funny_state.num <= 30 then
            obj:_send_msg("set ParamAngleZ "..obj.__funny_state.num)
        end
    end)

    hs.hotkey.bind({"cmd", "ctrl"}, "z", function()
        obj.__funny_state.toggle = not obj.__funny_state.toggle
        if obj.__funny_state.toggle then
            hs.alert.show('doing funnies')
        else
            hs.alert.show('stopping funnies')
            obj:_send_msg("set ParamAngleZ 0")
        end
    end)
end


return obj
