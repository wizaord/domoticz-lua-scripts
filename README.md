# domoticz-lua-scripts
Some lua scripts for my home domoticz

# Libraries
## lib_radiateur
Library to handle my radiator

# Scripts Device
## script_device_demo.lua
The default demo domoticz device lua script. Keep in git in order to see what type of functions I can use with LUA
## script_device_RADIATEURSALON.lua
This lua script is called when the status of my radiator changes.
The goal of this script is to start and stop the radiator.
## script_device-SDB-H.lua
This lua script is called when the bathroom humidity changes. If the humidity
is too high, the VMC is started.
## script_device_Thermostat-salon.lua
This lua script is called when the thermostat changes the temperature. Based on the thermostat, this script
will start, stop or change the radiator temperature.
## script_device_VMCS.lua
Used to start or stop all VMCs in the house.

# Scripts Time
## script_time_CHAUFFAGE.lua
Called every minute, this script can stop/start the radiator if the temperature is too high or too low.
## script_time_demo.lua
Default script. 
## script_time_REFHUMIDITY.lua
Called on the night at 5am, this script saves the humidity in the bathroom. This value is the reference humidity value for the day.
## script_time_VMCS.lua
Check every minute the time between the last time the VMCs were turn on. If the time is too long, this script starts VMCs.