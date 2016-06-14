WF_findClosestObjective = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_findClosestObjective.sqf";
WF_createPatrolGroup = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_createPatrolGroup.sqf";
WF_saveGroupState = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_saveGroupState.sqf";
WF_restoreGroupState = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_restoreGroupState.sqf";
WF_deleteGroup = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_deleteGroup.sqf";
WF_createTrigger = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_createTrigger.sqf";
WF_buildUnit = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_buildUnit.sqf";
WF_buildVehicle = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_buildVehicle.sqf";
WF_buyWeapons = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_buyWeapons.sqf";
WF_buyItem = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_buyItem.sqf";
WF_buyBackpack = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_buyBackpack.sqf";
WF_setWaypoint = compileFinal preprocessFileLineNumbers "scripts\server\functions\WF_setWaypoint.sqf";

[west, "WEST1"] call BIS_fnc_addRespawnInventory;
[west, "WEST2"] call BIS_fnc_addRespawnInventory;
