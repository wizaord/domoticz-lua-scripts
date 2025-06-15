--
-- Ce script s'active quand le capteur de la salle de bain s'active
-- Ce script permet d'allumer la VMC quand le taux d'humidite est superieur de 10 au taux de reference
--
--
package.path = package.path .. ';' .. '/home/wizaord/domoticz/scripts/lua/?.lua'
require("lib_conf")
require("lib_vmc")

--
-- variables definition
--
SEUIL = 10
VAR_HUMIDITY_REF = 'HUMIDITY_REF'

-- 
-- FUNCTIONS
--
function isHumiditySuperiorTo70()
    sdbHumidity = tonumber(otherdevices['HU-SALLEDEBAIN'])
    print('VMC SDB : Check if humidity is superior to 70 : ' .. sdbHumidity)
    return sdbHumidity >= 70
end

function isHumiditySuperiorToRef()
    sdbHumidity = tonumber(otherdevices['HU-SALLEDEBAIN'])
    seuilDeDeclenchement = tonumber(uservariables[VAR_HUMIDITY_REF]) + tonumber(SEUIL)
    print('VMC SDB : Check if humidity is superior to reference : ' .. sdbHumidity)
    return sdbHumidity >= seuilDeDeclenchement
end

-- MAIN FUNCTION
--

commandArray = {}
if (devicechanged['HU-SALLEDEBAIN']) then

    runningMode = getVmcMode(tonumber(otherdevices_svalues['VMC-MODE']))
    if (runningMode == "OFF" or runningMode == "MANUEL") then
        --mode manuel, on ne fait rien
        print('VMC SDB : VMC Mode OFF ou MANUEL ACTIVE. Do nothing')
        return commandArray
    end

    -- l'algo est le suivant
    -- si l'humidite est superieur a la valeur de réference + SEUIL
    -- et que le statut de la VMC est Off, on l'allume pour 30 minutes
    VMCLastEventTime = timeBetweenLastVMCEvent();

    if (isVmcIsTurnOff() and (isHumiditySuperiorToRef() or isHumiditySuperiorTo70())) then
        -- si le status de la VMC a changé il y a pas 5 minutes, on ne fait rien
        -- c'est surement l'utilisateur qui a voulu la couper pour une raison
        if (VMCLastEventTime < 300) then
            print("La VMC a ete coupé il y a pas 5 minutes, on ne fait rien pour l'instant")
            return commandArray
        end

        print("Allumage de la VMC pour 45 minutes")
        commandArray['Group:VMCs'] = 'On FOR 45'
    end
end
return commandArray
