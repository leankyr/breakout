--[[
    GD50
    Breakout Remake

    -- ServeState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The state in which we are waiting to serve the ball; here, we are
    basically just moving the paddle left and right with the ball until we
    press Enter, though everything in the actual game now should render in
    preparation for the serve, including our current health and score, as
    well as the level we're on.
]]

ServeState = Class{__includes = BaseState}

function ServeState:enter(params)
    -- grab game state from params
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.level = params.level
    self.recoverPoints = params.recoverPoints
    self.widthPoints = params.widthPoints
    self.flag = false
    -- init new ball (random color for fun)
    self.ball = Ball()
    -- init PowerUp
    self.bPowerUp = PowerUp(7)
    self.kPowerUp = PowerUp(10)
    self.ball.skin = math.random(7)

    self.initPoseBx = math.random(0, VIRTUAL_WIDTH)
    self.initPoseBy = math.random(0, VIRTUAL_HEIGHT/2)
    self.initPoseKx = math.random(0, VIRTUAL_WIDTH)
    self.initPoseKy = math.random(0, VIRTUAL_HEIGHT/2)
end

function ServeState:update(dt)
    -- have the ball track the player
    self.paddle:update(dt)
    self.ball.x = self.paddle.x + (self.paddle.width / 2) - 4
    self.ball.y = self.paddle.y - 8
    
    -- set bPowerUp's initial position if score is 0
    if self.score == 0 then
      -- init ball powerUp
      self.bPowerUp.x = self.initPoseBx
      self.bPowerUp.y = self.initPoseBy    
      -- init key powerUp
      self.kPowerUp.x = self.initPoseKx
      self.kPowerUp.y = self.initPoseKy
    else
        -- if it is not 0 just don't show it on the screen 
      self.bPowerUp.x = -25
      self.bPowerUp.y = -25
      -- same for key PowerUp 
      self.kPowerUp.x = -25
      self.kPowerUp.y = -25
    end
    -- update the power up
    -- self.bPowerUp:update(dt)

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        -- pass in all important state info to the PlayState
        gStateMachine:change('play', {
            paddle = self.paddle,
            bricks = self.bricks,
            health = self.health,
            score = self.score,
            highScores = self.highScores,
            ball = self.ball,
            level = self.level,
            recoverPoints = self.recoverPoints,
            widthPoints = self.widthPoints,
            flag = self.flag,
            -- send the power up to the next state
            bPowerUp = self.bPowerUp,
            kPowerUp = self.kPowerUp
        })
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function ServeState:render()
    self.paddle:render()
    self.ball:render()

    -- render the bPowerUp
    self.bPowerUp:render()
    -- render the key PowerUp
    self.kPowerUp:render()

    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    renderScore(self.score)
    renderHealth(self.health)

    love.graphics.setFont(gFonts['large'])
    love.graphics.printf('Level ' .. tostring(self.level), 0, VIRTUAL_HEIGHT / 3,
        VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Press Enter to serve!', 0, VIRTUAL_HEIGHT / 2,
        VIRTUAL_WIDTH, 'center')
end
