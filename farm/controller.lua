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

-- Cargar el módulo de configuración
local config = require("../config")

local state = {
  ["power"] = true,
  ["open"] = true,
}

print("Listening for signals...")
redstone.setOutput("left", state.power)
redstone.setOutput("right", state.open)


while true do
  -- Espera a recibir un mensaje en el protocolo específico, sin tiempo de espera
  local senderID, message, protocol = rednet.receive()

  if type(message) == "string" then
      if message == "on" then
          print("Turning on...")
          state["power"] = true
          redstone.setOutput("left", true)
      elseif message == "off" then
          print("Turning off...")
          state["power"] = false
          redstone.setOutput("left", false)
      elseif message == "open" then
          print("Opening...")
          state["open"] = true
          redstone.setOutput("right", true)
      elseif message == "close" then
          print("Closing...")
          state["open"] = false
          redstone.setOutput("right", false)
      elseif message == "dump" then
          print("Dumping all stored items...")
      elseif message == "fetch" then
          print("Farm status sent")
          rednet.send(senderID, state, "farm_protocol")
      else
          print("Unknown signal: " .. message)
      end
  elseif type(message) == "table" then
      print("Received a table message:")
      printTable(message)
  else
      print("Unknown message type: " .. type(message))
  end
end
