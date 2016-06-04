params ["_hqMarker", "_towns", "_side", "_teamGroups"];

setWaypoint ={
  params ["_group", "_towns", "_side"];
  private ["_group", "_towns", "_side"];

  _leader = leader _group;
  _minTown = [(getPos _leader), _towns, _side] call WF_findClosestObjective;
  _group setVariable ["order", _minTown];

  while {(count (waypoints _group)) > 0} do {
    _waypoint = ((waypoints _group) select 0);
    _waypoint setWPPos _leader;
    deleteWaypoint _waypoint;
  };

  _group addWaypoint [(getPos _minTown), 50]
};

{
  _currentOrder = _x getVariable "order";
  if ((isNil "_currentOrder")) then {
    [_x, _towns, _side] call setWaypoint;
  } else {
    if ((_currentOrder getVariable "townOwner") == _side) then {
      [_x, _towns, _side] call setWaypoint;
    };
  };
} forEach _teamGroups;
