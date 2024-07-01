local config = require("../config")
local peripheral = peripheral or require("peripheral")

local signals = {
    {label = "On", signal = "on"},
    {label = "Off", signal = "off"},
    {label = "Open", signal = "open"},
    {label = "Close", signal = "close"},
    {label = "Dump", signal = "dump"},
    {label = "Reset", signal = "reset"}
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

local function drawMonitor()
    monitor.clear()
    monitor.setCursorPos(1, 1)
    monitor.write("Control Panel - " .. config.NAME)
    
    local y = 3
    for i, button in ipairs(signals) do
        monitor.setCursorPos(1, y)
        monitor.write("[" .. button.label .. "]")
        y = y + 2
    end

    monitor.setCursorPos(1, y + 1)
    monitor.write("Power: " .. tostring(state.power))
    monitor.setCursorPos(1, y + 2)
    monitor.write("Open: " .. tostring(state.open))
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
    local buttonYStart = 3
    for i, button in ipairs(signals) do
        if y == buttonYStart or y == buttonYStart + 1 then
            handleSignal(button.signal)
            shell.run("net/fcp.lua", "admin", "update")

            break
        end
        buttonYStart = buttonYStart + 2
    end
    drawMonitor()
end



drawMonitor()

while true do
    local event, side, x, y = os.pullEvent("monitor_touch")
    
    if event == "monitor_touch" then
        handleTouch(x, y)
    end
end