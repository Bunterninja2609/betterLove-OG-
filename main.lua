--[[
    This file provides basic example functions needed to develop a 3d game using the following librarys:
    - betterMesh
    - love3d
    - betterMath
    these Librarys together form the "betterLove" library and are dependend on the love2d framework.
]]--

require("love3d")
require("betterMesh")
function love.load()
    love.graphics.volume.setFov(60)
    love.window.setFullscreen(true)
    love.mouse.setGrabbed(true)
    love.mouse.setVisible(false)
    
    img = love.graphics.newImage("test.png")
    suzanne = love.graphics.volume.newObj("suzanne.obj", "fill")
    FPS = 0
    tick = 0
    gDt = 0

    
            -- setting the color works the exact same as in normal love
            love.graphics.setColor(1, 1, 0)
            --adding a lightSource with the parameters x, y, z, strength
            love.graphics.volume.addLightSource(200*math.cos(tick), -20, 200*math.sin(tick), 150)
            --visualizing the light Source with a sphere (mode, x, y, z, radius)
            love.graphics.volume.sphere("line", 200*math.cos(tick), -20, 200*math.sin(tick), 10)
            love.graphics.setColor(1, 1, 1)
            
            ---[[
            for i = -10, 9 do
                for j = -10, 9 do
                    love.graphics.volume.cuboid("fill",20*i, 0, 20*j, 20, 20, 20)
                end
            end
            love.graphics.volume.cuboid(img, math.cos(tick)*20, -30, 20, 10, 10, 10)
            --]]
            
            love.graphics.setColor(1, 1, 1)
            love.graphics.volume.draw("fill", suzanne, 0, -100, -300, 100)
            love.graphics.setColor(1, 1, 1)
            --terminate ends the 3d view and renders everything
end
function love.update(dt)
    gDt = dt
    tick = tick + dt
    FPS = FPS - math.floor((FPS - 1/dt)/2)
    if love.keyboard.isDown("d")then
        cam.position.z = cam.position.z + dt * 20 * math.sin(cam.rotation.r1)
        cam.position.x = cam.position.x + dt * 20 * math.cos(cam.rotation.r1)
    end
    if love.keyboard.isDown("a")then
        cam.position.z = cam.position.z - dt * 20 * math.sin(cam.rotation.r1)
        cam.position.x = cam.position.x - dt * 20 * math.cos(cam.rotation.r1)
    end
    if love.keyboard.isDown("w")then
        cam.position.z = cam.position.z + dt * 20 * math.sin(cam.rotation.r1 + math.pi/2)
        cam.position.x = cam.position.x + dt * 20 * math.cos(cam.rotation.r1 + math.pi/2)
    end
    if love.keyboard.isDown("s")then
        cam.position.z = cam.position.z - dt * 20 * math.sin(cam.rotation.r1 + math.pi/2)
        cam.position.x = cam.position.x - dt * 20 * math.cos(cam.rotation.r1 + math.pi/2)
    end
    if love.keyboard.isDown("space")then
        cam.position.y = cam.position.y - dt * 20
    end
    if love.keyboard.isDown("lctrl")then
        cam.position.y = cam.position.y + dt * 20
    end
    if love.keyboard.isDown("left")then
        cam.rotation.r1 = cam.rotation.r1 + 0.01
    end
    if love.keyboard.isDown("right")then
        cam.rotation.r1 = cam.rotation.r1 - 0.01
    end
    if love.keyboard.isDown("up")then
        cam.rotation.r2 = cam.rotation.r2 - 0.01
    end
    if love.keyboard.isDown("down")then
        cam.rotation.r2 = cam.rotation.r2 + 0.01
    end
end
function love.mousemoved(x, y, dx, dy)
    if love.mouse.isDown(2) then
        love.graphics.volume.setFov(40)
        cam.rotation.r2 = cam.rotation.r2 + gDt*dy/400
        cam.rotation.r1 = cam.rotation.r1 - gDt*dx/400
    else 
        love.graphics.volume.setFov(60)
        cam.rotation.r2 = cam.rotation.r2 + gDt*dy/100
        cam.rotation.r1 = cam.rotation.r1 - gDt*dx/100
    end
    if cam.rotation.r2 > math.pi/2 then
        cam.rotation.r2 = math.pi/2
    elseif cam.rotation.r2 < -math.pi/2 then
        cam.rotation.r2 = -math.pi/2
    end
    love.mouse.setPosition(love.graphics:getWidth()/2, love.graphics:getHeight()/2)
end
function love.draw()
    love.graphics.push()
    love.graphics.setBackgroundColor(0.5, 0.8, 1)
        love.graphics.volume.initialize()

            love.graphics.volume.terminate()
    love.graphics.pop()
    -- place for GUI
    love.graphics.points(love.mouse.getX(), love.mouse.getY())
    love.graphics.print(FPS.." fps",0,0)
end