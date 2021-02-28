
function isDoorOpened(DOOR_NAME)
    --print("Door " .. DOOR_NAME .. " Status : " .. otherdevices[DOOR_NAME])
    return otherdevices[DOOR_NAME] ~= "Closed"
end