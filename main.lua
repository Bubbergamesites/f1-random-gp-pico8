-- F1 Random GP - Fixed for R36S
function love.load()
    -- Set resolution (R36S standard)
    width, height = love.graphics.getDimensions()
    
    -- Game Variables
    gameState = "title"
    playerX = 0
    playerZ = 0
    speed = 0
    lap = 1
    
    track = {}
    -- Build a simple track
    for i=1, 2000 do
        local curve = 0
        if i > 200 then curve = math.sin(i/50) * 2 end
        table.insert(track, {
            curve = curve,
            color = (math.floor(i/4)%2 == 0) and {0.2, 0.2, 0.2} or {0.25, 0.25, 0.25}
        })
    end
end

function love.update(dt)
    if gameState == "title" then
        -- R36S "A" or "Start" buttons usually map to 'z', 'x', or 'return'
        if love.keyboard.isDown("x", "z", "return") then gameState = "racing" end
        return
    end

    -- Acceleration/Braking
    if love.keyboard.isDown("up") then speed = math.min(speed + 500 * dt, 800)
    elseif love.keyboard.isDown("down") then speed = math.max(speed - 700 * dt, 0)
    else speed = speed * 0.98 end

    -- Steering
    if love.keyboard.isDown("left") then playerX = playerX - 1.5 * dt
    elseif love.keyboard.isDown("right") then playerX = playerX + 1.5 * dt end

    -- Move car
    playerZ = playerZ + speed * dt
    
    -- Auto-center steering slightly
    playerX = playerX * 0.99
end

function love.draw()
    -- Grass
    love.graphics.clear(0.1, 0.5, 0.1)
    
    -- Simple Road Rendering
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.polygon("fill", width*0.1, height, width*0.9, height, width*0.55, height*0.4, width*0.45, height*0.4)
    
    -- Car
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", width/2 + (playerX * 100) - 20, height - 80, 40, 20)
    
    -- HUD
    love.graphics.setColor(1, 1, 1)
    if gameState == "title" then
        love.graphics.printf("F1 RANDOM GP\nPRESS A TO START", 0, height/2, width, "center")
    else
        love.graphics.print("SPEED: "..math.floor(speed), 10, 10)
    end
end
