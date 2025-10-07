Robot = {}

function Robot:new(options)
    local instance = setmetatable({}, { __index = self })

    options = options or {}

    instance.x = 0
    instance.y = 0
    instance.z = 0
    instance.facing = 0

    return instance
end

--- @param turns number | nil
function Robot:turnLeft(turns)
    turns = turns or 1

    for i = 1, turns do
        turtle.turnLeft()
        self.facing = (self.facing - 1) % 4
    end
end

--- @param turns number | nil
function Robot:turnRight(turns)
    turns = turns or 1

    for i = 1, turns do
        turtle.turnRight()
        self.facing = (self.facing + 1) % 4
    end
end

function Robot:turnBack()
    self:turnRight(2)
end

--- @param facing number
function Robot:turnTo(facing)
    local turns = facing - self.facing

    if turns == 3 then
        turns = -1
    elseif turns == -3 then
        turns = 1
    end

    if turns > 0 then
        self:turnRight(turns)
    elseif turns < 0 then
        self:turnLeft(-turns)
    end
end

--- @param distance number | nil
--- @param destroyObstacle boolean | nil
--- @return boolean
function Robot:goFront(distance, destroyObstacle)
    distance = distance or 1
    destroyObstacle = destroyObstacle or false

    for i = 1, distance do
        while not turtle.forward() do
            if destroyObstacle then
                turtle.dig()
            else
                return false
            end
        end

        if self.facing == 0 then
            self.y = self.y + 1
        elseif self.facing == 1 then
            self.x = self.x + 1
        elseif self.facing == 2 then
            self.y = self.y - 1
        elseif self.facing == 3 then
            self.x = self.x - 1
        end
    end

    return true
end

--- @param distance number | nil
--- @param destroyObstacle boolean | nil
--- @return boolean
function Robot:goBack(distance, destroyObstacle)
    distance = distance or 1
    destroyObstacle = destroyObstacle or false

    for i = 1, distance do
        while not turtle.back() do
            if destroyObstacle then
                self:turnBack()

                while turtle.detect() do
                    turtle.dig()
                end

                self:turnBack()
            else
                return false
            end
        end

        if self.facing == 0 then
            self.y = self.y - 1
        elseif self.facing == 1 then
            self.x = self.x - 1
        elseif self.facing == 2 then
            self.y = self.y + 1
        elseif self.facing == 3 then
            self.x = self.x + 1
        end
    end

    return true
end

--- @param distance number | nil
--- @param destroyObstacle boolean | nil
--- @return boolean
function Robot:goUp(distance, destroyObstacle)
    distance = distance or 1
    destroyObstacle = destroyObstacle or false

    for i = 1, distance do
        while not turtle.up() do
            if destroyObstacle then
                turtle.digUp()
            else
                return false
            end
        end

        self.z = self.z + 1
    end

    return true
end

--- @param distance number | nil
--- @param destroyObstacle boolean | nil
--- @return boolean
function Robot:goDown(distance, destroyObstacle)
    distance = distance or 1
    destroyObstacle = destroyObstacle or false

    for i = 1, distance do
        while not turtle.down() do
            if destroyObstacle then
                turtle.digDown()
            else
                return false
            end
        end

        self.z = self.z - 1
    end

    return true
end

--- @param x number
--- @param y number
--- @param z number
--- @param facing number | nil
--- @param destroyObstacle boolean | nil
--- @return boolean
function Robot:goToXYZ(x, y, z, facing, destroyObstacle)
    local dx = x - self.x
    local dy = y - self.y
    local dz = z - self.z

    if dx ~= 0 then
        if dx > 0 then
            self:turnTo(1)
        else
            self:turnTo(3)
        end

        if not self:goFront(math.abs(dx), destroyObstacle) then
            return false
        end
    end

    if dy ~= 0 then
        if dy > 0 then
            self:turnTo(0)
        else
            self:turnTo(2)
        end

        if not self:goFront(math.abs(dy), destroyObstacle) then
            return false
        end
    end

    if dz ~= 0 then
        if dz > 0 then
            if not self:goUp(math.abs(dz), destroyObstacle) then
                return false
            end
        else
            if not self:goDown(math.abs(dz), destroyObstacle) then
                return false
            end
        end
    end

    if facing then
        self:turnTo(facing)
    end

    return true
