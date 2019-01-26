#include "settings\global_settings.sqf"

// Check if mission setup is to be run, or if the mission is to run normally
if (isServer and !isDedicated and ENABLE_MISSION_SETUP) then {
  // Run mission setup init
  [] execVM "scripts\server\missionSetup\setup_init.sqf";
} else {

  // Run mission normally
  RscSpectator_allowFreeCam = true;
  call compile preprocessFileLineNumbers "scripts\common\init.sqf";
  /*["Initialize", [player, [], true, true, true, true, true, true, true, true]] call BIS_fnc_EGSpectator;*/
  /*[] execVM "VCOMAI\init.sqf";*/
  if (isServer) then {
    call compile preprocessFileLineNumbers "scripts\server\init.sqf";
    _handle = execVM "scripts\server\gameManager.sqf";
  };

  if (hasInterface) then {
    hint "Welcome Client! How are you?";
    _handle2 = execVM "scripts\client\init.sqf";
  };
};
