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
  {label = "On", signal = "on"},
  {label = "Off", signal = "off"},
  {label = "Open", signal = "open"},
  {label = "Close", signal = "close"},
  {label = "Dump", signal = "dump"},
  {label = "Fetch Status", signal = "fetch"}
}

local farmStatus = {
  ["lava"] = {}
}

local monitor = peripheral.find("monitor")

if not monitor then
  print("No monitor found")
  return
end

local function drawMonitor()
  print("Drawing monitor...")

  monitor.clear()
  monitor.setCursorPos(1, 1)
  monitor.write("Control Panel - Lava Farm")
  
  local y = 3
  for i, button in ipairs(buttons) do
      monitor.setCursorPos(1, y)
      monitor.write("[" .. button.label .. "]")
      y = y + 2
  end

  monitor.setCursorPos(1, y + 1)
  monitor.write("Power: " .. tostring(farmStatus["lava"].power) or "unknown")
  monitor.setCursorPos(1, y + 2)
  monitor.write("Open: " .. tostring(farmStatus["lava"].open) or "unknown")
end

local function handleTouch(x, y)
  local buttonYStart = 3
  for i, button in ipairs(buttons) do
      if y == buttonYStart or y == buttonYStart + 1 then
          os.run({}, "farm/send_signal.lua", "lava", button.signal)

          -- if signal is not fetch, then we need to fetch the status
          if button.signal ~= "fetch" then
              os.run({}, "farm/send_signal.lua", "lava", "fetch")
          end

          
          local id, message, protocol = rednet.receive("farm_protocol", 1)

          if id then
              farmStatus["lava"] = {
                  ["power"] = message.power,
                  ["open"] = message.open,
              }
          end
    
          break 
      end
      
      buttonYStart = buttonYStart + 2
  end
  
  drawMonitor()
end

handleTouch(1, 13)

while true do
  local event, side, x, y = os.pullEvent("monitor_touch")
  
  if event == "monitor_touch" then
      handleTouch(x, y)
  end
end
