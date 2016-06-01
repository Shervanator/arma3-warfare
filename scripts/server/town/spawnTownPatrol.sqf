params ["_town"];


_patrolForces = [];

if (isNil "_town getVariable 'savedGroups'") then {
  hint "aaaa";
  _patrolForces = _town call WF_createPatrolGroup;
} else {
  _savedGroups = _town getVariable "savedGroups";
  _patrolForces = [_savedGroups, _town getVariable "townOwner"] call WF_restoreGroupState;
};

_town setVariable ["patrolForces", _patrolForces];

_town setVariable ["savedGroups", []];
