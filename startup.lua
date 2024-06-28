print("Setting computer preferences...")

local config = require("config")

os.setComputerLabel(config.NAME)
rednet.open(config.CONN_SIDE)
rednet.host("farm_protocol", config.ID)

print(" - Label: " .. os.getComputerLabel())
print(" - farm_protocol: " .. config.ID)
print(" - ID: " .. os.getComputerID())

if multishell then
  local program = "farm/draw.lua"

  local tabID = multishell.launch({shell, require}, program)

  multishell.setTitle(tabID, "Controller")

  multishell.setFocus(1)
else
  shell.run("farm/draw.lua")

  while true do
    local event, id, text = os.pullEvent("key")
    if event == "key" then
      break
    end
  end
end