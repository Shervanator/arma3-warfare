params ["_town"];

_patrolForces = _town call WF_createPatrolGroup;
_town setVariable ["patrolForces", _patrolForces];
