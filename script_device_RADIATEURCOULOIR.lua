--
-- Ce script permet d'allumer ou de couper le radiateur du salon.
-- Il faut passer par le RPI pour ealiser l'action
--
package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua'
require("lib_radiateur")

--
-- variables definition
--
DEVICE_NAME = 'RADIATEUR-COULOIR'

SERVEUR_IP = "192.168.1.12"
SERVEUR_LOGIN = "pi"

commandArray = {}
if (devicechanged[DEVICE_NAME]) then
    -- on recupere le status courant. Le radiateur peut etre eteint par le thermostat
    radiateurStatus = uservariables['RADIATEUR-COULOIR-STATUS']

    --on determine si on allume ou on eteint le radiateur
    status = devicechanged[DEVICE_NAME]

    if (status == radiateurStatus) then
        print('Le status est le eme, on ne fait rien')
    else
        commandArray['SendEmail'] = '[DOMOTICZ] RADIATEUR#Modification de status pour le radiateur couloir : ' .. status .. '#mouilleron.cedric@gmail.com'
        if (status == 'On') then
            startRadiateur()
            commandArray['Variable:RADIATEUR-COULOIR-STATUS'] = 'On'
        else
            stopRadiateur()
            commandArray['Variable:RADIATEUR-COULOIR-STATUS'] = 'Off'
        end
    end
end
return commandArray