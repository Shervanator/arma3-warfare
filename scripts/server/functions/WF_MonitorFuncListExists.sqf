private ["_side"];
params ["_side"];

if (isNil {missionNamespace getVariable ("monitorFunctions" + (str _side))}) then {
  missionNamespace setVariable [("monitorFunctions" + (str _side)), []];
};
