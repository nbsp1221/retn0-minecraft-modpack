package.path = package.path .. ';./modules/?.lua'

local utils = require('modules.utils')
local robot = require('modules.robot')

local function digHemp()
    robot.digByName('front', 'immersiveengineering:hemp')
end

local function cultivateHemp(length)
    for i = 1, length do
        digHemp()
        robot.go('front')
    end

    for i = 1, 3 do
        for j = 1, 2 do
            robot.turn(utils.fif(i % 2 == 1, 'left', 'right'))
            digHemp()
            robot.go('front')
        end

        for j = 1, length - 2 do
            digHemp()
            robot.go('front')
        end
    end

    robot.go('front')
end

local function main()
    local sectionCount = 4

    robot.go('front')

    for i = 1, sectionCount do
        cultivateHemp(22)

        robot.turn('left')
        robot.goContinuously('front')
        robot.turn('right')
        robot.go('front')
        robot.dropAll('down')
        robot.turn('back')

        if i < sectionCount then
            robot.go('front')
            robot.turn('left')
            robot.go('front', i * 5)
            robot.turn('right')
        end
    end
end

main()
