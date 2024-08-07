print("Setting computer preferences...")

local config = require("config")

os.setComputerLabel(config.NAME)
rednet.open(config.CONN_SIDE)
rednet.host("fcp", config.ID)

print(" - ID: " .. os.getComputerID())
print(" - Label: " .. os.getComputerLabel())
print(" - Farm: " .. config.FARM)
print(" - fcp (Farm Comms Protocol): " .. config.ID)


if multishell then
  local program = "farm/controller.lua"

  local tabID = multishell.launch({}, program)

  multishell.setTitle(tabID, "Controller")

  multishell.setFocus(1)
else
  os.run({}, "farm/controller.lua")

  while true do
    local event, id, text = os.pullEvent("key")
    if event == "key" then
      break
    end
  end
end