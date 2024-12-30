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
print('COULOIR : Mode de fonctionnement : ' .. runningMode);

if (isEdfTempoRedDay("COULOIR")) then
    currentTime = os.time()
    currentDate = os.date("*t", currentTime)
    -- if time is between 6h00 and 22h00, force the temperature to 16
    if (currentDate.hour >= 6 and currentDate.hour < 22) then
        print("COULOIR : TEMPO MODE - En heures pleines - Coupure du chauffage - FORCE 16")
        runningMode = "HORSGEL"
    else
        print("COULOIR : TEMPO MODE - En heures creuse - On ne change pas le mode de fonctionnement")
    end
end

if (runningMode == "OFF" or runningMode == "MANUEL") then
    --mode manuel, on ne fait rien
    print('COULOIR : Radiateur : Mode OFF ou MANUEL ACTIVE. Do nothing')
    return commandArray
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
    temperatureVoulue = tonumber(otherdevices['Thermostat-COULOIR'])
end

-- Recuperation de la temperature du salon
temperatureCouloir = tonumber(otherdevices['TH-CHAMBREETHAN'])
-- on regarde si le radiateur est eteint ou non
isRadiateurRunning = otherdevices['RADIATEUR-COULOIR']

-- algo mis en place
-- si la temperature du salon est > de 2 dege on coupe la VMC
-- si la temperature redevient au la temperature voulu et que le radiateur est coupe, on le redemarre
print('COULOIR : Temperature voulu : ' .. temperatureVoulue .. '  -- Temperature en cours : ' .. temperatureCouloir)


if ( temperatureCouloir > (temperatureVoulue + 1.4) and isRadiateurRunning == 'On') then
	-- on coupe le radiateur
    print('COULOIR : Arret du radiateur')
	commandArray['RADIATEUR-COULOIR'] = 'Off'
end

if ( temperatureCouloir <= temperatureVoulue and isRadiateurRunning == 'Off') then
	--on redemarre le radiateura la temperature voulu
    changeTemperature('RADIATEUR-COULOIR', PI_COULOIR_SERVEUR_LOGIN, PI_COULOIR_SERVEUR_IP, temperatureVoulue + 2)
    commandArray['Variable:RADIATEUR-COULOIR-LASTSEND'] = '' .. math.floor(temperatureVoulue)
    commandArray['Variable:RADIATEUR-COULOIR-STATUS'] = 'On'
    commandArray['RADIATEUR-COULOIR'] = 'On'
end

return commandArray
