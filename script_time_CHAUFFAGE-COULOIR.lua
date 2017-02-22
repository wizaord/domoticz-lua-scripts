--
-- Ce script est lance toutes les minutes. Il gere le chauffage dans la maison en fonction de la temperature choisi et de la temperature en cours 
--

package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua'
require("lib_radiateur")


SERVEUR_IP = "192.168.1.12"
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
temperatureCouloir = tonumber(otherdevices_svalues['TH-CHAMBREMATHIS']:match("([^;]+);.*"))
temperatureThermostat = tonumber(otherdevices['Thermostat-COULOIR'])

isModeManuel = otherdevices['RADIATEUR-MODE-MANUEL']

-- on regarde si le radiateur est eteint ou non
isRadiateurRunning = otherdevices['RADIATEUR-COULOIR']

-- algo mis en place
-- si la temperature du salon est > de 2 dege on coupe la VMC
-- si la temperature redevient au la temperature voulu et que le radiateur est coupe, on le redemarre

commandArray = {}

-- si on est en mode manuel, on ne fait rien
if ( isModeManuel == "On") then
      print('Radiateur : mode manuel active. Thermostat time ne marche pas')
      return commandArray
end

if ( temperatureCouloir > (temperatureThermostat + 1.4) and isRadiateurRunning == 'On') then
	-- on coupe le radiateur
	commandArray['RADIATEUR-COULOIR'] = 'Off'
end

print ('Temperature voulu : ' .. temperatureThermostat .. '  -- Temperature en cours : ' .. temperatureCouloir)

if ( temperatureCouloir <= temperatureThermostat and isRadiateurRunning == 'Off') then
	--on redemarre le radiateura la temperature voulu
    changeTemperature(temperatureThermostat)
    commandArray['Variable:RADIATEUR-COULOIR-LASTSEND'] = ''..temperatureThermostat
    commandArray['Variable:RADIATEUR-COULOIR-STATUS'] = 'On'
    commandArray['RADIATEUR-COULOIR'] = 'On'
    commandArray['SendEmail'] = '[DOMOTICZ] RADIATEUR#Modification de status pour le radiateur couloir : On#mouilleron.cedric@gmail.com'
end

return commandArray
