--
-- Met a jour les thermostats Domoticz avec la temperature ambiante mesuree par chaque PAC.
-- Chaque PAC est interrogee toutes les 20 minutes, avec un decalage de 5 minutes entre chaque.
--

package.path = package.path .. ';' .. '/home/wizaord/domoticz/scripts/lua/?.lua'
require("lib_conf")
require("lib_radiateur_fujitsu")
require("lib_radiateur_atlantic")

commandArray = {}

currentTime = os.time()
currentDate = os.date("*t", currentTime)
slot = currentDate.min % 20

if slot == 0 then
    print('[MAJ-THERMOSTATS] Mise a jour THERMOSTAT-SALON (Fujitsu)')
    local temp = getFujitsuTemperature(FUJITSU_PAC_SALON_IP)
    if temp then
        commandArray['THERMOSTAT-SALON'] = tostring(temp)
        print('[MAJ-THERMOSTATS] THERMOSTAT-SALON mis a jour : ' .. temp .. '°C')
    end
elseif slot == 5 then
    print('[MAJ-THERMOSTATS] Mise a jour THERMOSTAT-CHAMBRE-PARENTS (Atlantic)')
    local temp = getAtlanticTemperature(ATLANTIC_DEVICE_URL_CHAMBRE_PARENTS)
    if temp then
        commandArray['THERMOSTAT-CHAMBRE-PARENTS'] = tostring(temp)
        print('[MAJ-THERMOSTATS] THERMOSTAT-CHAMBRE-PARENTS mis a jour : ' .. temp .. '°C')
    end
elseif slot == 10 then
    print('[MAJ-THERMOSTATS] Mise a jour THERMOSTAT-CHAMBRE-ETHAN (Atlantic)')
    local temp = getAtlanticTemperature(ATLANTIC_DEVICE_URL_CHAMBRE_ETHAN)
    if temp then
        commandArray['THERMOSTAT-CHAMBRE-ETHAN'] = tostring(temp)
        print('[MAJ-THERMOSTATS] THERMOSTAT-CHAMBRE-ETHAN mis a jour : ' .. temp .. '°C')
    end
elseif slot == 15 then
    print('[MAJ-THERMOSTATS] Mise a jour THERMOSTAT-CHAMBRE-MATHIS (Atlantic)')
    local temp = getAtlanticTemperature(ATLANTIC_DEVICE_URL_CHAMBRE_MATHIS)
    if temp then
        commandArray['THERMOSTAT-CHAMBRE-MATHIS'] = tostring(temp)
        print('[MAJ-THERMOSTATS] THERMOSTAT-CHAMBRE-MATHIS mis a jour : ' .. temp .. '°C')
    end
end

return commandArray
