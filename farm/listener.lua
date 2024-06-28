-- Cargar el módulo de configuración
local config = require("../config")

-- Abre el módem en el lado correspondiente, cámbialo si es necesario
rednet.open(config.CONN_SIDE)

print("Listening for signals...")

while true do
    -- Espera a recibir un mensaje en el protocolo específico, sin tiempo de espera
    local senderID, message, protocol = rednet.receive()

    -- Procesa el mensaje recibido
    print("Received message from ID " .. senderID .. ": " .. message)

    if message == "on" then
        print("Turning on...")
        redstone.setOutput("left", true)
    elseif message == "off" then
        print("Turning off...")
        redstone.setOutput("left", false)
    elseif message == "open" then
        print("Opening...")
        redstone.setOutput("right", true)
    elseif message == "close" then
        print("Closing...")
        redstone.setOutput("right", false)
	elseif messsage == "dump" then
		print("Dumping all stored items...")
    else
        print("Unknown signal: " .. message)
    end
end
