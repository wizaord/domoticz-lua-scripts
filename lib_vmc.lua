-- Some functions to handle the VMW
--

-- This function returns a string value to identify the vmc mode
-- VMC mode is configured in domoticz GUI
-- 00 => OFF
-- 10 => MANUEL
-- 20 => AUTO
function getVmcMode(SELECTEUR_VALUE)
    local v = SELECTEUR_VALUE;
    if v == 0 then return "OFF"
    elseif v == 10 then return "MANUEL"
    elseif v == 20 then return "AUTO"
    else return "ERROR"
    end
end


function isVmcIsTurnOff()
    vmcStatus = uservariables["VMC_STATUS"]
    if (vmcStatus == "Off") then
        print("Check if VMC is off : VMC is off")
        return true
    end
    print("Check if VMC is off : VMC is on")
    return false
end

function startVmc()
    switchSonoffUrl="http://" .. SONOFF_VMC_IP ..":8081/zeroconf/switch"
    os.execute('/usr/bin/curl -H "Content-Type: application/json" -X POST -d \'{"deviceId":"1000aa2bcb", "data":{"switch":"on"} }\' ' .. switchSonoffUrl)
end

function stopVmc()
    switchSonoffUrl="http://" .. SONOFF_VMC_IP ..":8081/zeroconf/switch"
    os.execute('/usr/bin/curl -H "Content-Type: application/json" -X POST -d \'{"deviceId":"1000aa2bcb", "data":{"switch":"off"} }\' ' .. switchSonoffUrl)
end

-- Cette fonction retourne 1 si l heure courante fait partie de la nuit
function isNigth(hour)
    hour = os.date("%H")
    intHour = tonumber(hour)
    print('hour ' .. intHour)
    if (intHour < 10 or intHour > 21) then
        return 1
    end
    return 0
end

-- cette fonction permet d'indiquer le nombre de millisecondes depuis le dernier evenement sur la VMC
function timeBetweenLastVMCEvent()
    currentTime = os.time()
    currentDate = os.date("*t", currentTime)

    lastChangedVMCStatus = otherdevices_lastupdate['VMC-ALL']

    year = string.sub(lastChangedVMCStatus, 1, 4)
    month = string.sub(lastChangedVMCStatus, 6, 7)
    day = string.sub(lastChangedVMCStatus, 9, 10)
    hour = string.sub(lastChangedVMCStatus, 12, 13)
    minutes = string.sub(lastChangedVMCStatus, 15, 16)
    seconds = string.sub(lastChangedVMCStatus, 18, 19)

    t2 = os.time { year = year, month = month, day = day, hour = hour, min = minutes, sec = seconds }
    difference = (os.difftime(currentTime, t2))
    return difference;
end