--
-- Ce script permet de realiser les changements de temperature en fonction de ce qui est programme dans  le thermostat
--
package.path = package.path .. ';' .. '/home/wizaord/domoticz/scripts/lua/?.lua'
require("lib_radiateur")
require("lib_conf")

--
-- variables definition
--
THERMOSTAT_NAME = 'Thermostat-COULOIR'

commandArray = {}
if (devicechanged[THERMOSTAT_NAME]) then
    -- on regarde si le radiateur n'est pas en mode manuel
    runningMode = getRadiatorMode(tonumber(otherdevices_svalues['RADIATEUR-MODE']))
    print('THERMOSTAT COULOIR : Mode de fonctionnement : ' .. runningMode);
    if (runningMode == "OFF" or runningMode == "MANUEL") then
        --mode manuel, on ne fait rien
        print('Mode OFF ou MANUEL ACTIVE. Do nothing')
        return commandArray
    end

    -- si c'est le weekend ou mode forcé, on ne realise aucune action
    if (runningMode == "WEEKEND_OFF") then
        if (isWeekendOffMode()) then
            print('Mode WEEKEND . Do nothing')
            return commandArray
        end
    end

    -- on recupere la temperature du thermostat
    newTemp = math.floor(tonumber(devicechanged[THERMOSTAT_NAME]))

    -- on recupere la temperature du salon
    couloirTemp = tonumber(otherdevices['TH-CHAMBREETHAN'])

    -- on recupere la derniere temperature envoye
    lastTempSend = tonumber(uservariables['RADIATEUR-COULOIR-LASTSEND'])

    -- on regarde si le radiateur est eteint ou non
    isRadiateurRunning = otherdevices['RADIATEUR-COULOIR']

    -- si on est en mode FORCE16, on force la temperature a 16 degre
    if (runningMode == "FORCE16") then
        print('COULOIR : FORCE16 activé')
        newTemp = tonumber('16');
    end

    print('COULOIR : Thermostat couloir new temp : ' .. newTemp)
    print('COULOIR : Temperature du couloir      : ' .. couloirTemp)
    print('COULOIR : Derniere temperature send : ' .. lastTempSend)
    print('COULOIR : Radiateur statut          : ' .. isRadiateurRunning)

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
                changeTemperature('RADIATEUR-COULOIR', PI_COULOIR_SERVEUR_LOGIN, PI_COULOIR_SERVEUR_IP, newTemp + 2)
                commandArray['Variable:RADIATEUR-COULOIR-LASTSEND'] = '' .. math.floor(newTemp)
                commandArray['Variable:RADIATEUR-COULOIR-STATUS'] = 'On'
                commandArray['RADIATEUR-COULOIR'] = 'On'
            end
        else
            -- radiateur is running
            changeTemperature('RADIATEUR-COULOIR', PI_COULOIR_SERVEUR_LOGIN, PI_COULOIR_SERVEUR_IP, newTemp + 2)
            commandArray['Variable:RADIATEUR-COULOIR-LASTSEND'] = '' .. math.floor(newTemp)
        end
    end
end
return commandArray
