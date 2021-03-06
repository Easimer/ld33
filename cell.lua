require "assets"
require "player"

cell = {}

function cell:load()
  self._sprites = {}
  self.pos = {x = 0, y = 0}
  self.state = "idle"
  self.vel = {x = 0, y = 0}
  self.rot = 0
  self.infectable = true
  self.ticks = 0
  self._sprites["idle"] = {
    frame = 1,
    maxframes = 1,
    frametime = 1000,
    frames = {
      [1] = assets.load_image("data/cell_idle.png"),
    }
  }
  self._sprites["infected"] = {
    frame = 1,
    maxframes = 1,
    frametime = 1000,
    frames = {
      [1] = assets.load_image("data/cell_infected.png"),
    }
  }
end

function cell:update(dt)
  self.rot = self.rot + 1 * dt
end

function cell:draw()
  love.graphics.draw(self._sprites[self.state].frames[1], self.pos.x - game.camera.x, self.pos.y - game.camera.y, self.rot, 1, 1, self._sprites[self.state].frames[1]:getWidth() / 2, self._sprites[self.state].frames[1]:getHeight() / 2)
end

function cell:getX()
  return self.pos.x
end

function cell:getY()
  return self.pos.y
end

function cell:getW()
  return assets.get_current_frame(self._sprites[self.state]):getWidth()
end

function cell:getH()
  return assets.get_current_frame(self._sprites[self.state]):getHeight()
end

function cell:collision(other)

end

--spawn virions if infected
function cell:tick()
  self.ticks = self.ticks + 1
  if self.state == "infected" and self.ticks >= 20 then
    self.ticks = 0
    local nvirion = entities.add_entity(class(player))
    nvirion._controlled = false
    local selfx = self.pos.x
    local selfy = self.pos.y
    npos = {x = selfx, y = selfy}
    setmetatable(nvirion.pos, getmetatable(npos))
    nvirion.vel = {x = math.random(-20, 20), y = math.random(-20, 20)}
    --setmetatable(npos, getmetatable(self.pos))
    print("X:" .. npos.x .. "Y:" .. npos.y)
  end
end