end

--- @param x number
--- @param y number
--- @param z number
function Robot:digToXYZ(x, y, z)
    local minX, maxX = math.min(x, self.x), math.max(x, self.x)
    local minY, maxY = math.min(y, self.y), math.max(y, self.y)
    local minZ, maxZ = math.min(z, self.z), math.max(z, self.z)

    for currentX = minX, maxX do
        for currentY = minY, maxY do
            for currentZ = minZ, maxZ do
                self:goToXYZ(currentX, currentY, currentZ, nil, true)
            end
        end
    end
end

--- @param x number
--- @param y number
--- @param z number
function Robot:digCuboidFace(x, y, z)
    local minX, maxX = math.min(x, self.x), math.max(x, self.x)
    local minY, maxY = math.min(y, self.y), math.max(y, self.y)
    local minZ, maxZ = math.min(z, self.z), math.max(z, self.z)

    -- top
    self:goToXYZ(minX, minY, maxZ, nil, true)
    self:digToXYZ(maxX, maxY, maxZ)

    -- back
    self:goToXYZ(maxX, maxY, maxZ, nil, true)
    self:digToXYZ(minX, maxY, minZ)

    -- left
    self:goToXYZ(minX, maxY, minZ, nil, true)
    self:digToXYZ(minX, minY, maxZ)

    -- front
    self:goToXYZ(minX, minY, maxZ, nil, true)
    self:digToXYZ(maxX, minY, minZ)

    -- right
    self:goToXYZ(maxX, minY, minZ, nil, true)
    self:digToXYZ(maxX, maxY, maxZ)

    -- bottom
    self:goToXYZ(maxX, maxY, minZ, nil, true)
    self:digToXYZ(minX, minY, minZ)
end

--- @param name string | nil
function Robot:placeFront(name)
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)

        if item and (not name or name == item.name) then
            turtle.select(i)
            turtle.place()

            return
        end
    end

    error('no items to place')
end

--- @param name string | nil
function Robot:placeUp(name)
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)

        if item and (not name or name == item.name) then
            turtle.select(i)
            turtle.placeUp()

            return
        end
    end

    error('no items to place')
end

--- @param name string | nil
function Robot:placeDown(name)
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)

        if item and (not name or name == item.name) then
            turtle.select(i)
            turtle.placeDown()

            return
        end
    end

    error('no items to place')
end

--- @param x number
--- @param y number
--- @param z number
--- @param name string | nil
function Robot:fillToXYZ(x, y, z, name)
    local minX, maxX = math.min(x, self.x), math.max(x, self.x)
    local minY, maxY = math.min(y, self.y), math.max(y, self.y)
    local minZ, maxZ = math.min(z, self.z), math.max(z, self.z)

    for currentX = minX, maxX do
        for currentY = minY, maxY do
            for currentZ = minZ + 1, maxZ do
                self:goToXYZ(currentX, currentY, currentZ, nil, true)

                while turtle.detectDown() do
                    turtle.digDown()
                end

                self:placeDown()
            end
        end
    end

    self:goToXYZ(maxX, maxY, maxZ, 0, true)

    for currentX = maxX - 1, minX - 1, -1 do
        for i = 1, maxY - minY do
            self:goBack(1, true)
            self:placeFront(name)
        end

        if currentX >= minX then
            self:goToXYZ(currentX, minY, maxZ, 1, true)
            self:placeFront(name)
            self:goToXYZ(currentX, maxY, maxZ, 0, true)
        end
    end

    self:goUp(1, true)
    self:placeDown(name)
end

return Robot
