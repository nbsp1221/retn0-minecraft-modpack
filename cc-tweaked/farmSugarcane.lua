local function getInventorySpace()
    local space = 0

    for i = 1, 16 do
        space = space + turtle.getItemSpace(i)
    end

    return space
end

local function dropAllItems(direction)
    for i = 1, 16 do
        turtle.select(i)

        if direction == "up" then
            turtle.dropUp()
        elseif direction == "down" then
            turtle.dropDown()
        else
            turtle.drop()
        end
    end
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

local function main()
    local sugarcaneFarmCount = 11
    local sugarcaneFarmLength = 30

    while true do
        for i = 1, sugarcaneFarmCount do
            turtle.select(1)
            farmSugarcane(sugarcaneFarmLength)

            if getInventorySpace() < sugarcaneFarmLength * 4 or i == sugarcaneFarmCount then
                turtle.forward()
                turtle.turnLeft()

                while not turtle.detect() do
                    turtle.forward()
                end

                turtle.turnRight()
                turtle.forward()
                turtle.forward()

                dropAllItems("down")

                turtle.turnLeft()
                turtle.turnLeft()
                turtle.forward()
                turtle.forward()
                turtle.turnLeft()
                turtle.forward()

                if i ~= sugarcaneFarmCount then
                    for j = 1, i * 3 do
                        turtle.forward()
                    end
                end
            else
                turtle.forward()
                turtle.turnRight()
                turtle.forward()
                turtle.forward()
            end

            turtle.turnRight()
        end

        sleep(1200)
    end
end

main()
