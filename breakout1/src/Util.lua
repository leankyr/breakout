--[[
    GD50
    Breakout Remake

    -- StartState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Helper functions for writing games.
]]

--[[
    atlas is the sprite sheet
    Given an "atlas" (a texture with multiple sprites), as well as a
    width and a height for the tiles therein, split the texture into
    all of the quads by simply dividing it evenly.
    
]]
function GenerateQuads(atlas, tilewidth, tileheight)
    local sheetWidth = atlas:getWidth() / tilewidth
    local sheetHeight = atlas:getHeight() / tileheight

    local sheetCounter = 1
    local spritesheet = {}

    -- nested for lopp to iterate through the atlas
    -- and divide the sheet into even dimension quads (tileWidth, tileHeight)
    -- and then pick the one we want (with another function?)
    for y = 0, sheetHeight - 1 do
        for x = 0, sheetWidth - 1 do
        -- in lua tables get one index!!! 
            spritesheet[sheetCounter] =
                love.graphics.newQuad(x * tilewidth, y * tileheight, tilewidth,
                tileheight, atlas:getDimensions())
                -- dimensions paramater is what dimensions you wanna scale
                -- the quad to??
            sheetCounter = sheetCounter + 1
        end
    end

    return spritesheet
end

--[[
    Utility function for slicing tables, a la Python.

    https://stackoverflow.com/questions/24821045/does-lua-have-something-like-pythons-slice
]]

-- returns segment of whatever table we are in
-- #tbl returns the length of the table (tables in Lua are 1D)
function table.slice(tbl, first, last, step)
    local sliced = {}
  
    for i = first or 1, last or #tbl, step or 1 do
      sliced[#sliced+1] = tbl[i]
    end
  
    return sliced
end

--[[
    This function is specifically made to piece out the paddles from the
    sprite sheet. For this, we have to piece out the paddles a little more
    manually, since they are all different sizes.

    This Function gets the paddles (blue, green, red, purple) from the picture
]]
function GenerateQuadsPaddles(atlas)
    local x = 0
    local y = 64

    local counter = 1
    local quads = {}

    for i = 0, 3 do
        -- smallest
        -- 32, 16 are the actual dimenstions
        -- of the smallest quad (the brick we 
        -- are trying to hit with the ball)
        quads[counter] = love.graphics.newQuad(x, y, 32, 16,
            atlas:getDimensions())
        counter = counter + 1
        -- medium
        -- plus 32 to get the plate the user
        -- goes left and right to catch the ball
        -- (32 on the right of the small tile)
        quads[counter] = love.graphics.newQuad(x + 32, y, 64, 16,
            atlas:getDimensions())
        counter = counter + 1
        -- large
        quads[counter] = love.graphics.newQuad(x + 96, y, 96, 16,
            atlas:getDimensions())
        counter = counter + 1
        -- huge
        quads[counter] = love.graphics.newQuad(x, y + 16, 128, 16,
            atlas:getDimensions())
        counter = counter + 1

        -- prepare X and Y for the next set of paddles
        x = 0
        y = y + 32
    end

    return quads
end
