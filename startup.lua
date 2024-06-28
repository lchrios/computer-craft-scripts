print("Setting computer preferences...")

local config = require("config")

os.setComputerLabel(config.NAME)
rednet.open(config.CONN_SIDE)
rednet.host("farm_protocol", config.ID)

print(" - Label: " .. os.getComputerLabel())
print(" - farm_protocol: " .. config.ID)
print(" - ID: " .. os.getComputerID())
