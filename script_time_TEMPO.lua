--
-- Ce script va s'executer la nuit a 5h30
-- Ce script va aller rechercher le taux d'humidite dans la Salle de bain
-- Ce taux d'humidite va alors devenir le taux de reference pour la journee
-- Ce taux de reference est utilise pour detecter si quelqu'un a pris un douche ou non
-- En effet le taux d'humidite varie en fonction de l'annee. Ce script permet de palier a cette fluctuation.
--
package.path = package.path .. ';' .. '/home/wizaord/domoticz/scripts/lua/?.lua'
require("lib_conf")
require("lib_edf_tempo")

currentTime = os.time()
currentDate = os.date("*t", currentTime)

commandArray = {}

function isTimeToCheckTempo()
    return currentDate.min == 00
end

function mapTempoColorToSwitchSelector(tempoColor)
    if (tempoColor == 'BLEU') then
        return 'Set Level: 10'
    end
    if (tempoColor == 'BLANC') then
        return 'Set Level: 20'
    end
    if (tempoColor == 'ROUGE') then
        return 'Set Level: 30'
    end
    return 'Set Level: 0'
end

if (isTimeToCheckTempo()) then
    print("TEMPO : Time to get the TEMPO current day color")
    local currentDayColor = getCurrentColorDay()
    print("TEMPO : the current day color is " .. currentDayColor)
    commandArray['TEMPO_DAY'] = mapTempoColorToSwitchSelector(currentDayColor)
end

return commandArray
