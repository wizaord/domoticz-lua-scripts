--
-- Ce script permet d'allumer ou de couper le radiateur de la chambre Ethan.
-- Il utilise le JAR atlantic-heat-pump-cli pour piloter la PAC Atlantic
-- via le cloud CozyTouch.
--
package.path = package.path .. ';' .. '/home/wizaord/domoticz/scripts/lua/?.lua'
require("lib_conf")
require("lib_radiateur_atlantic")

commandArray = {}
handleAtlanticRadiateur('RADIATEUR-CHAMBRE-ETHAN', ATLANTIC_DEVICE_URL_CHAMBRE_ETHAN)
return commandArray
