--
-- Ce script s'active quand le capteur de la salle de bain s'active
-- Ce script permet d'allumer la VMC quand le taux d'humidite est superieur de 10 au taux de reference
--
--
package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua'
require("lib_conf")
require("lib_vmc")

--
-- variables definition
--
DEVICE_NAME = 'HU-SALLEDEBAIN'
SEUIL = 10

VAR_HUMIDITY_REF = 'HUMIDITY_REF'

-- 
-- FUNCTIONS
--

-- MAIN FUNCTION
--


commandArray = {}
if (devicechanged[DEVICE_NAME]) then

    runningMode = getVmcMode(tonumber(otherdevices_svalues['VMC-MODE']))
    if (runningMode == "OFF" or runningMode == "MANUEL") then
        --mode manuel, on ne fait rien
        print('VMC SDB : VMC Mode OFF ou MANUEL ACTIVE. Do nothing')
        return commandArray
    end

    -- l'algo est le suivant
    -- si l'humidite est superieur a la valeur de réference + SEUIL
    -- et que le statut de la VMC est Off, on l'allume pour 30 minutes
    sdbHumidity = otherdevices[DEVICE_NAME]
    vmcStatus = uservariables["VMC_STATUS"]
    VMCLastEventTime = timeBetweenLastVMCEvent();

    seuilDeDeclenchement = uservariables[VAR_HUMIDITY_REF] + SEUIL

    if (vmcStatus == "Off" and tonumber(sdbHumidity) >= seuilDeDeclenchement) then
        -- si le status de la VMC a changé il y a pas 10 minutes, on ne fait rien
        -- c'est surement l'utilisateur qui a voulu la couper pour une raison
        if (VMCLastEventTime < 600) then
            print("La VMC a ete coupé il y a pas 10 minutes, on ne fait rien pour l'instant")
            return commandArray
        end

        print("Allumage de la VMC pour 30 minutes")
        commandArray['Group:VMCs'] = 'On FOR 30'
    end
end
return commandArray
