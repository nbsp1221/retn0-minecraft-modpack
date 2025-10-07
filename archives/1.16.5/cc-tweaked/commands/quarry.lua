package.path = package.path .. ';./modules/?.lua'

local robot = require('robot')
local args = { ... }

if #args ~= 2 then
    print('Usage: quarry <length> <width>')
    return
end

local length = tonumber(args[1])
local width = tonumber(args[2])

for i = 1, width do
    robot.turn('right')
    robot.digLine('front', length - 1)
    robot.turn('back')
    robot.go('front', length - 1)

    if robot.getEmptySlotCount() <= 4 then
        robot.turn('left')
        robot.go('front', i - 1)
        robot.dropAll('front')
        robot.turn('back')
        robot.go('front', i - 1)
    else
        robot.turn('right')
    end

    if i < width then
        robot.dig('front')
        robot.go('front', 1)
    end
end

robot.turn('back')
robot.go('front', width - 1)
robot.dropAll('front')
robot.turn('back')
