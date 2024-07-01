local farms = require("/farm/farms")

local buttons = {
    {label = "On", signal = "on", x = 1, y = 3, width = 8, height = 3, bgColor = colors.green},
    {label = "Off", signal = "off", x = 12, y = 3, width = 8, height = 3, bgColor = colors.red},
    {label = "Open", signal = "open", x = 1, y = 7, width = 8, height = 3, bgColor = colors.lightBlue},
    {label = "Close", signal = "close", x = 12, y = 7, width = 8, height = 3, bgColor = colors.orange},
    {label = "Dump", signal = "dump", x = 24, y = 3, width = 7, height = 3, bgColor = colors.magenta},
    {label = "Fetch", signal = "fetch", x = 24, y = 7, width = 7, height = 3, bgColor = colors.cyan},
    {label = "<--", signal = "back", x = 1, y = 1, width = 5, height = 1, bgColor = colors.red},
}

local farmStatus = {
  ["mobs"] = {
    ["power"] = true,
    ["open"] = true
  },
  
}

local monitor = peripheral.find("monitor")

if not monitor then
    print("No monitor found")
    return
end

print("Monitor found")

monitor.setTextScale(0.5) -- Ajusta el tamaño del texto para una mejor visualización

local function printTable(t, indent)
    if not indent then indent = 0 end
    local formatting = string.rep("  ", indent)
    for key, value in pairs(t) do
        if type(value) == "table" then
            print(formatting .. tostring(key) .. ": ")
            printTable(value, indent + 1)
        else
            print(formatting .. tostring(key) .. ": " .. tostring(value))
        end
    end
end

local function fetchFarmStatus(farm)
    os.run({}, "net/fcp.lua", farm, "fetch")

    local id, message, protocol = rednet.receive("fcp", farms[farm].id)

    if id then
        farmStatus[farm] = {
            ["power"] = message.power,
            ["open"] = message.open,
        }
    end
end

local function drawFarmButtons(button)
    for i = 0, button.width - 1 do
        for j = 0, button.height - 1 do
            monitor.setCursorPos(button.x + i, button.y + j)
            monitor.setBackgroundColor(colors.green)
            monitor.write(" ")
        end
    end

    local textX = button.x + math.floor((button.width - string.len(button.label)) / 2)
    local textY = button.y + math.floor(button.height / 2)
    monitor.setCursorPos(textX, textY)
    monitor.setBackgroundColor(colors.green)
    monitor.setTextColor(colors.white)
    monitor.write(button.label)
end

local function drawButton(button, farm)
  if
    (button.signal == "on" and farmStatus[farm] and not farmStatus[farm].power) or
    (button.signal == "off" and farmStatus[farm] and farmStatus[farm].power) or
    (button.signal == "open" and farmStatus[farm] and not farmStatus[farm].open) or
    (button.signal == "close" and farmStatus[farm] and farmStatus[farm].open) then
        bgColor = colors.gray
    else     
        bgColor = button.bgColor
    end

    for i = 0, button.width - 1 do
        for j = 0, button.height - 1 do
            monitor.setCursorPos(button.x + i, button.y + j)
            monitor.setBackgroundColor(bgColor)
            monitor.write(" ")
        end
    end
    local textX = button.x + math.floor((button.width - string.len(button.label)) / 2)
    local textY = button.y + math.floor(button.height / 2)
    monitor.setCursorPos(textX, textY)
    monitor.setBackgroundColor(bgColor)
    monitor.setTextColor(colors.white)
    monitor.write(button.label)
end

local function drawFarmSelection()
  monitor.setBackgroundColor(colors.black)
  monitor.clear()
  monitor.setCursorPos(1, 1)
  monitor.write("Farm Selection")

  local farmList = {}
  for farm, _ in pairs(farms) do
      table.insert(farmList, farm)
  end
  table.sort(farmList, function(a, b) return farms[a].id < farms[b].id end)

  local x, y = 1, 3
  for _, farm in ipairs(farmList) do
      if farms[farm].id > 0 then
          drawFarmButtons(farms[farm]["button"])
      end
  end
end

local function drawFarmControl(farm)
    fetchFarmStatus(farm)

    monitor.setBackgroundColor(colors.black)
    monitor.clear()
    monitor.setCursorPos(7, 1)
    monitor.write("Control Panel - [Farm] " .. farms[farm].button.label)

    for i, button in ipairs(buttons) do
        drawButton(button, farm)
    end

    monitor.setCursorPos(2, 11)
    monitor.setBackgroundColor(colors.black)
    monitor.setTextColor(colors.white)
    monitor.write("Status:")
    monitor.setCursorPos(2, 12)
    monitor.write(" Power: " .. tostring(farmStatus[farm] and farmStatus[farm].power and "On" or "Off"))
    monitor.setCursorPos(2, 13)
    monitor.write(" Open:  " .. tostring(farmStatus[farm] and farmStatus[farm].open and "Yes" or "No"))
end

local function handleFarmSelectionTouch(x, y)
  for _, farm in pairs(farms) do
      -- Verificar si las coordenadas (x, y) están dentro de los límites del botón de la granja
      button = farm.button
      
      if x >= button.x and x < button.x + button.width and y >= button.y and y < button.y + button.height then
          return farm.name
      end
  end
  return nil
end

local function handleFarmControlTouch(farm, x, y)
    for i, button in ipairs(buttons) do
        if x >= button.x and x < button.x + button.width and y >= button.y and y < button.y + button.height then
            if button.signal == "back" then
                return "back"
            end
            print(farm .. " -> '" .. button.signal .. "'")
            os.run({}, "net/fcp", farm, button.signal)

            if button.signal ~= "fetch" then
                fetchFarmStatus(farm)
            end

            drawFarmControl(farm) -- Redibujar los controles después de ejecutar la acción

            break
        end
    end

    return nil
end

local function main()
    drawFarmSelection()

    while true do
        local event, side, x, y = os.pullEvent("monitor_touch")

        if event == "monitor_touch" then
            local selectedFarm = handleFarmSelectionTouch(x, y)
            if selectedFarm then
                drawFarmControl(selectedFarm)

                while true do
                    local event, side, x, y = os.pullEvent("monitor_touch")

                    if event == "monitor_touch" then
                        local action = handleFarmControlTouch(selectedFarm, x, y)
                        if action == "back" then
                            drawFarmSelection()
                            break
                        end
                    end
                end
            end
        end
    end
end

main()