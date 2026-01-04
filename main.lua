-- F1 Random GP - Love2D Port for R36S
function love.load()
    -- Screen Setup (R36S is 640x480)
    width, height = love.graphics.getDimensions()
    
    -- Game State
    gameState = "title"
    playerX, playerZ, speed, lap, startTime = 0, 0, 0, 1, 0
    trackLength, segL, camD, camH, drawDistance = 0, 200, 0.8, 2500, 300
    
    track = {}
    createTrack()
end

function createTrack()
    track = {}
    -- Add Start Straight
    for i=1, 100 do addSeg(0) end
    -- Random Generation
    while #track < 2000 do
        local len = math.random(40, 120)
        local curve = (math.random() > 0.5 and 1.5 or -1.5) * (math.random() * 2 + 1)
        for i=1, len do addSeg(curve) end
        for i=1, len do addSeg(0) end
    end
    trackLength = #track * segL
end

function addSeg(c)
    local color = (#track / 3) % 2 < 1 and {0.2, 0.2, 0.2} or {0.22, 0.22, 0.22}
    local wall = (#track / 3) % 2 < 1 and {1, 1, 1} or {1, 0, 0}
    table.insert(track, {curve = c, color = color, wall = wall})
end

function love.update(dt)
    if gameState ~= "racing" then
        if love.keyboard.isDown("return") or love.keyboard.isDown("x") then 
            gameState = "racing" 
            startTime = love.timer.getTime()
        end
        return
    end

    -- Controls (Mapped to R36S Buttons)
    if love.keyboard.isDown("up") or love.keyboard.isDown("a") then speed = speed + 400 * dt
    elseif love.keyboard.isDown("down") or love.keyboard.isDown("b") then speed = speed - 600 * dt
    else speed = speed * 0.99 end

    if speed < 0 then speed = 0 elseif speed > 600 then speed = 600 end

    local steerPower = 0.8 * (speed / 500 + 0.2) * dt
    if love.keyboard.isDown("left") then playerX = playerX - steerPower
    elseif love.keyboard.isDown("right") then playerX = playerX + steerPower end

    -- Physics
    local startPos = math.floor(playerZ / segL) % #track + 1
    playerX = playerX - (speed / 28000) * track[startPos].curve
    playerZ = playerZ + speed

    -- Boundaries
    if math.abs(playerX) > 0.85 then speed = speed * 0.95 end
    
    -- Lap Logic
    if playerZ >= trackLength then
        playerZ = playerZ - trackLength
        lap = lap + 1
    end
end

function love.draw()
    -- Sky and Grass
    love.graphics.clear(0.45, 0.78, 0.93)
    love.graphics.setColor(0.15, 0.45, 0.16)
    love.graphics.rectangle("fill", 0, height/2, width, height/2)

    if gameState == "racing" then
        local startPos = math.floor(playerZ / segL)
        local x, dx, maxy = 0, 0, height
        
        for n = 0, drawDistance do
            local i = (startPos + n) % #track + 1
            local loop = (startPos + n) >= #track and trackLength or 0
            
            local z = (i * segL) + loop - playerZ
            local scale = camD / z
            
            local px = (1 + scale * (x - playerX * 2000)) * width / 2
            local py = (1 - scale * (-camH)) * height / 2
            local pw = scale * 2000 * width / 2
            
            if n > 0 and py < maxy then
                local prev = track_prev
                love.graphics.setColor(track[i].color)
                love.graphics.polygon("fill", prev.px-prev.pw, prev.py, px-pw, py, px+pw, py, prev.px+prev.pw, prev.py)
                love.graphics.setColor(track[i].wall)
                love.graphics.polygon("fill", prev.px-prev.pw, prev.py, px-pw, py, px-pw, py-pw*0.1, prev.px-prev.pw, prev.py-prev.pw*0.1)
                maxy = py
            end
            track_prev = {px=px, py=py, pw=pw}
            x, dx = x + dx, dx + track[i].curve
        end
        
        -- HUD
        love.graphics.setColor(1,1,1)
        love.graphics.print("LAP: "..lap, 20, 20, 0, 2, 2)
        love.graphics.print(math.floor(speed).." KM/H", width-150, height-50, 0, 2, 2)
    else
        love.graphics.printf("F1 RANDOM GP\nPRESS START/X TO RACE", 0, height/2, width, "center", 0, 2, 2)
    end
    
    -- Draw Car
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", width/2 - 20, height - 100, 40, 20)
end
