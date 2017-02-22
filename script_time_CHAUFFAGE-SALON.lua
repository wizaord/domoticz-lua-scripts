--
-- Ce script est lance toutes les minutes. Il gere le chauffage dans la maison en fonction de la temperature choisi et de la temperature en cours 
--

package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua'
require("lib_radiateur")


SERVEUR_IP = "192.168.1.8"
SERVEUR_LOGIN = "pi"

currentTime = os.time()
currentDate = os.date("*t", currentTime)

-- 
-- FUNCTION
--

-- 
-- MAIN
--
-- Recuperation de la temperature du salon
temperatureSalon = tonumber(otherdevices_svalues['TH-SALON']:match("([^;]+);.*"))
temperatureThermostat = tonumber(otherdevices['Thermostat-SALON'])

isModeManuel = otherdevices['RADIATEUR-MODE-MANUEL']

-- on regarde si le radiateur est eteint ou non
isRadiateurRunning = otherdevices['RADIATEUR-SALON']

-- algo mis en place
-- si la temperature du salon est > de 2 dege on coupe la VMC
-- si la temperature redevient au la temperature voulu et que le radiateur est coupe, on le redemarre

commandArray = {}

-- si on est en mode manuel, on ne fait rien
if ( isModeManuel == "On") then
      print('Radiateur : mode manuel active. Thermostat time ne marche pas')
      return commandArray
end

if ( temperatureSalon > (temperatureThermostat + 1.4) and isRadiateurRunning == 'On') then
	-- on coupe le radiateur
	commandArray['RADIATEUR-SALON'] = 'Off'
end

print ('Temperature voulu : ' .. temperatureThermostat .. '  -- Temperature en cours : ' .. temperatureSalon)

if ( temperatureSalon <= temperatureThermostat and isRadiateurRunning == 'Off') then
	--on redemarre le radiateura la temperature voulu
    changeTemperature(temperatureThermostat)
    commandArray['Variable:RADIATEUR-SALON-LASTSEND'] = ''..temperatureThermostat
    commandArray['Variable:RADIATEUR-SALON-STATUS'] = 'On'
    commandArray['RADIATEUR-SALON'] = 'On'
    commandArray['SendEmail'] = '[DOMOTICZ] RADIATEUR#Modification de status pour le radiateur salon : On#mouilleron.cedric@gmail.com'
end

return commandArray
