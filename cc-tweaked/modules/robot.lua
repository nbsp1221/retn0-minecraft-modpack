local utils = require('utils')

--- @param name string
--- @param direction string
--- @return function
local function _getFunction(name, direction)
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

local function refuelAll()
    for i = 1, 16 do
        turtle.select(i)
        turtle.refuel()
    end
end

--- @param direction string
--- @param count number | nil
--- @return boolean
local function suck(direction, count)
    return _getFunction('suck', direction)(count)
end

--- @param direction string
local function suckAll(direction)
    while suck(direction) do end
end

--- @param direction string
--- @param count number | nil
--- @return boolean
local function drop(direction, count)
    return _getFunction('drop', direction)(count)
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
        if not _getFunction('go', direction)() then
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
        if not _getFunction('turn', direction)() then
            return false
        end
    end

    return true
end

--- @param direction string
--- @return boolean
local function dig(direction)
    return _getFunction('dig', direction)()
end

--- @param direction string
--- @param name string
--- @return boolean
local function digByName(direction, name)
    local success, data = _getFunction('inspect', direction)()

    if not success then
        return false
    end

    if data.name ~= name then
        error('unexpected block: ' .. data.name .. ' (expected: ' .. name ..')')
    end

    return dig(direction)
end

--- @param direction string
--- @param distance number
local function digLine(direction, distance)
    for i = 1, distance do
        dig(direction)
        go(direction)
    end
end

--- @param x number
--- @param y number
--- @param options table | nil
local function digToXY(x, y, options)
    options = options or {}

    if x == 0 and y == 0 then
        return
    end

    if x == 0 then
        if y < 0 then
            turn('back')
        end
    else
        turn(utils.fif(x > 0, 'right', 'left'))
    end

    local readyNextLine = function (direction)
        turn(direction)
        digLine('front', 1)
        turn(direction)
    end

    if x == 0 or y == 0 then
        digLine('front', math.max(math.abs(x), math.abs(y)))
    else
        for i = 0, math.abs(y) do
            digLine('front', math.abs(x))

            if i < math.abs(y) then
                if x * y > 0 then
                    readyNextLine(utils.fif(i % 2 == 0, 'left', 'right'))
                else
                    readyNextLine(utils.fif(i % 2 == 0, 'right', 'left'))
                end
            end
        end
    end

    if options.keepFirst then
        if x == 0 or y == 0 then
            turn('back')
            go('front', math.max(math.abs(x), math.abs(y)))
        else
            if math.abs(y) % 2 == 0 then
                turn('back')
                go('front', math.abs(x))
            end

            turn(utils.fif(x * y > 0, 'left', 'right'))
            go('front', math.abs(y))
        end

        if y >= 0 then
            turn(utils.fif(y > 0, 'back', utils.fif(x > 0, 'right', 'left')))
        end
    end
end

return {
    getAllItemsCount = getAllItemsCount,
    getAllItemsSpace = getAllItemsSpace,
    refuelAll = refuelAll,
    suck = suck,
    suckAll = suckAll,
    drop = drop,
    dropAll = dropAll,
    go = go,
    goContinuously = goContinuously,
    turn = turn,
    dig = dig,
    digByName = digByName,
    digLine = digLine,
    digToXY = digToXY,
}
