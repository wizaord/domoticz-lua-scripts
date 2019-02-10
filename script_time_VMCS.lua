--
-- Ce script est lance toutes les minutes. Il va verifier si la VMC
-- est coupee depuis plus de 6h. Si oui la VMC est lancee pendant
-- 30 minutes
-- La VMC n est pas allumee la nuit pour garder la chaleur
--

package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua'
require("lib_vmc")

commandArray = {}

runningMode = getVmcMode(tonumber(otherdevices_svalues['VMC-MODE']))
print('VMC : Mode de fonctionnement : ' .. runningMode);
if (runningMode == "OFF" or runningMode == "MANUEL") then
    --mode manuel, on ne fait rien
    print('VMC : Mode OFF ou MANUEL ACTIVE. Do nothing')
    return commandArray
end


-- Si le radiateur est actif, on ne lance pas la VMC pour moins gaspiller
isRadiateurCouloirRunning = otherdevices['RADIATEUR-COULOIR']
isRadiateurSalonRunning = otherdevices['RADIATEUR-SALON']
if (isRadiateurCouloirRunning == 'On' or isRadiateurSalonRunning == 'On') then
    -- on coupe le radiateur
    print('VMC: Non demarrage de la VMC car un des radiateurs fonctionne');
    return commandArray;
end

VMCLastEventTime = timeBetweenLastVMCEvent();
print('VMC : last executed time : ' .. VMCLastEventTime)
if (otherdevices['VMC-ALL'] == 'Off' and VMCLastEventTime > 21600) then

    -- on regarde si c est la nuit
    if (isNigth(hour) == 1) then
        --on va verifier la temperature a l'exterieur
        outTemperature, outHumidity = otherdevices_svalues["WU_Temp"]:match("([^;]+);([^;]+)")
        if (tonumber(outTemperature) > 5) then
            commandArray['Group:VMCs'] = 'On FOR 30'
        end
    else
        print("Allumage de la VMC car eteinte depuis 6h")
        commandArray['Group:VMCs'] = 'On FOR 30'
    end
end

return commandArray
