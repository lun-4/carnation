local obj = {}

obj.name = "carnation"
obj.version = "0.1"
obj.author = "Luna <luna@l4.pm>"
obj.license = "Unlicense"

obj.config_url = nil

function obj:start()
    hs.alert.show('hello')

    if not obj.config_url then
        hs.alert.show('fucked up')
        return
    end

    self.timer = hs.timer.doEvery(1, function()
        local pos = hs.mouse.absolutePosition()

        -- find out mbpro screen dimensions
        client = hs.socket.udp.new():send("denis", obj.config_url, 6699)
    end)
end

return obj
