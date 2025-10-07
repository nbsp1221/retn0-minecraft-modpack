Monitor = {}

function Monitor:new(monitor, options)
    local instance = setmetatable({}, { __index = self })

    if monitor == nil then
        error('Monitor:new() requires a monitor peripheral')
    end

    options = options or {}

    instance.monitor = monitor
    instance.backgroundColor = options.backgroundColor or colors.black
    instance.color = options.color or colors.white
    instance.textScale = options.textScale or 1
    instance.texts = {}
    instance.buttons = {}

    return instance
end

function Monitor:createText(name, options)
    local text = {}

    text.name = name
    text.x = options.x
    text.y = options.y
    text.text = options.text or ''
    text.backgroundColor = options.backgroundColor or self.backgroundColor
    text.color = options.color or self.color

    self.texts[name] = text
end

function Monitor:createButton(name, options)
    local button = {}

    button.name = name
    button.x = options.x
    button.y = options.y
    button.width = options.width
    button.height = options.height
    button.text = options.text or ''
    button.backgroundColor = options.backgroundColor or self.backgroundColor
    button.color = options.color or self.color
    button.onClick = options.onClick or function () end

    self.buttons[name] = button
end

function Monitor:getComponent(name)
    return self.texts[name] or self.buttons[name]
end

function Monitor:draw()
    self.monitor.setBackgroundColor(self.backgroundColor)
    self.monitor.setTextScale(self.textScale)
    self.monitor.clear()

    -- texts
    for _, text in pairs(self.texts) do
        self.monitor.setBackgroundColor(text.backgroundColor)
        self.monitor.setTextColor(text.color)
        self.monitor.setCursorPos(text.x, text.y)
        self.monitor.write(text.text)
    end

    -- buttons
    for _, button in pairs(self.buttons) do
        self.monitor.setBackgroundColor(button.backgroundColor)
        self.monitor.setTextColor(button.color)

        for i = 1, button.height do
            self.monitor.setCursorPos(button.x, button.y + i - 1)
            self.monitor.write(string.rep(' ', button.width))
        end

        self.monitor.setCursorPos(button.x + math.floor((button.width - #button.text) / 2), button.y + math.floor((button.height + 1) / 2) - 1)
        self.monitor.write(button.text)
    end
end

function Monitor:processEvents()
    local event, side, x, y = os.pullEvent('monitor_touch')

    for _, button in pairs(self.buttons) do
        if x >= button.x and x <= button.x + button.width - 1 and y >= button.y and y <= button.y + button.height - 1 then
            button.onClick(button)
        end
    end
end

function Monitor:run()
    while true do
        self:draw()
        self:processEvents()
    end
end

return Monitor
