package.path = package.path .. ';./modules/?.lua'

local dfpwm = require('cc.audio.dfpwm')
local Monitor = require('monitor')

local speaker = peripheral.find('speaker')
local decoder = dfpwm.make_decoder()

if not speaker then
    print('Speaker not found')
    return
end

local shifts = {243, 27, 174, 77, 169, 133, 62, 179, 210, 120, 227, 211, 249, 71, 252, 8}
local keys = {209, 163, 195, 180, 46, 217, 102, 49, 224, 0, 92, 72, 227, 47, 213, 158}

local playlist = {
    {
        title = 'Astronomia 2K19',
        artist = 'Stephan F',
        url = 'https://github.com/nbsp1221/minecraft-settings/raw/main/cc-tweaked/apps/music-player/data/stephan-f-astronomia-2k19',
    },
    {
        title = 'God knows...',
        artist = 'Aya Hirano',
        url = 'https://github.com/nbsp1221/minecraft-settings/raw/main/cc-tweaked/apps/music-player/data/aya-hirano-god-knows',
    },
    {
        title = 'only my railgun',
        artist = 'fripSide',
        url = 'https://github.com/nbsp1221/minecraft-settings/raw/main/cc-tweaked/apps/music-player/data/fripside-only-my-railgun',
    },
}

local function decode(data)
    local result = ''

    for i = 1, #data do
        local byte = string.byte(data, i)

        byte = bit.bxor(byte, keys[(i - 1) % #keys + 1])
        byte = (byte - shifts[(i - 1) % #shifts + 1]) % 256

        result = result .. string.char(byte)
    end

    return result
end

local function splitByChunk(data, chunkSize)
    local splitted = {}

    for i = 1, #data, chunkSize do
        splitted[#splitted + 1] = data:sub(i, i + chunkSize - 1)
    end

    return splitted
end

local function playMusic(url)
    local response = http.get(url, {}, true)

    if not response then
        error('Failed to download data')
    end

    local data = response.readAll()
    local decodedData = decode(data)
    local chunks = splitByChunk(decodedData, 8192)

    for i, chunk in ipairs(chunks) do
        while not speaker.playAudio(decoder(chunk)) do
            os.pullEvent('speaker_audio_empty')
        end
    end
end

local function main()
    local monitor = Monitor:new(peripheral.find('monitor'))

    local titleLength = 19
    local artistLength = 12

    local selectedMusic = nil

    monitor:createText('title-pt', {
        x = 5, y = 2, text = string.rep(' ', titleLength), backgroundColor = colors.gray,
    })
    monitor:createText('title', {
        x = 5, y = 3, text = string.rep(' ', (titleLength - 5) / 2) .. 'Title' .. string.rep(' ', (titleLength - 5) / 2), backgroundColor = colors.gray,
    })
    monitor:createText('title-pb', {
        x = 5, y = 4, text = string.rep(' ', titleLength), backgroundColor = colors.gray,
    })

    monitor:createText('artist-pt', {
        x = titleLength + 6, y = 2, text = string.rep(' ', artistLength), backgroundColor = colors.gray,
    })
    monitor:createText('artist', {
        x = titleLength + 6, y = 3, text = string.rep(' ', (artistLength - 6) / 2) .. 'Artist' .. string.rep(' ', (artistLength - 6) / 2), backgroundColor = colors.gray,
    })
    monitor:createText('artist-pb', {
        x = titleLength + 6, y = 4, text = string.rep(' ', artistLength), backgroundColor = colors.gray,
    })

    for i = 1, #playlist do
        local title = playlist[i].title
        local artist = playlist[i].artist

        monitor:createText(i, {
            x = 2, y = (i - 1) * 2 + 6, text = string.format('%02d', i), color = colors.yellow,
        })
        monitor:createButton('music-' .. i, {
            x = 5,
            y = (i - 1) * 2 + 6,
            width = titleLength + artistLength + 1,
            height = 1,
            text = title .. string.rep(' ', titleLength - #title + 1) .. artist .. string.rep(' ', artistLength - #artist),
            onClick = function (this)
                local number = tonumber(string.sub(this.name, -1))

                if selectedMusic then
                    monitor:getComponent('music-' .. selectedMusic).backgroundColor = monitor.backgroundColor
                end

                print(this)

                if selectedMusic ~= number then
                    selectedMusic = number
                    this.backgroundColor = colors.red
                else
                    selectedMusic = nil
                end

                monitor:draw()
            end
        })
    end

    monitor:createButton('play', {
        x = 40, y = 8, width = 10, height = 3, text = 'PLAY', backgroundColor = colors.green,
        onClick = function ()
            if selectedMusic then
                playMusic(playlist[selectedMusic].url)
            end
        end
    })
    monitor:createButton('scroll-up', {
        x = 40, y = 12, width = 10, height = 3, text = 'UP', backgroundColor = colors.lightGray, color = colors.gray,
    })
    monitor:createButton('scroll-down', {
        x = 40, y = 16, width = 10, height = 3, text = 'DOWN', backgroundColor = colors.lightGray, color = colors.gray,
    })

    monitor:run()
end

main()
