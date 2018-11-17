--
-- Ce script n'active rien. Il sert uniquement a allumer les autres VMC quand une des VMC
-- est allumee (ou eteinte)
--
--
--
--


--
-- variables definition
--
LST_VMC = { 'VMC-CUISINE', 'VMC-GARAGE', 'VMC-TOILETTE', 'VMC-SALLEDEBAIN', 'VMC-ALL' }

-- 
-- FUNCTIONS
--
-- return true if the device which has changed is in the list
--
function isDeviceHasChanged ()
	for k,v in pairs(LST_VMC)
	do
		if (devicechanged[v]) then
			return true
		end	
	end
	return false	
end

-- return the name of the first device with a changed status
function getChangeDeviceName()
	for k,v in pairs(LST_VMC)
        do
                if (devicechanged[v]) then
                        return v
                end
        end
        return ""
end

--
-- MAIN FUNCTION
--

commandArray = {}
if (isDeviceHasChanged()) then

	-- on regarde le status de la variable VMC_STATUS
	-- on la compare a la valeur dans STATUS-CHANGE

	-- si les valeurs correspondent, on ne fait rien
	-- sinon on change tout

	deviceWithNewValue = getChangeDeviceName()
	status = devicechanged[deviceWithNewValue]

	if (status ~= uservariables["VMC_STATUS"])
	then

		-- get the value
		print ('device change ' .. deviceWithNewValue .. 'with value ' .. status)
		commandArray['Variable:VMC_STATUS']=status
		for k,v in pairs(LST_VMC)
        	do
			print ('Changement de status <' .. status .. '> pour le device <' .. v .. '>')
			commandArray[v]=status
		end
	end
end
return commandArray
