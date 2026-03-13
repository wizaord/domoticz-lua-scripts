--
-- Synchronise en un seul appel PAC le statut ON/OFF (RADIATEUR-*) et la temperature
-- de consigne (THERMOSTAT-*) des devices Domoticz.
-- Chaque PAC est interrogee toutes les 20 minutes, avec un decalage de 5 minutes entre chaque.
--   slot 0  : PAC Fujitsu Salon
--   slot 5  : PAC Atlantic Chambre Parents
--   slot 10 : PAC Atlantic Chambre Ethan
--   slot 15 : PAC Atlantic Chambre Mathis
--

package.path = package.path .. ';' .. '/home/wizaord/domoticz/scripts/lua/?.lua'
require("lib_conf")
require("lib_radiateur_fujitsu")
require("lib_radiateur_atlantic")

commandArray = {}

currentTime = os.time()
currentDate = os.date("*t", currentTime)
slot = currentDate.min % 20

-- Synchronise le statut ON/OFF d'un radiateur Domoticz avec l'etat reel de la PAC.
local function syncStatus(deviceName, pacStatus)
    local currentDeviceStatus = otherdevices[deviceName]
    print('[MAJ-PAC] Statut device Domoticz : ' .. tostring(currentDeviceStatus))
    print('[MAJ-PAC] Statut reel PAC        : ' .. pacStatus)
    if (currentDeviceStatus == pacStatus) then
        print('[MAJ-PAC] Statuts coherents, aucune mise a jour necessaire')
    else
        print('[MAJ-PAC] Desynchronisation detectee, mise a jour : ' .. tostring(currentDeviceStatus) .. ' --> ' .. pacStatus)
        commandArray[deviceName] = pacStatus
    end
end

-- Synchronise la temperature de consigne d'un thermostat Domoticz avec celle de la PAC.
local function syncThermostat(deviceName, targetTemp)
    if targetTemp == nil then
        print('[MAJ-PAC] ' .. deviceName .. ' : temperature de consigne non disponible, pas de mise a jour')
        return
    end
    local currentTemp = tonumber(otherdevices_svalues[deviceName])
    print('[MAJ-PAC] Consigne Domoticz : ' .. tostring(currentTemp) .. '°C')
    print('[MAJ-PAC] Consigne reel PAC : ' .. targetTemp .. '°C')
    if (currentTemp == targetTemp) then
        print('[MAJ-PAC] Consignes coherentes, aucune mise a jour necessaire')
    else
        print('[MAJ-PAC] Desynchronisation detectee, mise a jour : ' .. tostring(currentTemp) .. ' --> ' .. targetTemp .. '°C')
        commandArray[deviceName] = tostring(targetTemp)
    end
end

if slot == 0 then
    print('[MAJ-PAC] Mise a jour SALON (Fujitsu)')
    local pac = getFujitsuFullStatus(FUJITSU_PAC_SALON_IP)
    syncStatus('RADIATEUR-SALON', pac.status)
    syncThermostat('THERMOSTAT-SALON', pac.targetTemp)

elseif slot == 5 then
    print('[MAJ-PAC] Mise a jour CHAMBRE-PARENTS (Atlantic)')
    local pac = getAtlanticFullStatus(ATLANTIC_DEVICE_URL_CHAMBRE_PARENTS)
    syncStatus('RADIATEUR-CHAMBRE-PARENTS', pac.status)
    syncThermostat('THERMOSTAT-CHAMBRE-PARENTS', pac.targetTemp)

elseif slot == 10 then
    print('[MAJ-PAC] Mise a jour CHAMBRE-ETHAN (Atlantic)')
    local pac = getAtlanticFullStatus(ATLANTIC_DEVICE_URL_CHAMBRE_ETHAN)
    syncStatus('RADIATEUR-CHAMBRE-ETHAN', pac.status)
    syncThermostat('THERMOSTAT-CHAMBRE-ETHAN', pac.targetTemp)

elseif slot == 15 then
    print('[MAJ-PAC] Mise a jour CHAMBRE-MATHIS (Atlantic)')
    local pac = getAtlanticFullStatus(ATLANTIC_DEVICE_URL_CHAMBRE_MATHIS)
    syncStatus('RADIATEUR-CHAMBRE-MATHIS', pac.status)
    syncThermostat('THERMOSTAT-CHAMBRE-MATHIS', pac.targetTemp)
end

return commandArray
