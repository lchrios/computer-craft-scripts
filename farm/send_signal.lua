local signals = {
  ["on"] = "on",
  ["off"] = "off",
  ["open"] = "open",
  ["close"] = "close",
  ["dump"] = "dump",
["fetch"] = "fetch"
}

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
  ["sugar_cane"] = 11,
["all"] = -1
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
  return farms[farm] or nil
end

local function getSignal(signal)
  return signals[signal] or nil
end

local function valFarm(farm)
  return farms[farm] ~= nil
end

local function valSignal(signal)
  return signals[signal] ~= nil
end

local function send(farm, signal)
  local pc = getFarm(farm)
  if pc then
  if pc == -1 then
    rednet.broadcast(signal, "farm_protocol")
  else
    rednet.send(pc, signal, "farm_protocol")
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
elseif #args ~= 2  then
  print("Usage: lua program_name.lua <farm_name> <signal>")
  return
end

local farm = args[1]
local signal = args[2]

if valFarm(farm) and valSignal(signal) then
  send(farm, signal)
else
  print("Invalid farm or signal.")
  printHelp()
end
