-- Some functions to handle the radiator
-- ATTENTION, il faut s'assurer que les cles SSH ROOT sont echanges via la commande : /usr/bin/ssh-copy-id -i ~/.ssh/id_dsa.pub XX@192.168.X.X
--

function sleep(n)
    os.execute("sleep " .. tonumber(n))
end

-- This function is used to start the radiator
function startRadiateur(SERVEUR_LOGIN, SERVEUR_IP)
    --print('demarrage du radiateur')
    print('Executing ' .. 'ssh ' .. SERVEUR_LOGIN .. '@' .. SERVEUR_IP .. ' \'irsend SEND_ONCE HITACHIFORCE BTN_START\'')
    os.execute('ssh ' .. SERVEUR_LOGIN .. '@' .. SERVEUR_IP .. ' \'irsend SEND_ONCE HITACHIFORCE BTN_START\'')
end

--This function is used to stop the radiator
function stopRadiateur(SERVEUR_LOGIN, SERVEUR_IP)
    print('executing : ssh ' .. SERVEUR_LOGIN .. '@' .. SERVEUR_IP.. ' \'irsend SEND_ONCE HITACHIFORCE KEY_STOP\'')
    os.execute('ssh ' .. SERVEUR_LOGIN .. '@' .. SERVEUR_IP .. ' \'irsend SEND_ONCE HITACHIFORCE KEY_STOP\'')
end

-- This function is used to change the temperature configured in the radiator.
-- If the radiator is turn off, it is started.
function changeTemperature(SERVEUR_LOGIN, SERVEUR_IP, newTemperature)
    local localTemp = ""
    if (newTemperature == 25) then
        localTemp = "KEY_F1"
    elseif (newTemperature == 26) then
        localTemp = "KEY_F2"
    else
        localTemp = "KEY_F" .. newTemperature
    end

    -- si le radiateur est eteint, on le reallume avant
    local isRadiateurRunning = otherdevices['RADIATEUR-SALON']
    if (isRadiateurRunning == "Off") then
        startRadiateur(SERVEUR_LOGIN, SERVEUR_IP)
        sleep(10)
    end

    print('Changement de la temperature a\' ' .. localTemp .. ' sur ' .. SERVEUR_LOGIN .. ':' .. SERVEUR_IP)
    os.execute('ssh ' .. SERVEUR_LOGIN .. '@' .. SERVEUR_IP .. ' \'irsend SEND_ONCE HITACHIFORCE ' .. localTemp .. '\'')

    if (isRadiateurRunning == "Off") then
        return 1
    else
        return 0
    end
end
