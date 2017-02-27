--
-- Ce script permet de realiser les changements de temperature en fonction de ce qui est programme dans  le thermostat
--
package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua'
require("lib_radiateur")

--
-- variables definition
--
DEVICE_NAME = 'Thermostat-COULOIR'
SERVEUR_IP = "192.168.1.12"
SERVEUR_LOGIN = "pi"

commandArray = {}
if (devicechanged[DEVICE_NAME]) then
    --on regarde si le radiateur n'est pas en mode manuel
    isModeManuel = otherdevices['RADIATEUR-MODE-MANUEL']

    if (isModeManuel == "On") then
        print('Radiateur : mode manuel active. Thermostat ne marche pas')
        return commandArray
    end

    --on determine si on allume ou on eteint le radiateur
    newTemp = math.floor(tonumber(devicechanged[DEVICE_NAME]))

    -- on recupere la temperature du salon
    couloirTemp = tonumber(otherdevices_svalues['TH-CHAMBREMATHIS']:match("([^;]+);.*"))

    -- on recupere la dernere temperature envoye
    lastTempSend = tonumber(uservariables['RADIATEUR-COULOIR-LASTSEND'])

    -- on regarde si le radiateur est eteint ou non
    isRadiateurRunning = otherdevices['RADIATEUR-COULOIR']

    print('Thermostat couloir new temp : ' .. newTemp)
    print('Temperature du couloir      : ' .. couloirTemp)
    print('Derniere temperature send : ' .. lastTempSend)
    print('Radiateur statut          : ' .. isRadiateurRunning)

    -- si la derniere commande envoye est la eme, on ne fait rien
    -- si le radiateur est eteint et la temperature > thermostat => on ne fait rien
    -- si le radiateur est eteint et la temperature < thermostat => on rallume le tout et on change la temperature
    -- si le radiateur est allume et la temperature > thermostat => on ennvoie la nouvelle commande de temperature
    -- si le radiateur est allume et la temperature < thermostat => on envoie la nouvelle commande de temperature

    if (newTemp == lastTempSend) then
        print('Do nothing, same temperature has always been send')
    else
        if (isRadiateurRunning == "Off") then
            -- radiateur is stopped
            if (newTemp > couloirTemp) then
                changeTemperature(newTemp + 3)
                commandArray['Variable:RADIATEUR-COULOIR-LASTSEND'] = '' .. newTemp
                commandArray['Variable:RADIATEUR-COULOIR-STATUS'] = 'On'
                commandArray['RADIATEUR-COULOIR'] = 'On'
                commandArray['SendEmail'] = '[DOMOTICZ] RADIATEUR#Modification de status pour le radiateur couloir : On#mouilleron.cedric@gmail.com'
            end
        else
            -- radiateur is running
            changeTemperature(newTemp)
            commandArray['Variable:RADIATEUR-COULOIR-LASTSEND'] = '' .. newTemp
        end
    end
end
return commandArray