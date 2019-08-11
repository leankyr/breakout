--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.ball = params.ball
    self.level = params.level
    self.recoverPoints = params.recoverPoints
    self.widthPoints = params.widthPoints
    self.flag = params.flag
    -- get the power up from the previous state
    self.powerUp = params.powerUp
    
    -- give ball random starting velocity
    self.ball.dx = math.random(-200, 200)
    self.ball.dy = math.random(-50, -60)


    -- drop interval for the powerUp in seconds after it appeared on screen
    self.dropInterval = math.random(5, 15)
    -- respawn interval
    self.respawnInterval = 0
    -- drop timer var
    self.dropTimer = 0
    -- respawn timer
    self.respawnTimer = 0
    -- give power up velocity
    -- self.powerUp.dy = 0.1
end
    
function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    -- update positions based on velocity
    self.paddle:update(dt)
    self.ball:update(dt)
    self.powerUp:update(dt)
      
    if self.flag then
      self.ball2:update(dt)
    end


    if self.ball:collides(self.paddle) then
        -- raise ball above paddle in case it goes below it, then reverse dy
        self.ball.y = self.paddle.y - 8
        self.ball.dy = -self.ball.dy

        --
        -- tweak angle of bounce based on where it hits the paddle
        --

        -- if we hit the paddle on its left side while moving left...
        if self.ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
            self.ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - self.ball.x))
        
        -- else if we hit the paddle on its right side while moving right...
        elseif self.ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
            self.ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - self.ball.x))
        end

        gSounds['paddle-hit']:play()
    end


    -- Could I ever put all this in a Class???

    if self.powerUp.x >= 0 then
        -- set the dropTimer up
        self.dropTimer = self.dropTimer + dt
        -- DEBUG: show the timer value
        --print('The dropTimer value is:', self.dropTimer)
    end

    if self.powerUp.x < 0 then
        self.respawnTimer = self.respawnTimer + dt
        -- DEBUG: show the respawnTimer value
        --print('The respawnTimer value is:', self.respawnTimer)
    end
    -- DEBUG: show the timer value
    -- print('The timer value is:', self.timer)
    -- check if we passed the time specified

    if self.dropTimer > self.dropInterval then
        self.powerUp.dy = 10
    end
    
    if self.respawnTimer > self.respawnInterval then
        self.powerUp.x = math.random(0, VIRTUAL_WIDTH)
        self.powerUp.y = math.random(0, VIRTUAL_HEIGHT/2)
        self.respawnTimer = 0
        self.dropInterval = math.random(5, 15)
        --print('The drop interval is value is:', self.dropInterval)

    end

    -- PowerUp collission code
    if self.powerUp:collides(self.paddle) then
        -- play a sound
        gSounds['paddle-hit']:play()

        -- init the ball
        self.ball2 = Ball()
        self.ball2.x = self.paddle.x + (self.paddle.width / 2)
        self.ball2.y = self.paddle.y - self.paddle.height
        -- give ball random starting velocity
        self.ball2.dx = math.random(-200, 200)
        self.ball2.dy = math.random(-50, -60)
        self.flag = true


        -- Put it away from the screen
        -- Instead in order to save memory I could 
        -- erase this powerUp from memory like the previous lecture I guess
        -- but now it might not be a problem I guess
        self.powerUp.x = -25
        self.powerUp.y = -25
        -- Stop the spped
        self.powerUp.dy = 0

        -- set the timer to 0 again
        self.dropTimer = 0
        -- set the respawn interval
        self.respawnInterval = math.random(10, 30)
        --print('The respawn interval is value is:', self.respawnInterval)
    end
    
    -- if we lose the PowerUp
    if self.powerUp.y > VIRTUAL_HEIGHT then
        self.respawnInterval = math.random(10, 30)
        -- set the value of the power to negative so 
        -- that the respawn timer can work
        self.powerUp.x = -25
        self.powerUp.y = -25
        -- DEBUG
        --print('The respawn interval is value is:', self.respawnInterval)
        self.dropTimer = 0
        self.powerUp.dy = 0
    end

    -- Dunnow
    if self.flag then
        if self.ball2:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            self.ball2.y = self.paddle.y - 8
            self.ball2.dy = -self.ball2.dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if we hit the paddle on its left side while moving left...
            if self.ball2.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                self.ball2.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - self.ball2.x))
            
            -- else if we hit the paddle on its right side while moving right...
            elseif self.ball2.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                self.ball2.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - self.ball2.x))
            end

            gSounds['paddle-hit']:play()
        end
    end

    -- detect collision across all bricks with the ball
    for k, brick in pairs(self.bricks) do

        -- only check collision if we're in play
        if brick.inPlay and self.ball:collides(brick) then

            -- add to score
            self.score = self.score + (brick.tier * 200 + brick.color * 25)

            -- trigger the brick's hit function, which removes it from play
            brick:hit()

            -- if we have enough points, recover a point of health
            if self.score >= self.recoverPoints then
                -- can't go above 3 health
                self.health = math.min(3, self.health + 1)

                -- multiply recover points by 2
                self.recoverPoints = math.min(100000, self.recoverPoints * 2)

                -- play recover sound effect
                gSounds['recover']:play()
            end
            
            -- print('Width points are:', self.widthPoints)
            if self.score >= self.widthPoints then
                
                self.paddle:changeSize(true)

                -- multiply width points by 4
                self.widthPoints = math.min(100000, self.widthPoints * 2)

            end
            -- go to our victory screen if there are no more bricks left
            if self:checkVictory() then
                gSounds['victory']:play()

                gStateMachine:change('victory', {
                    level = self.level,
                    paddle = self.paddle,
                    health = self.health,
                    score = self.score,
                    highScores = self.highScores,
                    ball = self.ball,
                    recoverPoints = self.recoverPoints,
                    widthPoints = self.widthPoints
                })
            end

            --
            -- collision code for bricks
            --
            -- we check to see if the opposite side of our velocity is outside of the brick;
            -- if it is, we trigger a collision on that side. else we're within the X + width of
            -- the brick and should check to see if the top or bottom edge is outside of the brick,
            -- colliding on the top or bottom accordingly 
            --

            -- left edge; only check if we're moving right, and offset the check by a couple of pixels
            -- so that flush corner hits register as Y flips, not X flips
            


            if self.ball.x + 2 < brick.x and self.ball.dx > 0 then
                
                -- flip x velocity and reset position outside of brick
                self.ball.dx = -self.ball.dx
                self.ball.x = brick.x - 8
            
            -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
            -- so that flush corner hits register as Y flips, not X flips
            elseif self.ball.x + 6 > brick.x + brick.width and self.ball.dx < 0 then
                
                -- flip x velocity and reset position outside of brick
                self.ball.dx = -self.ball.dx
                self.ball.x = brick.x + 32
            
            -- top edge if no X collisions, always check
            elseif self.ball.y < brick.y then
                
                -- flip y velocity and reset position outside of brick
                self.ball.dy = -self.ball.dy
                self.ball.y = brick.y - 8
            
            -- bottom edge if no X collisions or top collision, last possibility
            else
                
                -- flip y velocity and reset position outside of brick
                self.ball.dy = -self.ball.dy
                self.ball.y = brick.y + 16
            end

            -- slightly scale the y velocity to speed up the game, capping at +- 150
            if math.abs(self.ball.dy) < 150 then
                self.ball.dy = self.ball.dy * 1.02
            end

            -- only allow colliding with one brick, for corners
            break
        end
        
        -- Must refractor this to a function at some point in time 

        if self.flag then
            -- only check collision if we're in play
            if brick.inPlay and self.ball2:collides(brick) then

                -- add to score
                self.score = self.score + (brick.tier * 200 + brick.color * 25)

                -- trigger the brick's hit function, which removes it from play
                brick:hit()
                -- if we have enough points, recover a point of health
                if self.score >= self.recoverPoints then
                    -- can't go above 3 health
                    self.health = math.min(3, self.health + 1)

                    -- multiply recover points by 2
                    self.recoverPoints = math.min(100000, self.recoverPoints * 2)
                    
                    -- play recover sound effect
                    gSounds['recover']:play()
                end
 
                if self.score >= self.widthPoints then
                
                    self.paddle:changeSize(true)

                    -- multiply width points by 4
                    self.widthPoints = math.min(100000, self.widthPoints * 2)

                end

                -- go to our victory screen if there are no more bricks left
                if self:checkVictory() then
                    gSounds['victory']:play()

                    gStateMachine:change('victory', {
                        level = self.level,
                        paddle = self.paddle,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        ball = self.ball,
                        recoverPoints = self.recoverPoints,
                        widthPoints = self.widthPoints
                    })
                end

                --
                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly 
                --

                -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
            

                if self.ball2.x + 2 < brick.x and self.ball2.dx > 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    self.ball2.dx = -self.ball2.dx
                    self.ball2.x = brick.x - 8
                
                -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                elseif self.ball2.x + 6 > brick.x + brick.width and self.ball2.dx < 0 then
                    
                    -- flip x velocity and reset position outside of brick
                    self.ball2.dx = -self.ball2.dx
                    self.ball2.x = brick.x + 32
                
                -- top edge if no X collisions, always check
                elseif self.ball2.y < brick.y then
                    
                    -- flip y velocity and reset position outside of brick
                    self.ball2.dy = -self.ball2.dy
                    self.ball2.y = brick.y - 8
                
                -- bottom edge if no X collisions or top collision, last possibility
                else
                    
                    -- flip y velocity and reset position outside of brick
                    self.ball2.dy = -self.ball2.dy
                    self.ball2.y = brick.y + 16
                end

                -- slightly scale the y velocity to speed up the game, capping at +- 150
                if math.abs(self.ball2.dy) < 150 then
                    self.ball2.dy = self.ball2.dy * 1.02
                end

                -- only allow colliding with one brick, for corners
                break
            end
        end
    end

    -- if ball goes below bounds, revert to serve state and decrease health
    if self.ball.y >= VIRTUAL_HEIGHT then
        self.health = self.health - 1
        self.paddle:changeSize(false)
        gSounds['hurt']:play()

        if self.health == 0 then
            gStateMachine:change('game-over', {
                score = self.score,
                highScores = self.highScores
            })
        else
            gStateMachine:change('serve', {
                paddle = self.paddle,
                bricks = self.bricks,
                health = self.health,
                score = self.score,
                highScores = self.highScores,
                level = self.level,
                recoverPoints = self.recoverPoints,
                widthPoints = self.widthPoints
            })
        end
    end

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()
    self.ball:render()
    -- render the powerUp
    self.powerUp:render()
    if self.flag then
        self.ball2:render2()
    end
    renderScore(self.score)
    renderHealth(self.health)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end
