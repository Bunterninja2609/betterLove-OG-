love.graphics.newSubdividedMesh = function(texture, x1, y1, x2, y2, x3, y3, x4, y4, subdivisions)
    if not subdivisions then
        subdivisions = 1
    end
    if not x4 then
        x4 = x1
        y4 = y1
    end
    local vertices = {}
    for i = 0, subdivisions do
        local vertice = {x1 + i*((x2 - x1)/subdivisions), y1 + i*((y2 - y1)/subdivisions), i*(1/subdivisions), 0}
        table.insert(vertices, vertice)
    end
    for i = 0, subdivisions do
        local vertice = {x2 + i*((x3 - x2)/subdivisions), y2 + i*((y3 - y2)/subdivisions), 1, i*(1/subdivisions)}
        table.insert(vertices, vertice)
    end
    for i = 0, subdivisions do
        local vertice = {x3 + i*((x4 - x3)/subdivisions), y3 + i*((y4 - y3)/subdivisions), 1 - i*(1/subdivisions), 1}
        table.insert(vertices, vertice)
    end
    for i = 0, subdivisions do
        
    end
    local mesh = love.graphics.newMesh(vertices, "fan", "dynamic")
    
    mesh:setTexture(texture)
    return mesh
end

