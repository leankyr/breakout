PowerUp = Class{}

function PowerUp:init()
    -- positional and dimensional variables
    self.width = 8
    self.height = 8

    -- velocity variables
    self.dy = 0
    self.dx = 0
end


function PowerUp:collides(target)
    -- first, check to see if the left edge of either is farther to the right
    -- than the right edge of the other
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    -- then check to see if the bottom edge of either is higher than the top
    -- edge of the other
    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end 

    -- if the above aren't true, they're overlapping
    return true
end

--[[
    Places the ball in the middle of the screen, with no movement.
]]
function PowerUp:reset()
    self.x = VIRTUAL_WIDTH  - VIRTUAL_WIDTH + 20 
    self.y = VIRTUAL_HEIGHT - VIRTUAL_HEIGHT + 20 
    self.dx = 0 
    self.dy = 0 
end


function PowerUp:update(dt)
    -- update the powerUp
    -- self.dy is the speed of the ball
    self.y = self.y + self.dy * dt
    -- print('The velocity is:', self.dy)
end

function PowerUp:render()
    -- gTexture is our global texture for all blocks
    -- gBallFrames is a table of quads mapping to each individual ball skin in the texture
    love.graphics.draw(gTextures['main'], gFrames['powerups'][7],
        self.x, self.y)
end

