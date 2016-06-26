private ["_vehicle", "_strengthPoints"];
params ["_town"];

_patrolForces = _town getVariable "patrolForces";
_savedGroups = [];
_allPatrolForces = [];

{
  _allPatrolForces append (units _x);
} forEach _patrolForces;

_town setVariable ["patrolForceStrength", [_allPatrolForces] call WF_estimateForceStrength];

{
  // First check to see if the group has any members left, as groups without members are not deleted automatically
  if ((count (units _x)) > 0) then {
    _savedGroups pushBack (_x call WF_saveGroupState);
    _x call WF_deleteGroup;
  } else {
    deleteGroup _x;
  };
} forEach _patrolForces;

_town setVariable ["savedGroups", _savedGroups];
_town setVariable ["patrolForces", []];
