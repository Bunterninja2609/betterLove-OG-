-- Wrapper for arrays
local Vector = {}

-- Function to add two arrays element-wise
function Array.__add(vector1, vector2)
    local result = {}
    for i = 1, math.min(#array1, #array2) do
        table.insert(result, vector1[i] + vector2[i])
    end
    return setmetatable(result, Vector)
end

-- Function to create arrays with the metatable
local function newVector(...)
    local vector = {...}
    return setmetatable(vector, Vector)
end

return {
  newVector = newVector
  Vector = Vector
}
