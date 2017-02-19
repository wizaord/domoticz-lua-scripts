-- FUNCTION PERMETTANT dINTERAGIR AVEC LE RADIATEUR
--
function sleep(n)
  os.execute("sleep " .. tonumber(n))
end

function startRadiateur ()
        os.execute ("ssh pi@192.168.1.8 'irsend SEND_ONCE HITACHIFORCE BTN_START'")
end

function stopRadiateur ()
        os.execute ("ssh pi@192.168.1.8 'irsend SEND_ONCE HITACHIFORCE KEY_STOP'")
end

function changeTemperature (temp)
	localTemp = "KEY_F"..temp
	if (temp == "25") then
		localTemp = "KEY_F1"
	end

	if (temp == "26") then
		localTemp = "KEY_F2"
	end

	-- si le radiateur est eteint, on le reallume avant
	isRadiateurRunning = otherdevices['RADIATEUR-SALON']

	if ( isRadiateurRunning == "Off" ) then
		startRadiateur()
		sleep (5)
	end
	
	print ('Changement de la temperature a\' ' .. localTemp)
	os.execute ('ssh pi@192.168.1.8 \'irsend SEND_ONCE HITACHIFORCE ' .. localTemp .. '\'')
	
	if ( isRadiateurRunning == "Off" ) then	
		return 1
	else
		return 0
	end
end
