WF_findClosestObjective = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_findClosestObjective.sqf";
WF_createPatrolGroup = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_createPatrolGroup.sqf";
WF_saveGroupState = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_saveGroupState.sqf";
WF_restoreGroupState = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_restoreGroupState.sqf";
WF_deleteGroup = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_deleteGroup.sqf";
WF_createTrigger = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_createTrigger.sqf";
WF_buildUnit = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_buildUnit.sqf";
WF_buildVehicle = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_buildVehicle.sqf";
WF_buyWeapon = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_buyWeapon.sqf";

[west, "WEST1"] call BIS_fnc_addRespawnInventory;
[west, "WEST2"] call BIS_fnc_addRespawnInventory;
