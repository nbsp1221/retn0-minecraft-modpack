local args = { ... }
local selectedSlot = 1

local function placeItem(direction)
    while turtle.getItemCount() == 0 do
        if selectedSlot == 16 then
            return false
        end

        selectedSlot = selectedSlot + 1
        turtle.select(selectedSlot)
    end

    if direction == "up" then
        turtle.placeUp()
    elseif direction == "down" then
        turtle.placeDown()
    else
        turtle.place()
    end

    return true
end

local function fillRectangle()
    while not turtle.detect() do
        turtle.forward()
    end

    turtle.turnLeft()

    while not turtle.detect() do
        turtle.forward()
    end

    local turnCount = 0

    while turnCount < 4 do
        while turtle.back() do
            turnCount = 0

            if not placeItem() then
                return false
            end
        end

        turtle.turnRight()
        turnCount = turnCount + 1
    end

    turtle.up()
    placeItem("down")

    return true
end

local function main()
    if args[1] == nil then
        print("Usage: fillRectangle <height>")
        return
    end

    local height = tonumber(args[1])

    if height < 1 then
        print("Height must be greater than 0")
        return
    end

    turtle.select(selectedSlot)

    while height > 0 do
        if not fillRectangle() then
            return
        end

        height = height - 1
    end
end

main()
