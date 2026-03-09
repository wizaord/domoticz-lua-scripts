--
-- Ce script permet d'allumer ou de couper le radiateur du salon.
-- Il utilise le JAR fujitsu-heat-pump-cli pour piloter la PAC Fujitsu
-- via l'adaptateur WiFi AirStage (UTY-TFSXH3) en local, sans cloud.
--
package.path = package.path .. ';' .. '/home/wizaord/domoticz/scripts/lua/?.lua'
require("lib_conf")
require("lib_radiateur_fujitsu")

--
-- variables definition
--
DEVICE_NAME = 'RADIATEUR-SALON'

commandArray = {}
if (devicechanged[DEVICE_NAME]) then
    -- on determine si on allume ou on eteint le radiateur
    newRadiateurStatus = devicechanged[DEVICE_NAME]
    print('[RADIATEUR-SALON] Changement demande : ' .. newRadiateurStatus)

    -- on recupere le status courant directement depuis la PAC
    currentPacStatus = getFujitsuPacStatus(FUJITSU_PAC_SALON_IP)

    if (newRadiateurStatus == currentPacStatus) then
        print('[RADIATEUR-SALON] Statut identique (' .. currentPacStatus .. '), aucune action necessaire')
    else
        print('[RADIATEUR-SALON] Changement de statut : ' .. currentPacStatus .. ' --> ' .. newRadiateurStatus)
        if (newRadiateurStatus == 'On') then
            startFujitsuPac(FUJITSU_PAC_SALON_IP)
        else
            stopFujitsuPac(FUJITSU_PAC_SALON_IP)
        end
    end
end
return commandArray
