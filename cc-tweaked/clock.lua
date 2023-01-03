local monitor = peripheral.wrap("right")

monitor.setTextColor(colors.yellow)
monitor.setTextScale(1.5)

while true do
    local x, y = monitor.getSize()
    local date = os.date("%Y-%m-%d %X")

    monitor.clear()
    monitor.setCursorPos(math.floor(x / 2 - #date / 2) + 1, y - 1)
    monitor.write(date)

    sleep(0.1)
end
