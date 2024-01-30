FOV = 60;
love.graphics.volume = {}
love.graphics.volume.pointsList = {}
love.graphics.volume.resolution = 20
love.math.convert3dTo2d = function(x, y, z)
    local x2 = (x - cam.position.x) * math.cos(cam.rotation.r1) + (z - cam.position.z) * math.sin(cam.rotation.r1)
    local z2 = (x - cam.position.x) * -math.sin(cam.rotation.r1) + (z - cam.position.z) * math.cos(cam.rotation.r1)
    local z3 = (y - cam.position.y) * math.sin(cam.rotation.r2) + (z2) *  math.cos(cam.rotation.r2)
    local y2 = (y - cam.position.y) * math.cos(cam.rotation.r2) + (z2) * -math.sin(cam.rotation.r2)
    local angleRadians = (FOV / 180) * math.pi
    local result ={x2 / (z3 * math.tan(angleRadians/2))*(love.graphics:getWidth()/2), y2 / (z3 * math.tan(angleRadians/2))*(love.graphics:getWidth()/2)}
    return result
end
love.graphics.volume.setFov = function (deg)
    FOV = FOV - (FOV - deg)/2
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
love.graphics.volume.point = function(x, y, z, color)
    local x2 = (x - cam.position.x) * math.cos(cam.rotation.r1) + (z - cam.position.z) * math.sin(cam.rotation.r1)
    local z2 = (x - cam.position.x) * -math.sin(cam.rotation.r1) + (z - cam.position.z) * math.cos(cam.rotation.r1)
    local z3 = (y - cam.position.y) * math.sin(cam.rotation.r2) + (z2) *  math.cos(cam.rotation.r2)
    local y2 = (y - cam.position.y) * math.cos(cam.rotation.r2) + (z2) * -math.sin(cam.rotation.r2)
    local angleRadians = (FOV / 180) * math.pi
    local result ={x2 / (z3 * math.tan(angleRadians/2))*(love.graphics:getWidth()/2), y2 / (z3 * math.tan(angleRadians/2))*(love.graphics:getWidth()/2)}
    love.graphics.setColor(color)
    if z3 >= 0 then
        love.graphics.points(result)
    end
end
love.graphics.volume.cuboid = function(mode, x, y, z, width, height, depth)
    love.graphics.volume.plane(mode, x, y, z, x + width, y, z, x + width, y + height, z, x, y + height, z)
    love.graphics.volume.plane(mode, x, y, z + depth, x + width, y, z + depth, x + width, y + height, z + depth, x, y + height, z + depth)
    love.graphics.volume.plane(mode, x, y, z, x, y, z + depth, x + width, y, z + depth, x + width, y, z )
    love.graphics.volume.plane(mode, x, y + width, z, x, y + width, z + depth, x + width, y + width, z + depth, x + width, y + width, z )
    love.graphics.volume.plane(mode, x + width, y, z, x + width, y, z + depth,   x + width, y + height, z + depth, x + width, y + height, z)
    love.graphics.volume.plane(mode, x, y, z, x, y, z + depth,   x, y + height, z + depth, x, y + height, z)
end
love.graphics.volume.plane = function (mode, ...)
    points = {...}
    local convertedPoints = {}
    local usedPoints = {}
    local plane = {
        closestDistance = 2^128,
        averageDistance = 2^128,
        usedPoints = {},
        mode = mode,
        color = {love.graphics.getColor()}
    }
    local averageDistanceCollectionVariable = 0
    for i = 1, #points, 3 do 
        local x1, y1, z1 = points[i], points[i + 1], points[i + 2]
        if love.math.get3dDistance(x1, y1, z1) > 0 then
            table.insert(usedPoints, love.math.convert3dTo2d(x1, y1, z1))
            if love.math.get3dDistance(x1, y1, z1) < plane.closestDistance then
                plane.closestDistance = love.math.get3dDistance(x1, y1, z1)
            end
            averageDistanceCollectionVariable = averageDistanceCollectionVariable + love.math.get3dDistance(x1, y1, z1)
        end
    end
    plane.averageDistance = averageDistanceCollectionVariable / #points
    for _, point in ipairs(usedPoints) do
        table.insert(plane.usedPoints, point[1])
        table.insert(plane.usedPoints, point[2])
    end
    
    if #plane.usedPoints > 6 then
        if #love.graphics.volume.pointsList > 0 then
            local t = false
            for i, otherPlanes in ipairs(love.graphics.volume.pointsList) do
                if otherPlanes.closestDistance < plane.closestDistance then
                    table.insert(love.graphics.volume.pointsList, i, plane)
                    t = true
                    break
                elseif otherPlanes.averageDistance < plane.averageDistance then
                    table.insert(love.graphics.volume.pointsList, i, plane)
                    t = true
                    break
                end
            end
            if not t then
                table.insert(love.graphics.volume.pointsList, plane)
            end
        else
            table.insert(love.graphics.volume.pointsList, plane)
        end
    end
end
love.graphics.volume.initialize = function()
    love.graphics.volume.pointsList = {}
    love.graphics.translate(love.graphics:getWidth()/2, love.graphics:getHeight()/2)
end
love.graphics.volume.terminate = function()
    for i, plane in ipairs(love.graphics.volume.pointsList) do 
        love.graphics.setColor(plane.color)  
        if plane.mode == "fill" or plane.mode == "line" then
            love.graphics.polygon(plane.mode, plane.usedPoints)
        else
            love.graphics.draw(love.graphics.newSubdividedMesh(plane.mode, plane.usedPoints[1], plane.usedPoints[2],  plane.usedPoints[3], plane.usedPoints[4], plane.usedPoints[5], plane.usedPoints[6], plane.usedPoints[7], plane.usedPoints[8], 100), 0, 0)
        end
    end
    love.graphics.setColor(1, 1, 1)
end
love.math.get3dDistance = function(x1, y1, z1, x2, y2, z2)
    if not x2 then
        local x2 = (x1 - cam.position.x) * math.cos(cam.rotation.r1) + (z1 - cam.position.z) * math.sin(cam.rotation.r1)
        local z2 = (x1 - cam.position.x) * -math.sin(cam.rotation.r1) + (z1 - cam.position.z) * math.cos(cam.rotation.r1)
        local z3 = (y1 - cam.position.y) * math.sin(cam.rotation.r2) + (z2) *  math.cos(cam.rotation.r2)
        local y2 = (y1 - cam.position.y) * math.cos(cam.rotation.r2) + (z2) * -math.sin(cam.rotation.r2)
        return z3
    end
end

cam = {}
cam.position = {x = 0, y = 0, z = 0}
cam.rotation = {r1 = 0, r2 = 0}

