--
-- Ce script permet d'allumer ou de couper le radiateur du salon.
-- Il faut passer par le RPI pour ealiser l'action
--
package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua'
require("lib_conf")
require("lib_radiateur")

--
-- variables definition
--

PRISE1_IP="sonoff-prise1"
PRISE1_SONOFFAPI="http://" .. PRISE1_IP ..":8081/zeroconf/switch"

DEVICE_NAME = 'Prise1'
commandArray = {}
if (devicechanged[DEVICE_NAME]) then
    statusPrise1 = devicechanged[DEVICE_NAME]
    if (statusPrise1 == "On") then
        os.execute('/usr/bin/curl -H "Content-Type: application/json" -X POST -d \'{"deviceId":"1000f935e7", "data":{"switch":"on"} }\' ' .. PRISE1_SONOFFAPI)
    else
        os.execute('/usr/bin/curl -H "Content-Type: application/json" -X POST -d \'{"deviceId":"1000f935e7", "data":{"switch":"off"} }\' ' .. PRISE1_SONOFFAPI)
    end
end
return commandArray


