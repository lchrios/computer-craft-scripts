-- Enumerar todos los periféricos conectados
local peripherals = peripheral.getNames()

print("Perifericos conectados:")

-- Iterar a través de la lista de nombres de periféricos
for _, name in ipairs(peripherals) do
    print("- " .. name .. " (" .. peripheral.getType(name) .. ")")
end