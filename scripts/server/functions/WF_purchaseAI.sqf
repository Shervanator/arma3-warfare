private ["_sideStr", "_units", "_unit", "_parentGroup"];
params ["_parentGroup"];

_sideStr = str (side _parentGroup);
_units = missionNamespace getVariable ("WF_arrayTypes_" + _sideStr + "infantry");
_unit = _units select (floor (random (count _units)));
[_parentGroup, configName (_unit select 0), _unit select 1] call WF_buildUnit;
