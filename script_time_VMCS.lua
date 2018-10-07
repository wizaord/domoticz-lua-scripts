--
-- Ce script est lance toutes les minutes. Il va verifier si la VMC
-- est coupee depuis plus de 6h. Si oui la VMC est lancee pendant
-- 30 minutes
-- La VMC n est pas allume la nuit pour garder la chaleur
--

package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua'
require("lib_vmc")

commandArray = {}

currentTime = os.time()
currentDate = os.date("*t", currentTime)

runningMode = getVmcMode(tonumber(otherdevices_svalues['VMC-MODE']))
print('VMC : Mode de fonctionnement : ' .. runningMode);
if (runningMode == "OFF" or runningMode == "MANUEL") then
    --mode manuel, on ne fait rien
    print('VMC : Mode OFF ou MANUEL ACTIVE. Do nothing')
    return commandArray
end

lastChangedVMCStatus = otherdevices_lastupdate['VMC-ALL']

year = string.sub(lastChangedVMCStatus, 1, 4)
month = string.sub(lastChangedVMCStatus, 6, 7)
day = string.sub(lastChangedVMCStatus, 9, 10)
hour = string.sub(lastChangedVMCStatus, 12, 13)
minutes = string.sub(lastChangedVMCStatus, 15, 16)
seconds = string.sub(lastChangedVMCStatus, 18, 19)

t2 = os.time { year = year, month = month, day = day, hour = hour, min = minutes, sec = seconds }
difference = (os.difftime(currentTime, t2))
print('VMC : last executed time : ' .. difference)
if (otherdevices['VMC-ALL'] == 'Off' and difference > 21600) then

    -- on regarde si c est la nuit
    if (isNigth(hour) == 1) then
        --on va erifier la temperature de dehors
        outTemperature, outHumidity = otherdevices_svalues["WU_Temp"]:match("([^;]+);([^;]+)")
        if (tonumber(outTemperature) > 5) then
            commandArray['Group:VMCs'] = 'On FOR 30'
        end
    else
        print("Allumage de la VMC car eteinte depuis 6h")
        commandArray['Group:VMCs'] = 'On FOR 30'
    end
end

return commandArray
