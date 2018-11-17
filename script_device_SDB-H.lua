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
DEVICE_NAME = 'TH-SALLEDEBAIN'
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
    -- si l'humidite est superieur a 70 et que le statut de la VMC est Off, on l'allume pour 30 minutes
    sdbTemperature, sdbHumidity = otherdevices_svalues[DEVICE_NAME]:match("([^;]+);([^;]+)")
    vmcStatus = uservariables["VMC_STATUS"]

    seuilDeDeclenchement = uservariables[VAR_HUMIDITY_REF] + SEUIL

    if (vmcStatus == "Off" and tonumber(sdbHumidity) >= seuilDeDeclenchement) then
        print("Allumage de la VMC pour 30 minutes")
        commandArray['Group:VMCs'] = 'On FOR 30'

        -- send email
--        local emailAddress = uservariables['email_address']
--        commandArray['SendEmail'] = '[DOMOTICZ] ALLUMAGE VMC#Allumage de la VMC#' .. emailAddress
    end
end
return commandArray
