--
-- Ce script reagit aux changements des devices RADIATEUR-* pour piloter
-- la PAC correspondante (Fujitsu locale ou Atlantic cloud).
--
package.path = package.path .. ';' .. '/home/wizaord/domoticz/scripts/lua/?.lua'
require("lib_conf")
require("lib_radiateur_fujitsu")
require("lib_radiateur_atlantic")

commandArray = {}

handleFujitsuRadiateur('RADIATEUR-SALON', FUJITSU_PAC_SALON_IP)
handleAtlanticRadiateur('RADIATEUR-CHAMBRE-PARENTS', ATLANTIC_DEVICE_URL_CHAMBRE_PARENTS)
handleAtlanticRadiateur('RADIATEUR-CHAMBRE-ETHAN', ATLANTIC_DEVICE_URL_CHAMBRE_ETHAN)
handleAtlanticRadiateur('RADIATEUR-CHAMBRE-MATHIS', ATLANTIC_DEVICE_URL_CHAMBRE_MATHIS)

return commandArray
