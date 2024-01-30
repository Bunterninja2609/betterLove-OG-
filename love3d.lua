FOV = 60;
love.graphics.volume = {}
love.graphics.volume.pointsList = {}
love.graphics.volume.resolution = 20
love.math.convert3dTo2d = function(x, y, z)
    x2 = (x - cam.position.x) * math.cos(cam.rotation.r1) + (z - cam.position.z) * math.sin(cam.rotation.r1)
    z2 = (x - cam.position.x) * -math.sin(cam.rotation.r1) + (z - cam.position.z) * math.cos(cam.rotation.r1)
    z3 = (y - cam.position.y) * math.sin(cam.rotation.r2) + (z2) *  math.cos(cam.rotation.r2)
    y2 = (y - cam.position.y) * math.cos(cam.rotation.r2) + (z2) * -math.sin(cam.rotation.r2)
    local angleRadians = (FOV / 180) * math.pi
    local result ={x2 / (z3 * math.tan(angleRadians/2))*(love.graphics:getWidth()/2), y2 / (z3 * math.tan(angleRadians/2))*(love.graphics:getWidth()/2)}
    local point = {distance = math.sqrt((x - cam.position.x)^2 + (y - cam.position.y)^2 + (z - cam.position.z)^2), nx = x, ny = y, nz = z, color = {love.graphics.getColor()}}
    local isExistent = false
    if #love.graphics.volume.pointsList == 0 then
        table.insert(love.graphics.volume.pointsList, point)
    else
        for i = 1, #love.graphics.volume.pointsList do
            if love.graphics.volume.pointsList[i].distance >= point.distance then
                table.insert(love.graphics.volume.pointsList, i, point)
                isExistent = true
                break
            end
        end
        if not isExistent then
            table.insert(love.graphics.volume.pointsList, point)
        end
    end
    
    return result
end
love.graphics.volume.setFov = function (deg)
    FOV = FOV - (FOV - deg)/2
end
love.graphics.volume.line = function(...)
    points = {...}
    local convertedPoints = {}
    for i = 1, #points, 6 do 
        local x1, y1, z1 = points[i], points[i + 1], points[i + 2]
        local x2, y2, z2 = points[i + 3], points[i + 4], points[i + 5]
        for i = 0, love.graphics.volume.resolution do
            love.math.convert3dTo2d(x1 + ((x2 - x1)/love.graphics.volume.resolution) * i, y1 + ((y2 - y1)/love.graphics.volume.resolution) * i, z1 + ((z2 - z1)/love.graphics.volume.resolution) * i)
        end
    end
end
love.graphics.volume.point = function(x, y, z, color)
    x2 = (x - cam.position.x) * math.cos(cam.rotation.r1) + (z - cam.position.z) * math.sin(cam.rotation.r1)
    z2 = (x - cam.position.x) * -math.sin(cam.rotation.r1) + (z - cam.position.z) * math.cos(cam.rotation.r1)
    z3 = (y - cam.position.y) * math.sin(cam.rotation.r2) + (z2) *  math.cos(cam.rotation.r2)
    y2 = (y - cam.position.y) * math.cos(cam.rotation.r2) + (z2) * -math.sin(cam.rotation.r2)
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

    for i = 1, #points, 3 do 
        local x1, y1, z1 = points[i], points[i + 1], points[i + 2]
        table.insert(convertedPoints, love.math.convert3dTo2d(x1, y1, z1))
    end
    
    local unpackedPoints = {}
    for _, point in ipairs(convertedPoints) do
        table.insert(unpackedPoints, point[1])
        table.insert(unpackedPoints, point[2])
    end

    if mode == "line" or mode == "fill" then
        love.graphics.volume.line(...)
    else
        love.graphics.draw(love.graphics.newSubdividedMesh(mode, unpackedPoints[1], unpackedPoints[2], unpackedPoints[3], unpackedPoints[4], unpackedPoints[5], unpackedPoints[6], unpackedPoints[7], unpackedPoints[8], 1))
    end
end
love.graphics.volume.initialize = function()
    love.graphics.volume.pointsList = {}
    love.graphics.translate(love.graphics:getWidth()/2, love.graphics:getHeight()/2)
end
love.graphics.volume.terminate = function()
    for i, point in ipairs(love.graphics.volume.pointsList) do
        love.graphics.volume.point(point.nx, point.ny, point.nz, point.color)
    end
end

cam = {}
cam.position = {x = 0, y = 0, z = 0}
cam.rotation = {r1 = 0, r2 = 0}

