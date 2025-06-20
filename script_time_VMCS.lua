--
-- Ce script est lance toutes les minutes. Il va verifier si la VMC
-- est coupee depuis plus de 4h. Si oui la VMC est lancee pendant
-- 45 minutes
-- La VMC n est pas allumee la nuit pour garder la chaleur
--

package.path = package.path .. ';' .. '/home/wizaord/domoticz/scripts/lua/?.lua'
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
    -- On ne lance pas la VMC si un des radiateur tourne
    print('VMC: Non demarrage de la VMC car un des radiateurs fonctionne');
    return commandArray;
end

VMCLastEventTime = timeBetweenLastVMCEvent();
print('VMC : last executed time : ' .. VMCLastEventTime .. ' seconds ago')
print('VMC-ALL status : : ' .. otherdevices['VMC-ALL'])
if (otherdevices['VMC-ALL'] == 'Off' and VMCLastEventTime > 14400) then
    print('VMC : starting VMC. Last event was > at 14400 seconds ago (4h)')
    -- on regarde si c est la nuit
    if (isNigth() == 1) then
        --on va verifier la temperature a l'exterieur
        outTemperature, outHumidity = otherdevices_svalues["DS_THB"]:match("([^;]+);([^;]+)")
        if (tonumber(outTemperature) < 0) then
            print("La VMC n'est pas allumee la nuit car la temperature exterieure est negative")
            return commandArray;
        end
    end
    print("Allumage de la VMC car eteinte depuis 4h")
    commandArray['Group:VMCs'] = 'On FOR 45'
end

return commandArray
