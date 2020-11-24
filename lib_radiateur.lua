-- Some functions to handle the radiator
-- ATTENTION, il faut s'assurer que les cles SSH ROOT sont echanges via la commande : /usr/bin/ssh-copy-id -i ~/.ssh/id_dsa.pub XX@192.168.X.X
--

function sleep(n)
    os.execute("sleep " .. tonumber(n))
end

-- This function is used to start the radiator
function startRadiateur(SERVEUR_LOGIN, SERVEUR_IP)
--     print('demarrage du radiateur')
--     print('Executing ' .. 'ssh ' .. SERVEUR_LOGIN .. '@' .. SERVEUR_IP .. ' \'irsend SEND_ONCE HITACHIFORCE BTN_START\'')
    os.execute('ssh ' .. SERVEUR_LOGIN .. '@' .. SERVEUR_IP .. ' \'irsend SEND_ONCE HITACHIFORCE BTN_START\'')
end

--This function is used to stop the radiator
function stopRadiateur(SERVEUR_LOGIN, SERVEUR_IP)
--     print('executing : ssh ' .. SERVEUR_LOGIN .. '@' .. SERVEUR_IP.. ' \'irsend SEND_ONCE HITACHIFORCE KEY_STOP\'')
    os.execute('ssh ' .. SERVEUR_LOGIN .. '@' .. SERVEUR_IP .. ' \'irsend SEND_ONCE HITACHIFORCE KEY_STOP\'')
end

-- This function is used to change the temperature configured in the radiator.
-- If the radiator is turn off, it is started.
function changeTemperature(RADIATEUR_NAME, SERVEUR_LOGIN, SERVEUR_IP, newTemperature)
    local localTemp = ""
    if (newTemperature == 25) then
        localTemp = "KEY_F1"
    elseif (newTemperature == 26) then
        localTemp = "KEY_F2"
    else
        localTemp = "KEY_F" .. newTemperature
    end

    -- si le radiateur est eteint, on le reallume avant
    local isRadiateurRunning = otherdevices[RADIATEUR_NAME]
    if (isRadiateurRunning == "Off") then
        startRadiateur(SERVEUR_LOGIN, SERVEUR_IP)
        sleep(10)
    end

    print('Changement de la temperature a\' ' .. localTemp .. ' sur ' .. SERVEUR_LOGIN .. ':' .. SERVEUR_IP)
    os.execute('ssh ' .. SERVEUR_LOGIN .. '@' .. SERVEUR_IP .. ' \'irsend SEND_ONCE HITACHIFORCE ' .. localTemp .. '\'')
end

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