local farms = {
  ["lava"] = 1,
  ["cobble"] = 2,
  ["gravel"] = 3,
  ["sand"] = 4,
  ["chicken"] = 5,
  ["cows"] = 6,
  ["mobs"] = 7,
  ["ores"] = 8,
  ["carrot"] = 9,
  ["potato"] = 10,
  ["sugar_cane"] = 11    
}

local buttons = {
  {label = "On", signal = "on", x = 1, y = 3},
  {label = "Off", signal = "off", x = 8, y = 3},
  {label = "Open", signal = "open", x = 1, y = 5},
  {label = "Close", signal = "close", x = 8, y = 5},
  {label = "Dump", signal = "dump", x = 1, y = 7},
  {label = "Fetch Status", signal = "fetch", x = 1, y = 9}
}

local farmStatus = {}

local monitor = peripheral.find("monitor")

if not monitor then
  print("No monitor found")
  return
end

print("Monitor found")

local function drawFarmSelection()
  monitor.clear()
  monitor.setCursorPos(1, 1)
  monitor.write("Farm Selection")

  local farmList = {}
  for farm, _ in pairs(farms) do
      table.insert(farmList, farm)
  end
  table.sort(farmList, function(a, b) return farms[a] < farms[b] end)

  local x, y = 1, 3
  for _, farm in ipairs(farmList) do
      monitor.setCursorPos(x, y)
      monitor.write("[" .. farm .. "]")
      x = x + 15
      if x > 45 then
          x = 1
          y = y + 2
      end
  end
end

local function fetchFarmStatus(farm)
  os.run({}, "farm/send_signal.lua", farm, "fetch")

  local id, message, protocol = rednet.receive("farm_protocol", farms[farm])

  if id then
      farmStatus[farm] = {
          ["power"] = message.power,
          ["open"] = message.open,
      }
  end
end

local function drawFarmControl(farm)
  fetchFarmStatus(farm)

  monitor.clear()
  monitor.setCursorPos(1, 1)
  monitor.write("Control Panel - " .. farm .. " Farm")

  for i, button in ipairs(buttons) do
      monitor.setCursorPos(button.x, button.y)
      monitor.write("[" .. button.label .. "]")
  end

  monitor.setCursorPos(1, 11)
  monitor.write("Power: " .. tostring(farmStatus[farm] and farmStatus[farm].power or "unknown"))
  monitor.setCursorPos(1, 12)
  monitor.write("Open: " .. tostring(farmStatus[farm] and farmStatus[farm].open or "unknown"))
  monitor.setCursorPos(1, 14)
  monitor.write("[Back]")
end

local function handleFarmSelectionTouch(x, y)
  local farmList = {}
  for farm, _ in pairs(farms) do
      table.insert(farmList, farm)
  end
  table.sort(farmList, function(a, b) return farms[a] < farms[b] end)

  local bx, by = 1, 3
  for _, farm in ipairs(farmList) do
      if y == by or y == by + 1 then
          if x >= bx and x < bx + string.len("[" .. farm .. "]") then
              return farm
          end
      end
      bx = bx + 15
      if bx > 45 then
          bx = 1
          by = by + 2
      end
  end
  return nil
end

local function handleFarmControlTouch(farm, x, y)
  for i, button in ipairs(buttons) do
      if x >= button.x and x < button.x + string.len(button.label) + 2 and y == button.y then
          print(farm .. " -> '" .. button.signal .. "'")
          os.run({}, "farm/send_signal.lua", farm, button.signal)

          if button.signal ~= "fetch" then
            fetchFarmStatus(farm)
          end

          break
      end
  end

  if y == 14 then
      return "back"
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
              print("Selected farm: " .. selectedFarm)

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