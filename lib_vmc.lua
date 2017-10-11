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


-- Cette fonction retourne 1 si l heure passe en parametre fait partie de la nuit
function isNigth(hour)
    intHour = tonumber(hour)
    print('hour ' .. intHour)
    if (intHour < 10 or intHour > 21) then
        return 1
    end
    return 0
end
