params ["_hqMarker", "_towns", "_side", "_teamGroups"];

{
  _currentOrder = _x getVariable "order";
  if ((isNil "_currentOrder")) then {
    _minTown = [(getPos (leader _x)), _towns, _side] call WF_findClosestObjective;
    _x setVariable ["order", _minTown];
    _wp = _x addWaypoint [(getPos _minTown), 50];
  } else {
    if ((_currentOrder getVariable "townOwner") == _side) then {
      _minTown = [(getPos (leader _x)), _towns, _side] call WF_findClosestObjective;
      _x setVariable ["order", _minTown];
      _wp = _x addWaypoint [(getPos _minTown), 50];
    };
  };

} forEach _teamGroups;
