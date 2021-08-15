# carnation

control https://github.com/adrianiainlam/mouse-tracker-for-cubism remotely

comes with a hammerspoon script to send mac os mouse position info to the renderer.

## overall setup

- one mac os machine serves as the controller
- one linux machine serves as the renderer

```
[ mac os mouse ] ---udp----> [ puppeteer ] ----stdin---> [ mouse-tracker-for-cubism ]
```

#### setting up macos machine

depedencies:

- https://www.hammerspoon.org/

```sh
git clone https://github.com/lun-4/carnation.git
ln -s (realpath ./carnation/carnation.spoon) ~/.hammerspoon/Spoons/
```

then add relevant config to `~/.hammerspoon/init.lua`

```lua
hs.loadSpoon("carnation")
spoon.carnation.config_url = "192.168.33.22"
spoon.carnation.config_port = 6699
spoon.carnation.screen_dimensions = {3072, 1920}
spoon.carnation:start()
```

reload the config and it's ready!

#### setting up puppeteer

deps:

- https://github.com/adrianiainlam/mouse-tracker-for-cubism
- python3

```sh
git clone https://github.com/lun-4/carnation.git
cd carnation
env 'CARNATION_BIND_IP=192.168.33.22' 'LIVE2D_PATH=/path/to/mouse-tracker-for-cubism/example/demo_build/build/make_gcc/bin/Demo' 'LIVE2D_CONFIG=/path/to/mouse-tracker-for-cubism/config.txt' python3 ./puppeteer_live2d.py
```

## protocol

all udp on a port of your choosing as long as controller and puppeteer are
aligned on the port.

if a message starts with `!angles`, treat message format as `!angles x y` where
x and y are floats.

else, treat it as a full command to be sent to mouse-tracker (gives practicality
on scripting more movements without puppeteer having to know about them)

`!angles` is done to prevent having to send 2x the messages for the hot path
of mouse tracking.
