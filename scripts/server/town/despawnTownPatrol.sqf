params ["_town"];

_patrolForces = _town getVariable "patrolForces";
_savedGroups = [];

{
  _savedGroups pushBack (_x call WF_saveGroupState);
  _x call WF_deleteGroup;
} forEach _patrolForces;

_town setVariable ["savedGroups", _savedGroups];
_town setVariable ["patrolForces", []];
