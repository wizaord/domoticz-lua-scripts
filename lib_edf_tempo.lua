
local ltn12 = require("ltn12")
local json = require("dkjson")
local http = require("socket.http")

local EDF_TEMPO_COLOR = {
    BLEU = "BLEU",
    BLANC = "BLANC",
    ROUGE = "ROUGE"
}

url_edf_token_api = "https://digital.iservices.rte-france.com/token/oauth/"
url_edf_open_api = "https://digital.iservices.rte-france.com/open_api/"

function getEnumEdfTempoColor(edfTempoString)
    if edfTempoString == "BLUE" then
        return EDF_TEMPO_COLOR.BLEU
    elseif edfTempoString == "WHITE" then
        return EDF_TEMPO_COLOR.BLANC
    elseif edfTempoString == "RED" then
        return EDF_TEMPO_COLOR.ROUGE
    else
        return nil
    end
end

-- get the bearer auth from API EDF Tempo
function getAuthBearerToken()
    local response_body = {}
    local res, code, response_headers = http.request{
        url = url_edf_token_api,
        method = "POST",
        headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded";
            ["Authorization"] = "Basic " .. EDF_TEMPO_TOKEN,
        },
        sink = ltn12.sink.table(response_body),
    }
    if code ~= 200 then
        print("Error lors de la récupération du token TEMPO:", err)
        return nil
    end
    local response_str = table.concat(response_body)
    local response_json, pos, err = json.decode(response_str, 1, nil)
    if err then
        print("Error:", err)
        return nil
    end
    return response_json["access_token"]
end

function getCurrentDayForEDFTempo()
    currentTime = os.time()
    currentDate = os.date("*t", currentTime)
    return os.date("%Y-%m-%dT00:00:00+01:00")
end

function getNextDayForEDFTempo()
    currentTime = os.time()
    currentDate = os.date("*t", currentTime)
    return os.date("%Y-%m-%dT00:00:00+01:00", os.time{year=currentDate.year, month=currentDate.month, day=currentDate.day+1})
end

function getNextNextDayForEDFTempo()
    currentTime = os.time()
    currentDate = os.date("*t", currentTime)
    return os.date("%Y-%m-%dT00:00:00+01:00", os.time{year=currentDate.year, month=currentDate.month, day=currentDate.day+2})
end

function getCurrentColorDay()
    local url = url_edf_open_api .. "tempo_like_supply_contract/v1/tempo_like_calendars?start_date=" .. getCurrentDayForEDFTempo() .. "&end_date=" .. getNextDayForEDFTempo()
    local bearerToken = "Bearer " .. getAuthBearerToken()
    local response_body = {}
    local res, code = http.request{
        url = url,
        method = "GET",
        headers = {
            ["Authorization"] = bearerToken,
            ["Accept"] = "application/json"
        },
        sink = ltn12.sink.table(response_body),
    }

    if code ~= 200 then
        print("Error lors de l'appel de l'API TEMPO:", err)
        return nil
    end
    local response_str = table.concat(response_body)
    local response_json, pos, err = json.decode(response_str, 1, nil)
    return getEnumEdfTempoColor(response_json["tempo_like_calendars"]["values"][1]["value"])
end

function isEdfTempoRedDay(logger)
    local deviceLevel = tonumber(otherdevices_svalues['TEMPO_DAY'])
    print(logger .. " - TEMPO : Current device level - " .. deviceLevel)
    if (deviceLevel == 30) then
        print(logger .. " - TEMPO : C'est un jour rouge ! ")
        return true
    end
    print(logger .. " - TEMPO : Ce n'est pas un jour rouge")
    return false
end