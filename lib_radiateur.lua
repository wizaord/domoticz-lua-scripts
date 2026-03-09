-- Some functions to handle the radiator
--

-- This function returns a string value to identify the radiator mode
-- Radiator mode is configured in domoticz GUI
-- 00 => OFF
-- 10 => AUTO
-- 20 => WEEKEND
-- 30 => MANUEL
function getRadiatorMode(SELECTEUR_VALUE)
    local v = SELECTEUR_VALUE;
    if v == 0 then return "OFF"
    elseif v == 10 then return "AUTO"
    elseif v == 20 then return "WEEKEND_OFF"
    elseif v == 30 then return "MANUEL"
    elseif v == 40 then return "HORSGEL"
    elseif v == 50 then return "FORCE16"
    else return "ERROR"
    end
end


-- Function to determine if it's the weekend or not
-- Return true if it's the weekend
function isWeekendOffMode()
    local currentHour = os.date("*t").hour;
    local currentDay = os.date("*t").wday;
    print('currentDay => ' .. currentDay .. ' currentHour => ' .. currentHour)
    -- 1 is Sunday
    if (currentDay == 7) then return true end
    if (currentDay == 1) then
        -- it's sunday. Weekend mode only if hour is less than 1pm
        if (currentHour < 13) then return true end
    elseif currentDay == 6   then
        -- it's friday
        if (currentHour > 14) then return true end
    end
    print("Ce n'est pas le weekend")
    return false
end