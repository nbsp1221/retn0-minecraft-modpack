--- @param name string
--- @param direction string
--- @return function
local function _getFunctionByName(name, direction)
    local fn = nil

    if name == 'go' then
        if direction == 'front' then
            fn = turtle.forward
        elseif direction == 'back' then
            fn = turtle.back
        elseif direction == 'up' then
            fn = turtle.up
        elseif direction == 'down' then
            fn = turtle.down
        else
            error('invalid direction: ' .. direction)
        end
    else
        if direction == 'front' then
            fn = turtle[name]
        else
            fn = turtle[name .. direction:gsub('^%l', string.upper)]
        end
    end

    if not fn then
        if not turtle[name] then
            error('invalid name: ' .. name)
        else
            error('invalid direction: ' .. direction)
        end
    end

    return fn
end

--- @return number
local function getAllItemsCount()
    local count = 0

    for i = 1, 16 do
        count = count + turtle.getItemCount(i)
    end

    return count
end

--- @return number
local function getAllItemsSpace()
    local space = 0

    for i = 1, 16 do
        space = space + turtle.getItemSpace(i)
    end

    return space
end

local function refuel()
    for i = 1, 16 do
        turtle.select(i)
        turtle.refuel()
    end
end

--- @param direction string
--- @return boolean
local function suck(direction)
    return _getFunctionByName('suck', direction)()
end

--- @param direction string
local function suckAll(direction)
    while suck(direction) do end
end

--- @param direction string
--- @return boolean
local function drop(direction)
    return _getFunctionByName('drop', direction)()
end

--- @param direction string
local function dropAll(direction)
    for i = 1, 16 do
        turtle.select(i)
        drop(direction)
    end
end

--- @param direction string
--- @param distance number | nil
--- @return boolean
local function go(direction, distance)
    distance = distance or 1

    for i = 1, distance do
        if not _getFunctionByName('go', direction)() then
            return false
        end
    end

    return true
end

--- @param direction string
local function goContinuously(direction)
    while go(direction) do end
end

--- @param direction string
--- @param turns number | nil
--- @return boolean
local function turn(direction, turns)
    turns = turns or 1

    if direction == 'back' then
        direction = 'left'
        turns = turns * 2
    end

    for i = 1, turns do
        if not _getFunctionByName('turn', direction)() then
            return false
        end
    end

    return true
end

--- @param direction string
--- @return boolean
local function dig(direction)
    return _getFunctionByName('dig', direction)()
end

--- @param direction string
--- @param name string
--- @return boolean
local function safeDig(direction, name)
    local isExists, data = _getFunctionByName('inspect', direction)()

    if not isExists then
        return false
    end

    if data.name ~= name then
        error('unexpected block: ' .. data.name .. ' (expected: ' .. name ..')')
    end

    return dig(direction)
end

return {
    getAllItemsCount = getAllItemsCount,
    getAllItemsSpace = getAllItemsSpace,
    refuel = refuel,
    suck = suck,
    suckAll = suckAll,
    drop = drop,
    dropAll = dropAll,
    go = go,
    goContinuously = goContinuously,
    turn = turn,
    dig = dig,
    safeDig = safeDig,
}
