--
-- Ce script va s'executer la nuit a 5h30
-- Ce script va aller rechercher le taux d'humidite dans la Salle de bain
-- Ce taux d'humidite va alors devenir le taux de reference pour la journee
-- Ce taux de reference est utilise pour detecter si quelqu'un a pris un douche ou non
-- En effet le taux d'humidite varie en fonction de l'annee. Ce script permet de palier a cette fluctuation.
--
package.path = package.path .. ';' .. '/home/wizaord/domoticz/scripts/lua/?.lua'
require("lib_conf")

currentTime = os.time()
currentDate = os.date("*t", currentTime)

commandArray = {}

if (currentDate.hour == 5 and currentDate.min == 10) then
    print("Save the current humidity as reference for the next day")

    --get the humidity value from SDB humidity sensor
    sdbHumidity = tonumber(otherdevices['HU-SALLEDEBAIN'])
    if (sdbHumidity == nil or sdbHumidity == '') then
        local emailAddress = uservariables['email_address']
        commandArray['SendEmail'] = '[DOMOTICZ] HUMIDITY REF#Erreur de recuperation. Set default value a 50#' .. emailAddress
        sdbHumidity = 50
    end
    print("reference humidity value is " .. math.floor(sdbHumidity))
    commandArray['Variable:HUMIDITY_REF'] = '' .. math.floor(sdbHumidity)
end

return commandArray
