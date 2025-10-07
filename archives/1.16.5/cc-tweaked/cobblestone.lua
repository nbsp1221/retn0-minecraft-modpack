package.path = package.path .. ';./modules/?.lua'

local robot = require('modules.robot')

local function main()
    while true do
        if robot.detect('down') then
            robot.digByName('down', 'minecraft:cobblestone')
            robot.drop('front')
        end

        sleep(0.5)
    end
end

main()
