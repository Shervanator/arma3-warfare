params ["_town"];

_patrolForces = _town getVariable "patrolForces";
_savedGroups = [];

{
  _savedGroups pushBack (_x call WF_saveGroupState);
  {
    if (vehicle _x != _x) then {
      deleteVehicle (vehicle _x);
    };
    deleteVehicle _x;
  } forEach (units _x);

  deleteGroup _x;
} forEach _patrolForces;

_town setVariable ["savedGroups", _savedGroups];
_town setVariable ["patrolForces", []];
