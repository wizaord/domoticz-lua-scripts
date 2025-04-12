--
-- Ce script va s'executer toutes les heures
-- Il appelle l'API d'EDF pour recuperer la couleur du jour TEMPO
-- Il met ensuite à jour le switch TEMPO_DAY avec la couleur du jour
--
package.path = package.path .. ';' .. '/home/wizaord/domoticz/scripts/lua/?.lua'
require("lib_conf")
require("lib_edf_tempo")

currentTime = os.time()
currentDate = os.date("*t", currentTime)

commandArray = {}

function isTimeToCheckTempo()
    return true
    --return currentDate.min == 00
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
