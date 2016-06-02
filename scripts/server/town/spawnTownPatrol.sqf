params ["_town"];


_patrolForces = [];
_savedGroups = _town getVariable "savedGroups";

if (count _savedGroups > 0) then {
  _patrolForces = [_savedGroups, _town getVariable "townOwner"] call WF_restoreGroupState;
} else {
  hint format ["%1", random 50];
  _patrolForces = _town call WF_createPatrolGroup;
};

_town setVariable ["patrolForces", _patrolForces];

_town setVariable ["savedGroups", []];
