love.graphics.volume = {}
love.graphics.volume.fov = 60;
love.graphics.volume.renderDistance = 2^128;
love.graphics.volume.buffer = 2^256;
love.graphics.volume.planeList = {}
love.graphics.volume.resolution = 20
love.graphics.volume.lightSources = {}
love.graphics.volume.savedShapes = {}
love.math.convert3dTo2d = function(x, y, z)
    local x2 = (x - cam.position.x) * math.cos(cam.rotation.r1) + (z - cam.position.z) * math.sin(cam.rotation.r1)
    local z2 = (x - cam.position.x) * -math.sin(cam.rotation.r1) + (z - cam.position.z) * math.cos(cam.rotation.r1)
    local z3 = (y - cam.position.y) * math.sin(cam.rotation.r2) + (z2) *  math.cos(cam.rotation.r2)
    local y2 = (y - cam.position.y) * math.cos(cam.rotation.r2) + (z2) * -math.sin(cam.rotation.r2)
    local angleRadians = (love.graphics.volume.fov / 180) * math.pi
    local result ={x2 / (z3 * math.tan(angleRadians/2))*(love.graphics:getWidth()/2), y2 / (z3 * math.tan(angleRadians/2))*(love.graphics:getWidth()/2)}
    if z3 < 0 then
        return nil
    else
        return result
    end
end
love.graphics.volume.setFov = function (deg)
    love.graphics.volume.fov = love.graphics.volume.fov - (love.graphics.volume.fov - deg)/2
end
love.graphics.volume.draw = function(mode, object, x, y, z, scale)
    for i, face in ipairs(object[2]) do
        local points = {}
        for j, info in ipairs(face) do
            table.insert(points, object[1][info].x * scale + x)
            table.insert(points, object[1][info].y * scale + y)
            table.insert(points, object[1][info].z * scale + z)
        end
        love.graphics.volume.plane(mode, points)
    end
end
love.graphics.volume.line = function(...)
    points = {...}
    local convertedPoints = {}
    for i = 1, #points, 3 do 
        local x1, y1, z1 = points[i], points[i + 1], points[i + 2]
        table.insert(convertedPoints, love.math.convert3dTo2d(x1, y1, z1))
    end
    local unpackedPoints = {}
    for _, point in ipairs(convertedPoints) do
        table.insert(unpackedPoints, point[1])
        table.insert(unpackedPoints, point[2])
    end
        love.graphics.line(unpackedPoints)
end
love.graphics.volume.cuboid = function(mode, x, y, z, width, height, depth)
    love.graphics.volume.plane(mode, x, y, z, x + width, y, z, x + width, y + height, z, x, y + height, z)
    love.graphics.volume.plane(mode, x, y, z + depth, x + width, y, z + depth, x + width, y + height, z + depth, x, y + height, z + depth)
    love.graphics.volume.plane(mode, x, y, z, x, y, z + depth, x + width, y, z + depth, x + width, y, z)
    love.graphics.volume.plane(mode, x, y + width, z, x, y + width, z + depth, x + width, y + width, z + depth, x + width, y + width, z)
    love.graphics.volume.plane(mode, x + width, y, z, x + width, y, z + depth, x + width, y + height, z + depth, x + width, y + height, z)
    love.graphics.volume.plane(mode, x, y, z, x, y, z + depth,   x, y + height, z + depth, x, y + height, z)
end
love.graphics.volume.sphere = function(mode, x, y, z, radius)
    love.graphics.volume.draw(mode, love.graphics.volume.savedShapes.sphere, x, y, z, radius)
end
love.graphics.volume.plane = function (mode, ...)
    local plane = {
        mode = mode,
        color = {love.graphics.getColor()}
    }
    if type(...) == "table" then
        plane.points = ...
    else 
        plane.points = {...}
    end
    if #plane.points >= 9 then
        table.insert(love.graphics.volume.planeList, plane)
    end
end
love.graphics.volume.initialize = function()
    love.graphics.volume.lightSources = {}
    love.graphics.translate(love.graphics:getWidth()/2, love.graphics:getHeight()/2)
end
love.graphics.volume.terminate = function()
    local queue = {}
    for i, plane in ipairs(love.graphics.volume.planeList) do
        local points = {}
        for i = 1, #plane.points, 3 do
            if love.math.convert3dTo2d(plane.points[i], plane.points[i+1], plane.points[i+2]) then
                table.insert(points, love.math.convert3dTo2d(plane.points[i], plane.points[i+1], plane.points[i+2])[1])
                table.insert(points, love.math.convert3dTo2d(plane.points[i], plane.points[i+1], plane.points[i+2])[2])
            end
        end
        if #points >= 6 then
            table.insert(queue, points)
        end
    end
    for i, points in ipairs(queue) do
        love.graphics.polygon("fill", points)
    end
    love.graphics.setColor(1, 1, 0)
    --[[
    for _, lightSource in ipairs(love.graphics.volume.lightSources) do
        love.graphics.circle("fill", love.math.convert3dTo2d(lightSource.x, lightSource.y, lightSource.z)[1], love.math.convert3dTo2d(lightSource.x, lightSource.y, lightSource.z)[2], 10)
    end
    love.graphics.setColor(1, 1, 1)
    --]]
end
love.graphics.volume.addLightSource = function(x, y, z, strength)
    local lightSource = {x = x, y = y, z = z, strength = strength}
    table.insert(love.graphics.volume.lightSources, lightSource)
end
love.math.get3dDistance = function(x1, y1, z1, x2, y2, z2)
    if not x2 then
        local x2 = (x1 - cam.position.x) * math.cos(cam.rotation.r1) + (z1 - cam.position.z) * math.sin(cam.rotation.r1)
        local z2 = (x1 - cam.position.x) * -math.sin(cam.rotation.r1) + (z1 - cam.position.z) * math.cos(cam.rotation.r1)
        local z3 = (y1 - cam.position.y) * math.sin(cam.rotation.r2) + (z2) *  math.cos(cam.rotation.r2)
        local y2 = (y1 - cam.position.y) * math.cos(cam.rotation.r2) + (z2) * -math.sin(cam.rotation.r2)
        return z3
    else
        return math.sqrt((x2-x1)^2+(y2-y1)^2+(z2-z1)^2)
    end
end
love.graphics.volume.newObj = function(file, mode)
    if string.lower(string.match(file, "%.obj$")) ~= nil then
        local vertices = {}
        local faces = {}
        for line in love.filesystem.lines(file) do
            local words = {}
            for word in line:gmatch("%S+") do
                table.insert(words, word)
            end
            if #words > 0 then
                if words[1] == 'v' then
                    local vertice = {}
                    vertice.x, vertice.y, vertice.z = tonumber(words[2]), -tonumber(words[3]), tonumber(words[4])
                    table.insert(vertices, vertice)
                elseif words[1] == 'f' then
                    local face = {}
                    for i = 2, #words do
                        local info = {}
                        for information in words[i]:gmatch("[^/]+") do
                            table.insert(info, information)
                        end
                        table.insert(face, tonumber(info[1]))
                    end
                    table.insert(faces, face)
                end
            end
        end
        return {vertices, faces, mode}
    else
        error("Invalid file format. please provide a .obj file")
    end
end
love.graphics.volume.savedShapes.sphere = love.graphics.volume.newObj("sphere.obj", "fill")

cam = {}
cam.position = {x = 0, y = 0, z = 0}
cam.rotation = {r1 = 0, r2 = 0}