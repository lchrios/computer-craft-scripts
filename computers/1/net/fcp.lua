-- fcp.lua
os.loadAPI("/farm/farms.lua")

local signals = {
  ["on"] = "on",
  ["off"] = "off",
  ["open"] = "open",
  ["close"] = "close",
  ["dump"] = "dump",
  ["fetch"] = "fetch"
}

local function printHelp()
  print("Available signals")
  print("===================")
  for sig in pairs(signals) do
      print(" - " .. sig)
  end

  read()
  
  print("\nAvailable farms")
  print("===================")
  for farm in pairs(farms) do
      print(" - " .. farm)
  end

  read()
end

local function getFarm(farm) 
  return farms.farms[farm] or nil
end

local function getSignal(signal)
  return signals[signal] or nil
end

local function valFarm(farm)
  return farms.farms[farm] ~= nil
end

local function valSignal(signal)
  return signals[signal] ~= nil
end

local function send(farm, signal)
  local pc = getFarm(farm)
  if pc then
      if pc.id == -1 then
          rednet.broadcast(signal, "fcp")
      else
          rednet.send(pc.id, signal, "fcp")
          print(farm .. " -> '" .. signal .. "'")
      end
  else
      print("Invalid farm '" .. farm .. "'")
  end
end

-- Parse command line arguments
local args = { ... }
if #args == 1 and args[1] == "help" then
    printHelp()
elseif #args ~= 2 then
    print("Usage: lua program_name.lua <farm_name> <signal>")
    return
end

local farm = args[1]
local signal = args[2]

if valFarm(farm) and valSignal(signal) then
    send(farm, signal)
else
  print("Invalid farm or signal.") 
  print("farm:   " .. (farm or "unknown") .. " valid: " .. tostring(valFarm(farm)))
  print("signal: " .. (signal or "unknown") .. " valid: " .. tostring(valSignal(signal)))
  print("Use 'help' to get a list of available farms and signals.")
end