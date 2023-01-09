local robot = require('robot')

local sugarcaneSectionCount = 11
local sugarcaneSectionLength = 30

while true do
    robot.suckAll('down')
    robot.refuelAll()
    robot.dropAll('down')
    robot.go('front', 3)
    robot.turn('left')
    robot.go('front')
    robot.turn('right')

    for i = 1, sugarcaneSectionCount do
        for j = 1, sugarcaneSectionLength do
            robot.safeDig('front', 'minecraft:sugar_cane')
            robot.go('front')
            robot.safeDig('down', 'minecraft:sugar_cane')
        end

        for j = 1, 2 do
            robot.turn('left')
            robot.safeDig('front', 'minecraft:sugar_cane')
            robot.go('front')
            robot.safeDig('down', 'minecraft:sugar_cane')
        end

        for j = 1, sugarcaneSectionLength - 2 do
            robot.safeDig('front', 'minecraft:sugar_cane')
            robot.go('front')
            robot.safeDig('down', 'minecraft:sugar_cane')
        end

        robot.go('front')

        if i < sugarcaneSectionCount then
            if robot.getAllItemsSpace() < sugarcaneSectionLength * 4 then
                robot.turn('left')
                robot.goContinuously('front')
                robot.turn('right')
                robot.go('front')
                robot.dropAll('down')
                robot.turn('back')
                robot.go('front')
                robot.turn('left')
                robot.go('front', i * 3 + 1)
            else
                robot.turn('right')
                robot.go('front', 2)
            end

            robot.turn('right')
        end
    end

    robot.turn('left')
    robot.goContinuously('front')
    robot.turn('right')
    robot.go('front')
    robot.dropAll('down')
    robot.go('front', 2)
    robot.turn('back')

    -- 30 minutes
    sleep(1800)
end
