--
-- Ce script s'execute toutes les 5 minutes et synchronise le status
-- du device Domoticz RADIATEUR-SALON avec l'etat reel de la PAC Fujitsu.
--
package.path = package.path .. ';' .. '/home/wizaord/domoticz/scripts/lua/?.lua'
require("lib_conf")
require("lib_radiateur_fujitsu")

DEVICE_NAME = 'RADIATEUR-SALON'

currentTime = os.time()
currentDate = os.date("*t", currentTime)

commandArray = {}

if (currentDate.min % 30 == 0) then
    print('[RADIATEUR-SALON-SYNC] Synchronisation du statut du device...')

    -- Recupere le statut reel de la PAC
    currentPacStatus = getFujitsuPacStatus(FUJITSU_PAC_SALON_IP)

    -- Recupere le statut courant du device Domoticz
    currentDeviceStatus = otherdevices[DEVICE_NAME]
    print('[RADIATEUR-SALON-SYNC] Statut device Domoticz : ' .. tostring(currentDeviceStatus))
    print('[RADIATEUR-SALON-SYNC] Statut reel PAC        : ' .. currentPacStatus)

    if (currentDeviceStatus == currentPacStatus) then
        print('[RADIATEUR-SALON-SYNC] Statuts coherents, aucune mise a jour necessaire')
    else
        print('[RADIATEUR-SALON-SYNC] Desynchronisation detectee, mise a jour du device : ' .. tostring(currentDeviceStatus) .. ' --> ' .. currentPacStatus)
        commandArray[DEVICE_NAME] = currentPacStatus
    end
end

return commandArray
