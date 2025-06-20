--
-- Ce script est lance toutes les minutes. Il gere le chauffage dans la maison en fonction de la temperature choisie et de la temperature en cours
--

package.path = package.path .. ';' .. '/home/wizaord/domoticz/scripts/lua/?.lua'
require("lib_radiateur")
require("lib_conf")
require("lib_edf_tempo")

--
-- FUNCTION
--

-- 
-- MAIN
--

commandArray = {}

runningMode = getRadiatorMode(tonumber(otherdevices_svalues['RADIATEUR-MODE']))
print('SALON : Mode de fonctionnement : ' .. runningMode);

if (runningMode == "OFF" or runningMode == "MANUEL") then
    --mode manuel, on ne fait rien
    print('SALON : Radiateur : Mode OFF ou MANUEL ACTIVE. Do nothing')
    return commandArray
end

if (isEdfTempoRedDay("SALON")) then
    currentTime = os.time()
    currentDate = os.date("*t", currentTime)
    -- if time is between 6h00 and 22h00, force the temperature to 16
    if (currentDate.hour >= 6 and currentDate.hour < 22) then
        print("SALON : TEMPO MODE - En heures pleines - Coupure du chauffage - HORSGEL")
        runningMode = "HORSGEL"
    else
        print("SALON : TEMPO MODE - En heures creuse - On ne change pas le mode de fonctionnement")
    end
end

temperatureVoulue = tonumber('16');

if (runningMode == "WEEKEND_OFF") then
    if (isWeekendOffMode()) then
        temperatureVoulue = tonumber('16');
    else
        runningMode = "AUTO"
    end
end
if (runningMode == "HORSGEL") then
    temperatureVoulue = tonumber('10');
end
if (runningMode == "FORCE16") then
    temperatureVoulue = tonumber('16');
end
if (runningMode == "AUTO") then
    temperatureVoulue = tonumber(otherdevices['Thermostat-SALON'])
end

-- Recuperation de la temperature du salon
temperatureSalon = tonumber(otherdevices['TH-SALON'])
-- on regarde si le radiateur est eteint ou non
isRadiateurRunning = otherdevices['RADIATEUR-SALON']

-- algo mis en place
-- si la temperature du salon est > de 2 dege on coupe la VMC
-- si la temperature redevient au la temperature voulu et que le radiateur est coupe, on le redemarre
print('SALON : Temperature voulu : ' .. temperatureVoulue .. '  -- Temperature en cours : ' .. temperatureSalon)

if (temperatureSalon > (temperatureVoulue + 1.4) and isRadiateurRunning == 'On') then
    -- on coupe le radiateur
    print('SALON : Arret du radiateur')
    commandArray['RADIATEUR-SALON'] = 'Off'
end

if (temperatureSalon <= temperatureVoulue and isRadiateurRunning == 'Off') then
    --on redemarre le radiateura la temperature voulu
    changeTemperature('RADIATEUR-SALON', PI_SALON_SERVEUR_LOGIN, PI_SALON_SERVEUR_IP, temperatureVoulue + 1)
    commandArray['Variable:RADIATEUR-SALON-LASTSEND'] = '' .. math.floor(temperatureVoulue)
    commandArray['Variable:RADIATEUR-SALON-STATUS'] = 'On'
    commandArray['RADIATEUR-SALON'] = 'On'
end

return commandArray
