local obj = {}

obj.name = "carnation"
obj.version = "0.1"
obj.author = "Luna <luna@l4.pm>"
obj.license = "Unlicense"

function obj:start()
    hs.alert.show('hello')
    self.timer = hs.timer.doEvery(0.005, function()
        local pos = hs.mouse.absolutePosition()
    end)
end

return obj
