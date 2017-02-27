-- Some functions to handle the radiator
-- ATTENTION, il faut s'assurer que les cles SSH ROOT sont echanges via la commande : /usr/bin/ssh-copy-id -i ~/.ssh/id_dsa.pub XX@192.168.X.X
--


function sleep(n)
  os.execute("sleep " .. tonumber(n))
end

-- This function is used to start the radiator
function startRadiateur ()
    --print('demarrage du radiateur')
    os.execute ('ssh ' .. SERVEUR_LOGIN .. '@' .. SERVEUR_IP.. ' \'irsend SEND_ONCE HITACHIFORCE BTN_START\'')
end

--This function is used to stop the radiator
function stopRadiateur ()
    --print('executing : ssh ' .. SERVEUR_LOGIN .. '@' .. SERVEUR_IP.. ' \'irsend SEND_ONCE HITACHIFORCE KEY_STOP\'')
    os.execute ('ssh ' .. SERVEUR_LOGIN .. '@' .. SERVEUR_IP.. ' \'irsend SEND_ONCE HITACHIFORCE KEY_STOP\'')
end

-- This function is used to change the temperature configured in the radiator.
-- If the radiator is turn off, it is started.
function changeTemperature (temp)
	localTemp = "KEY_F"..temp
	if (temp == 25) then
		localTemp = "KEY_F1"
	end

	if (temp == 26) then
		localTemp = "KEY_F2"
	end

	-- si le radiateur est eteint, on le reallume avant
	isRadiateurRunning = otherdevices['RADIATEUR-SALON']

	if ( isRadiateurRunning == "Off" ) then
		startRadiateur()
		sleep (5)
	end
	
	print ('Changement de la temperature a\' ' .. localTemp)
    os.execute ('ssh ' .. SERVEUR_LOGIN .. '@' .. SERVEUR_IP.. ' \'irsend SEND_ONCE HITACHIFORCE ' .. localTemp .. '\'')
	
	if ( isRadiateurRunning == "Off" ) then	
		return 1
	else
		return 0
	end
end
