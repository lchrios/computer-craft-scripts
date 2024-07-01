local config = require("../config")
local peripheral = peripheral or require("peripheral")

local buttons = {
  {label = "On", signal = "on", x = 1, y = 3, width = 8, height = 3, bgColor = colors.green},
  {label = "Off", signal = "off", x = 12, y = 3, width = 8, height = 3, bgColor = colors.red},
  {label = "Open", signal = "open", x = 1, y = 7, width = 8, height = 3, bgColor = colors.lightBlue},
  {label = "Close", signal = "close", x = 12, y = 7, width = 8, height = 3, bgColor = colors.orange},
  {label = "Dump", signal = "dump", x = 24, y = 3, width = 7, height = 3, bgColor = colors.magenta},
}

local state = {
    ["power"] = false,
    ["open"] = false
}

local monitor = peripheral.find("monitor")
if not monitor then
    print("No monitor found")
    return
end

print("Monitor found")

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

local function drawButton(button)
  if
    (button.signal == "on" and not state.power) or
    (button.signal == "off" and state.power) or
    (button.signal == "open" and not state.open) or
    (button.signal == "close" and state.open) then
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

local function drawMonitor()
  monitor.setBackgroundColor(colors.black)
  monitor.clear()
  monitor.setCursorPos(1, 1)
  monitor.write("Control Panel - " .. config.NAME)

  for i, button in ipairs(buttons) do
      drawButton(button)
  end

  monitor.setCursorPos(2, 11)
  monitor.setBackgroundColor(colors.black)
  monitor.setTextColor(colors.white)
  monitor.write("Status:")
  monitor.setCursorPos(2, 12)
  monitor.write(" Power: " .. tostring(state.power and "On" or "Off"))
  monitor.setCursorPos(2, 13)
  monitor.write(" Open: " .. tostring(state.open and "Yes" or "No"))
end

local function handleSignal(signal)
    if signal == "on" then
        print("Turning on...")
        state["power"] = true
        redstone.setOutput("left", true)
    elseif signal == "off" then
        print("Turning off...")
        state["power"] = false
        redstone.setOutput("left", false)
    elseif signal == "open" then
        print("Opening...")
        state["open"] = true
        redstone.setOutput("right", true)
    elseif signal == "close" then
        print("Closing...")
        state["open"] = false
        redstone.setOutput("right", false)
    elseif signal == "dump" then
        print("Dumping all stored items...")
        redstone.setOutput("back", true)
        sleep(1)
        redstone.setOutput("back", false)
    elseif signal == "reset" then
        print("Resetting...")
        state["power"] = false
        state["open"] = false
        redstone.setOutput("left", false)
        redstone.setOutput("right", false)
    elseif signal == "fetch" then
        print("Farm status sent")
        rednet.send(senderID, state, "fcp")
    else
        print("Unknown signal: " .. signal)
    end
    drawMonitor()
end

local function handleTouch(x, y)
  for i, button in ipairs(buttons) do
      if x >= button.x and x < button.x + button.width and y >= button.y and y < button.y + button.height then
          handleSignal(button.signal)
          break
      end
  end

  return nil
end

drawMonitor()

while true do
    local event, side, x, y = os.pullEvent("monitor_touch")
    
    if event == "monitor_touch" then
      handleTouch(x, y)
    else
      local id, message, protocol = rednet.receive("fcp", farms["admin"].id)
      if message ~= nil then
          print("Received message: " .. message)
          handleSignal(message)
      end
    end
end