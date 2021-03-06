require "class"
require "assets"
require "entities"
require "player"
require "background"
require "cell"
require "sound"

game = {
  version = "0.1.0",
  ticktime = 0,
  player = nil,
  camera = {
    x = 0,
    y = 0
  },
  background = nil,
  layers = {
    game = {
      canvas = nil,
      shader = nil
    },
    gui = {
      canvas = nil,
      shader = nil
    }
  }
}

function game.load()
  love.window.setTitle("Vector Decay") --working title
  love.window.setMode(1024, 768)
  game.player = entities.add_entity(class(player))
  p2 = entities.add_entity(class(player))
  p2._controlled = false
  p2.pos = {x = 0, y = 0}
  game.background = entities.add_entity(background)
  entities.add_entity(class(cell)).pos = {x = 25, y = 300}
  game.layers.game.canvas = love.graphics.newCanvas()
  --game.layers.gui.canvas = love.graphics.newCanvas()
  --game.layers.game.shader = love.graphics.newShader("data/ca.fs")
end

function game.update(dt)
  entities.update(dt)
  game.ticktime = game.ticktime + dt
  if game.ticktime >= 0.05 then
    entities.tick()
    game.ticktime = 0
  end
  if not game.player then
    local newp = entities.get_first_player()
    game.player = newp
    print(newp)
    if game.player then
      game.player._controlled = true
    end
  end
end

function game.draw()
  --First draw things to Game layer
  game.layers.game.canvas:clear()
  love.graphics.setCanvas(game.layers.game.canvas)
  game.background:draw()
  entities.draw()
  love.graphics.setCanvas()
  --Then draw GUI elements to the GUI layer
  --[[
  game.layers.gui.canvas:clear()
  love.graphics.setCanvas(game.layers.gui.canvas)
  gui_sys.draw()
  love.graphics.setCanvas()
  ]]
  if game.layers.game.canvas then
    if game.layers.game.shader then
      love.graphics.setShader(game.layers.game.shader)
    end
    love.graphics.draw(game.layers.game.canvas)
    love.graphics.setShader()
  end
  if game.layers.gui.canvas then
    if game.layers.gui.shader then
      love.graphics.setShader(game.layers.gui.shader)
    end
    love.graphics.draw(game.layers.gui.canvas)
    love.graphics.setShader()
  end
end

function game.mousepressed(x, y, button)
  entities.mousepressed(x, y, button)
end

function game.mousereleased(x, y, button)
  entities.mousereleased(x, y, button)
end

function game.keypressed(key)
  entities.keypressed(key)
end

function game.keyreleased(key)
  entities.keyreleased(key)
end

local function error_printer(msg, layer)
	print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end

function game.errhand(msg)
	msg = tostring(msg)
	error_printer(msg, 2)

	if not love.window or not love.graphics or not love.event then
		return
	end

	if not love.graphics.isCreated() or not love.window.isCreated() then
		local success, status = pcall(love.window.setMode, 800, 600)
		if not success or not status then
			return
		end
	end
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
	end
	if love.joystick then
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration()
		end
	end
	if love.audio then love.audio.stop() end
	love.graphics.reset()
	local font = love.graphics.setNewFont(math.floor(love.window.toPixels(14)))
	local sRGB = select(3, love.window.getMode()).srgb
	if sRGB and love.math then
		love.graphics.setBackgroundColor(love.math.gammaToLinear(0, 0, 0))
	else
		love.graphics.setBackgroundColor(0, 0, 0)
	end
	love.graphics.setColor(255, 255, 255, 255)
	local trace = debug.traceback()
	love.graphics.clear()
	love.graphics.origin()
	local err = {}
	table.insert(err, "Error\n")
	table.insert(err, msg.."\n\n")
	for l in string.gmatch(trace, "(.-)\n") do
		if not string.match(l, "boot.lua") then
			l = string.gsub(l, "stack traceback:", "Traceback\n")
			table.insert(err, l)
		end
	end
  table.insert(err, "\n--System:--\n")
  table.insert(err, "Lua version: " .. _VERSION)
  verM, verm, rev, code = love.getVersion()
  table.insert(err, string.format("Löve2D version: %d.%d.%d %s", verM, verm, rev, code))
  local os = love.system.getOS()
  table.insert(err, "Operating System: " .. os)
  if os == "Linux" then
    local uname = io.popen("uname -a")
    for line in uname:lines() do
      table.insert(err, string.format("\t\t%s\n", line))
    end
    uname:close()
  end
  table.insert(err, "\n\nYou can send this error screen to: easimer@gmail.com\n")
  local keyb
  if os == "Windows" then keyb = "Alt-F4 or Ctrl-W"
  elseif os == "OS X" then keyb = "Cmd+Q or Cmd+W"
  elseif os == "Linux" then keyb = "Alt-F4, Ctrl-W or another exit key combo"
  elseif os == "Android" then keyb = "the Home or Back button"
  else keyb = "exit button." end
  table.insert(err, "Now, quit and restart the game using " .. keyb)
	local p = table.concat(err, "\n")
	p = string.gsub(p, "\t", "")
	p = string.gsub(p, "%[string \"(.-)\"%]", "%1")
  local logofont = love.graphics.newFont(math.floor(love.window.toPixels(24)))
  local panic = false
  local t = 0
	local function draw()
		local pos = love.window.toPixels(100)
		love.graphics.clear()
    love.graphics.setColor(255, 255, 255)
    love.graphics.setFont(logofont)
    love.graphics.print("Vector Decay v" .. game.version, love.window.toPixels(95), love.window.toPixels(38))
    love.graphics.setFont(font)
		love.graphics.printf(p, pos, pos, love.graphics.getWidth() - pos)
    if panic then
      love.graphics.setColor(200, 255, 0)
      love.graphics.point(5, 5)
      love.graphics.point(15, 5)
      love.graphics.point(25, 5)
    end
		love.graphics.present()
	end
	while true do
		love.event.pump()
		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return
			end
			if e == "keypressed" and a == "escape" then
				return
			end
		end
		draw()
		if love.timer then
			love.timer.sleep(0.1)
      t = t + love.timer.getDelta()
      if t > 0.25 then
        panic = not panic
        t = 0
      end
		end
	end
end
