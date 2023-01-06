local function getItemsCount()
    local count = 0

    for i = 1, 16 do
        count = count + turtle.getItemCount(i)
    end

    return count
end

local function getItemsSpace()
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

local function dropAllItems(direction)
    local drop = nil

    if direction == "up" then
        drop = turtle.dropUp
    elseif direction == "down" then
        drop = turtle.dropDown
    else
        drop = turtle.drop
    end

    for i = 1, 16 do
        turtle.select(i)
        drop()
    end
end

local function suckAllItems(direction)
    local suck = nil

    if direction == "up" then
        suck = turtle.suckUp
    elseif direction == "down" then
        suck = turtle.suckDown
    else
        suck = turtle.suck
    end

    while suck() do end
end

local function farmSugarcane(length)
    for i = 1, length do
        turtle.dig()
        turtle.forward()
        turtle.digDown()
    end

    for i = 1, 2 do
        turtle.turnLeft()
        turtle.dig()
        turtle.forward()
        turtle.digDown()
    end

    for i = 1, length - 2 do
        turtle.dig()
        turtle.forward()
        turtle.digDown()
    end
end

local function returnHome()
    turtle.forward()
    turtle.turnLeft()

    while not turtle.detect() do
        turtle.forward()
    end

    turtle.turnRight()
    turtle.forward()
end

local function main()
    local sugarcaneFarmCount = 11
    local sugarcaneFarmLength = 30

    while true do
        if turtle.getFuelLevel() < turtle.getFuelLimit() then
            suckAllItems("down")
            refuelAll()
            dropAllItems("down")
        end

        turtle.forward()
        turtle.forward()
        turtle.forward()
        turtle.turnLeft()
        turtle.forward()
        turtle.turnRight()

        for i = 1, sugarcaneFarmCount do
            farmSugarcane(sugarcaneFarmLength)

            if i < sugarcaneFarmCount then
                if getItemsSpace() < sugarcaneFarmLength * 4 then
                    returnHome()
                    dropAllItems("down")

                    turtle.turnLeft()
                    turtle.turnLeft()
                    turtle.forward()
                    turtle.turnLeft()
                    turtle.forward()

                    for j = 1, i * 3 do
                        turtle.forward()
                    end
                else
                    turtle.forward()
                    turtle.turnRight()
                    turtle.forward()
                    turtle.forward()
                end

                turtle.turnRight()
            end
        end

        returnHome()
        dropAllItems("down")

        turtle.forward()
        turtle.forward()
        turtle.turnLeft()
        turtle.turnLeft()

        if getItemsCount() > 0 then
            return
        end

        -- 30 minutes
        sleep(1800)
    end
end

main()
