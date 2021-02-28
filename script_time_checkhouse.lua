--
-- Ce script va s'executer le soir à 20h
-- Il permet de faire différent controle sur la maison.
-- Une notification est envoyé si jamais il y a un souci.
--
package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua'
require("lib_conf")


currentTime = os.time()
currentDate = os.date("*t", currentTime)

function checkAndNotifIfDoorIsOpened(PORTE_NAME)
    deviceDoorStatus = otherdevices[PORTE_NAME]
    print("Door status with name " .. PORTE_NAME .. " has value " .. deviceDoorStatus)
    if deviceDoorStatus ~= "Closed" then
        commandArray['SendNotification']='Porte ' .. PORTE_NAME .. '#Ouverte#0###pushbullet'
    end
end

commandArray = {}

if (currentDate.hour == 20 and currentDate.min == 00) then
    checkAndNotifIfDoorIsOpened("Porte Garage")
    checkAndNotifIfDoorIsOpened("Porte Cuisine")
    checkAndNotifIfDoorIsOpened("Porte Salon")
end

return commandArray
