--
-- Synchronise le statut ON/OFF des devices Domoticz RADIATEUR-* avec l'etat reel de chaque PAC.
-- Chaque PAC est interrogee toutes les 20 minutes, avec un decalage de 5 minutes entre chaque.
-- Les slots utilises (2/7/12/17) evitent les conflits avec MAJ-THERMOSTATS (0/5/10/15).
--

package.path = package.path .. ';' .. '/home/wizaord/domoticz/scripts/lua/?.lua'
require("lib_conf")
require("lib_radiateur_fujitsu")
require("lib_radiateur_atlantic")

commandArray = {}

currentTime = os.time()
currentDate = os.date("*t", currentTime)
slot = currentDate.min % 20

local function syncStatus(deviceName, pacStatus)
    local currentDeviceStatus = otherdevices[deviceName]
    print('[MAJ-STATUS] Statut device Domoticz : ' .. tostring(currentDeviceStatus))
    print('[MAJ-STATUS] Statut reel PAC        : ' .. pacStatus)
    if (currentDeviceStatus == pacStatus) then
        print('[MAJ-STATUS] Statuts coherents, aucune mise a jour necessaire')
    else
        print('[MAJ-STATUS] Desynchronisation detectee, mise a jour du device : ' .. tostring(currentDeviceStatus) .. ' --> ' .. pacStatus)
        commandArray[deviceName] = pacStatus
    end
end

if slot == 2 then
    print('[MAJ-STATUS] Synchronisation RADIATEUR-SALON (Fujitsu)')
    local pacStatus = getFujitsuPacStatus(FUJITSU_PAC_SALON_IP)
    syncStatus('RADIATEUR-SALON', pacStatus)
elseif slot == 7 then
    print('[MAJ-STATUS] Synchronisation RADIATEUR-CHAMBRE-PARENTS (Atlantic)')
    local pacStatus = getAtlanticPacStatus(ATLANTIC_DEVICE_URL_CHAMBRE_PARENTS)
    syncStatus('RADIATEUR-CHAMBRE-PARENTS', pacStatus)
elseif slot == 12 then
    print('[MAJ-STATUS] Synchronisation RADIATEUR-CHAMBRE-ETHAN (Atlantic)')
    local pacStatus = getAtlanticPacStatus(ATLANTIC_DEVICE_URL_CHAMBRE_ETHAN)
    syncStatus('RADIATEUR-CHAMBRE-ETHAN', pacStatus)
elseif slot == 17 then
    print('[MAJ-STATUS] Synchronisation RADIATEUR-CHAMBRE-MATHIS (Atlantic)')
    local pacStatus = getAtlanticPacStatus(ATLANTIC_DEVICE_URL_CHAMBRE_MATHIS)
    syncStatus('RADIATEUR-CHAMBRE-MATHIS', pacStatus)
end

return commandArray
