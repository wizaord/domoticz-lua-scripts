--
-- Ce script permet de realiser les changements de temperature en fonction de ce qui est programme dans  le thermostat
--
package.path = package.path .. ';' .. '/home/wizaord/domoticz/scripts/lua/?.lua'
require("lib_radiateur")
require("lib_conf")

--
-- variables definition
--
THERMOSTAT_NAME = 'Thermostat-SALON'

commandArray = {}
if (devicechanged[THERMOSTAT_NAME]) then
    --on regarde si le radiateur n'est pas en mode manuel
    runningMode = getRadiatorMode(tonumber(otherdevices_svalues['RADIATEUR-MODE']))
    print('THERMOSTAT SALON : Mode de fonctionnement : ' .. runningMode);
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
    salonTemp = tonumber(otherdevices['TH-SALON'])

    -- on recupere la derniere temperature envoye
    lastTempSend = tonumber(uservariables['RADIATEUR-SALON-LASTSEND'])

    -- on regarde si le radiateur est eteint ou non
    isRadiateurRunning = otherdevices['RADIATEUR-SALON']

    -- si on est en mode FORCE16, on force la temperature a 16 degre
    if (runningMode == "FORCE16") then
        print('SALON : FORCE16 activé')
        newTemp = tonumber('16');
    end

    print('SALON : Thermostat salon new temp : ' .. newTemp)
    print('SALON : Temperature du salon      : ' .. salonTemp)
    print('SALON : Derniere temperature send : ' .. lastTempSend)
    print('SALON : Radiateur statut          : ' .. isRadiateurRunning)

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
            if (newTemp > salonTemp) then
                changeTemperature('RADIATEUR-SALON', PI_SALON_SERVEUR_LOGIN, PI_SALON_SERVEUR_IP, newTemp + 1)
                commandArray['Variable:RADIATEUR-SALON-LASTSEND'] = '' .. math.floor(newTemp)
                commandArray['Variable:RADIATEUR-SALON-STATUS'] = 'On'
                commandArray['RADIATEUR-SALON'] = 'On'
            end
        else
            -- radiateur is running
            changeTemperature('RADIATEUR-SALON', PI_SALON_SERVEUR_LOGIN, PI_SALON_SERVEUR_IP, newTemp + 1)
            commandArray['Variable:RADIATEUR-SALON-LASTSEND'] = '' .. math.floor(newTemp)
        end
    end
end
return commandArray
