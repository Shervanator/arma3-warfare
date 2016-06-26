private ["_group", "_radius"];

_group = group _this;
_objective = _group getVariable "currentObjective";
_radius = (triggerArea (_objective getVariable "alertZone")) select 0;
[_group, _objective, _radius] call WF_setWaypoint;
