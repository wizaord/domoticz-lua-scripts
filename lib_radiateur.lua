-- Some functions to handle the radiator
--
function sleep(n)
  os.execute("sleep " .. tonumber(n))
end

-- This function is used to start the radiator
function startRadiateur ()
        os.execute ("ssh pi@192.168.1.8 'irsend SEND_ONCE HITACHIFORCE BTN_START'")
end

--This function is used to stop the radiator
function stopRadiateur ()
        os.execute ("ssh pi@192.168.1.8 'irsend SEND_ONCE HITACHIFORCE KEY_STOP'")
end

-- This function is used to change the temperature configured in the radiator.
-- If the radiator is turn off, it is started.
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
